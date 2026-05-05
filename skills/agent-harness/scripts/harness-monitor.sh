#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
gate_script="${script_dir}/harness-gate.sh"
runner_script="${script_dir}/harness-runner.sh"

usage() {
  cat <<'EOF'
Usage:
  harness-monitor.sh --workspace PATH [options]

Options:
  --mode MODE              standard | long-job | simplified-final-review | review-only
  --stage STAGE            checkpoint | final
  --interval SECONDS       polling interval (default: 30)
  --idle-timeout SECONDS   fail if workspace is idle this long while gate fails (default: 900)
  --max-seconds SECONDS    maximum monitor duration, 0 means no limit (default: 21600)
  --request TEXT           original user request for continuation prompt
  --request-file PATH      file containing the original user request
  --cwd PATH               target working directory for generated prompts

Behavior:
  Acts as a self-started watchdog for the active Coordinator session.
  It does not control the interactive agent process. It repeatedly runs the
  artifact gate. If the gate passes, monitor exits 0.
  If the workspace stops changing while the gate still fails, monitor writes
  runner-next-prompt.md and exits 1 with the missing artifact report.

Example:
  harness-monitor.sh \
    --workspace .agent-harness/my-task \
    --mode long-job \
    --stage final \
    --interval 30 \
    --idle-timeout 600
EOF
}

workspace=""
mode="long-job"
stage="final"
interval=30
idle_timeout=900
max_seconds=21600
request_text=""
request_file=""
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
    --interval)
      interval="${2:-}"
      shift 2
      ;;
    --idle-timeout)
      idle_timeout="${2:-}"
      shift 2
      ;;
    --max-seconds)
      max_seconds="${2:-}"
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

for number in "$interval" "$idle_timeout" "$max_seconds"; do
  if ! [[ "$number" =~ ^[0-9]+$ ]]; then
    echo "Interval, idle timeout, and max seconds must be non-negative integers" >&2
    exit 2
  fi
done

if [[ "$interval" -eq 0 ]]; then
  echo "--interval must be greater than 0" >&2
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
gate_output_path="${workspace}/monitor-gate-output.txt"
log_path="${workspace}/monitor.log"

timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

log() {
  printf '[%s] %s\n' "$(timestamp)" "$*" | tee -a "$log_path"
}

latest_mtime() {
  local latest="0"
  local value
  while IFS= read -r -d '' file; do
    case "$(uname -s)" in
      Darwin|FreeBSD)
        value="$(stat -f '%m' "$file" 2>/dev/null || echo 0)"
        ;;
      *)
        value="$(stat -c '%Y' "$file" 2>/dev/null || echo 0)"
        ;;
    esac
    if [[ "$value" =~ ^[0-9]+$ ]] && (( value > latest )); then
      latest="$value"
    fi
  done < <(
    find "$workspace" -type f \
      ! -name 'monitor.log' \
      ! -name 'monitor-*.log' \
      ! -name 'monitor-gate-output.txt' \
      ! -name 'monitor.pid' \
      ! -name 'monitor-*.pid' \
      ! -name 'runner.log' \
      ! -name 'runner-*.log' \
      ! -name 'runner-gate-output.txt' \
      ! -name 'runner-next-prompt.md' \
      -print0 2>/dev/null
  )
  echo "$latest"
}

write_continuation_prompt() {
  local temp_output
  temp_output="$(mktemp "${TMPDIR:-/tmp}/harness-monitor-runner.XXXXXX")"
  local args=(
    --workspace "$workspace"
    --mode "$mode"
    --stage "$stage"
    --max-cycles 0
    --cwd "$target_cwd"
  )
  if [[ -n "$request_text" ]]; then
    args+=(--request "$request_text")
  fi
  "$runner_script" "${args[@]}" >"$temp_output" 2>&1 || true
  cat "$temp_output" | tee -a "$log_path"
  rm -f "$temp_output"
}

run_gate() {
  if "$gate_script" --workspace "$workspace" --mode "$mode" --stage "$stage" >"$gate_output_path" 2>&1; then
    cat "$gate_output_path" | tee -a "$log_path"
    return 0
  fi
  cat "$gate_output_path" | tee -a "$log_path"
  return 1
}

start_epoch="$(date '+%s')"
last_change_epoch="$start_epoch"
last_seen_mtime="$(latest_mtime)"

log "monitor started: workspace=$workspace mode=$mode stage=$stage interval=${interval}s idle-timeout=${idle_timeout}s max=${max_seconds}s"

while true; do
  current_epoch="$(date '+%s')"
  current_mtime="$(latest_mtime)"

  if [[ "$current_mtime" != "$last_seen_mtime" ]]; then
    last_seen_mtime="$current_mtime"
    last_change_epoch="$current_epoch"
    log "workspace changed"
  fi

  if run_gate; then
    log "gate passed; monitor complete"
    exit 0
  fi

  idle_for=$((current_epoch - last_change_epoch))
  elapsed=$((current_epoch - start_epoch))

  if [[ "$idle_timeout" -gt 0 && "$idle_for" -ge "$idle_timeout" ]]; then
    log "workspace idle for ${idle_for}s while gate still fails"
    write_continuation_prompt
    exit 1
  fi

  if [[ "$max_seconds" -gt 0 && "$elapsed" -ge "$max_seconds" ]]; then
    log "max monitor duration reached while gate still fails"
    write_continuation_prompt
    exit 1
  fi

  sleep "$interval"
done
