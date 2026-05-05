#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
gate_script="${script_dir}/harness-gate.sh"

usage() {
  cat <<'EOF'
Usage:
  harness-runner.sh --workspace PATH [options]

Options:
  --mode MODE              standard | long-job | simplified-final-review | review-only
  --stage STAGE            checkpoint | final
  --request TEXT           original user request, used when 00-request.md is missing
  --request-file PATH      file containing the original user request
  --agent-cmd COMMAND      shell command to run one agent continuation cycle
  --max-cycles N           maximum agent continuation cycles (default: 3)
  --sleep SECONDS          delay between cycles (default: 0)
  --cwd PATH               working directory exported as HARNESS_CWD (default: current dir)

Environment exported to --agent-cmd:
  HARNESS_WORKSPACE        handoff workspace path
  HARNESS_MODE             selected delivery mode
  HARNESS_STAGE            checkpoint or final
  HARNESS_PROMPT           generated continuation prompt path
  HARNESS_CWD              target working directory
  HARNESS_GATE_OUTPUT      latest gate output path

Example:
  harness-runner.sh \
    --workspace .agent-harness/my-task \
    --mode long-job \
    --stage final \
    --agent-cmd 'codex exec --cd "$HARNESS_CWD" "$(cat "$HARNESS_PROMPT")"' \
    --max-cycles 12
EOF
}

workspace=""
mode="long-job"
stage="final"
request_text=""
request_file=""
agent_cmd=""
max_cycles=3
sleep_seconds=0
target_cwd="$(pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace)
      workspace="${2:-}"
      shift 2
      ;;
    --mode)
      mode="${2:-}"
      shift 2
      ;;
    --stage)
      stage="${2:-}"
      shift 2
      ;;
    --request)
      request_text="${2:-}"
      shift 2
      ;;
    --request-file)
      request_file="${2:-}"
      shift 2
      ;;
    --agent-cmd)
      agent_cmd="${2:-}"
      shift 2
      ;;
    --max-cycles)
      max_cycles="${2:-}"
      shift 2
      ;;
    --sleep)
      sleep_seconds="${2:-}"
      shift 2
      ;;
    --cwd)
      target_cwd="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$workspace" ]]; then
  echo "Missing --workspace PATH" >&2
  usage >&2
  exit 2
fi

case "$mode" in
  standard|long-job|simplified-final-review|review-only) ;;
  *)
    echo "Invalid --mode: $mode" >&2
    exit 2
    ;;
esac

case "$stage" in
  checkpoint|final) ;;
  *)
    echo "Invalid --stage: $stage" >&2
    exit 2
    ;;
esac

if ! [[ "$max_cycles" =~ ^[0-9]+$ ]]; then
  echo "Invalid --max-cycles: $max_cycles" >&2
  exit 2
fi

if ! [[ "$sleep_seconds" =~ ^[0-9]+$ ]]; then
  echo "Invalid --sleep: $sleep_seconds" >&2
  exit 2
fi

if [[ -n "$request_file" ]]; then
  if [[ ! -f "$request_file" ]]; then
    echo "Request file does not exist: $request_file" >&2
    exit 2
  fi
  request_text="$(<"$request_file")"
fi

mkdir -p "$workspace"

workspace="$(cd "$workspace" && pwd)"
target_cwd="$(cd "$target_cwd" && pwd)"
prompt_path="${workspace}/runner-next-prompt.md"
gate_output_path="${workspace}/runner-gate-output.txt"
log_path="${workspace}/runner.log"

timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

log() {
  printf '[%s] %s\n' "$(timestamp)" "$*" | tee -a "$log_path"
}

write_prompt() {
  local cycle="$1"
  local gate_status="$2"

  {
    echo "# Agent Harness Continuation Prompt"
    echo
    echo "You are continuing an agent-harness run. Do not answer the user directly until the gate passes."
    echo
    echo "## Current Runner State"
    echo "- Handoff workspace: \`${workspace}\`"
    echo "- Working directory: \`${target_cwd}\`"
    echo "- Delivery mode: \`${mode}\`"
    echo "- Target stage: \`${stage}\`"
    echo "- Cycle: ${cycle}"
    echo "- Gate status: ${gate_status}"
    echo
    if [[ -n "$request_text" ]]; then
      echo "## Original Request"
      echo
      echo '```text'
      printf '%s\n' "$request_text"
      echo '```'
      echo
    fi
    echo "## Latest Gate Output"
    echo
    echo '```text'
    if [[ -s "$gate_output_path" ]]; then
      sed -n '1,160p' "$gate_output_path"
    else
      echo "No gate output captured yet."
    fi
    echo '```'
    echo
    echo "## Required Behavior"
    echo "- Read the workspace artifacts that already exist."
    echo "- If \`00-request.md\` is missing, create it from the original request and current constraints."
    echo "- Continue from the latest completed artifact instead of restarting the whole task."
    echo "- Write missing artifacts in order: \`10-product-spec.md\`, \`20-evaluation-rubric.md\`, active contract, \`05-self-supervision.md\` when in long-job mode, \`30-generation-report.md\`, \`40-evaluation-report.md\`, checkpoint when required, and \`50-final-summary.md\` for final stage."
    echo "- Run or record appropriate verification before writing \`40-evaluation-report.md\`."
    echo "- \`40-evaluation-report.md\` must include a standalone or labeled \`PASS\` or \`FAIL\` decision."
    echo "- In product-delivery modes, final delivery requires \`PASS\` and an active contract status of \`AGREED\` or \`COORDINATOR-ARBITRATED\`."
    echo "- If blocked, mark the active contract \`BLOCKED\`, write \`45-checkpoint.md\` when in long-job mode, and ask only the smallest necessary user question."
    echo "- Before final response, run the gate again or leave the workspace ready for the runner to run it."
  } > "$prompt_path"
}

run_gate() {
  if "$gate_script" --workspace "$workspace" --mode "$mode" --stage "$stage" >"$gate_output_path" 2>&1; then
    cat "$gate_output_path"
    return 0
  fi
  cat "$gate_output_path"
  return 1
}

if run_gate; then
  log "gate already passed"
  exit 0
fi

if [[ "$max_cycles" -eq 0 || -z "$agent_cmd" ]]; then
  write_prompt 0 "FAILED"
  log "gate failed; wrote continuation prompt: $prompt_path"
  echo "Continuation prompt: $prompt_path"
  exit 1
fi

cycle=1
while [[ "$cycle" -le "$max_cycles" ]]; do
  write_prompt "$cycle" "FAILED"
  log "cycle ${cycle}/${max_cycles}: running agent command"

  export HARNESS_WORKSPACE="$workspace"
  export HARNESS_MODE="$mode"
  export HARNESS_STAGE="$stage"
  export HARNESS_PROMPT="$prompt_path"
  export HARNESS_CWD="$target_cwd"
  export HARNESS_GATE_OUTPUT="$gate_output_path"

  (
    cd "$target_cwd"
    bash -lc "$agent_cmd"
  ) 2>&1 | tee -a "$log_path"

  if run_gate; then
    log "gate passed after cycle ${cycle}"
    exit 0
  fi

  if [[ "$cycle" -lt "$max_cycles" && "$sleep_seconds" -gt 0 ]]; then
    sleep "$sleep_seconds"
  fi
  cycle=$((cycle + 1))
done

write_prompt "$max_cycles" "FAILED"
log "gate still failed after ${max_cycles} cycle(s); continuation prompt: $prompt_path"
echo "Continuation prompt: $prompt_path"
exit 1
