#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  harness-gate.sh --workspace PATH [--mode MODE] [--stage STAGE]

Modes:
  standard                  requires one complete contract cycle
  long-job                  requires one complete contract cycle plus checkpoint
  simplified-final-review   requires final-review contract instead of iteration contract
  review-only               requires review artifacts only

Stages:
  checkpoint                validate artifacts needed before continuing a long job
  final                     validate artifacts needed before user-facing final response

Examples:
  harness-gate.sh --workspace /tmp/agent-harness-demo --mode standard --stage final
  harness-gate.sh --workspace .agent-harness/my-task --mode long-job --stage checkpoint
EOF
}

workspace=""
mode="standard"
stage="final"

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

if [[ ! -d "$workspace" ]]; then
  echo "Workspace does not exist: $workspace" >&2
  exit 1
fi

case "$stage" in
  checkpoint|final) ;;
  *)
    echo "Invalid --stage: $stage" >&2
    exit 2
    ;;
esac

required=()

case "$mode" in
  standard)
    required=(
      "00-request.md"
      "10-product-spec.md"
      "20-evaluation-rubric.md"
      "25-iteration-contract.md"
      "30-generation-report.md"
      "40-evaluation-report.md"
    )
    ;;
  long-job)
    required=(
      "00-request.md"
      "05-self-supervision.md"
      "10-product-spec.md"
      "20-evaluation-rubric.md"
      "25-iteration-contract.md"
      "30-generation-report.md"
      "40-evaluation-report.md"
      "45-checkpoint.md"
    )
    ;;
  simplified-final-review)
    required=(
      "00-request.md"
      "10-product-spec.md"
      "20-evaluation-rubric.md"
      "25-final-review-contract.md"
      "30-generation-report.md"
      "40-evaluation-report.md"
    )
    ;;
  review-only)
    required=(
      "00-request.md"
      "10-product-spec.md"
      "20-evaluation-rubric.md"
      "40-evaluation-report.md"
    )
    ;;
  *)
    echo "Invalid --mode: $mode" >&2
    exit 2
    ;;
esac

if [[ "$stage" == "final" ]]; then
  required+=("50-final-summary.md")
fi

missing=()
empty=()

for artifact in "${required[@]}"; do
  path="${workspace%/}/${artifact}"
  if [[ ! -e "$path" ]]; then
    missing+=("$artifact")
  elif [[ ! -s "$path" ]]; then
    empty+=("$artifact")
  fi
done

invalid=()

extract_status() {
  local file="$1"
  local allowed="$2"
  awk -v allowed="$allowed" '
    function clean(raw) {
      line = raw
      sub(/^[[:space:]#>*-]+/, "", line)
      sub(/[[:space:]]+$/, "", line)
      gsub(/[`*_]/, "", line)
      sub(/^[[:space:]]+/, "", line)
      sub(/[[:space:]]+$/, "", line)
      return line
    }
    {
      line = clean($0)
      if (line ~ "^(" allowed ")$") {
        status = line
      }
      if (line ~ "^(Decision|Result|Verdict|Status|Pass[[:space:]]*/[[:space:]]*Fail|Agreement Status|Contract Status):[[:space:]]*(" allowed ")$") {
        sub(/^.*:[[:space:]]*/, "", line)
        status = line
      }
    }
    END {
      if (status != "") {
        print status
      }
    }
  ' "$file"
}

evaluation_report="${workspace%/}/40-evaluation-report.md"
if [[ -s "$evaluation_report" ]]; then
  evaluation_status="$(extract_status "$evaluation_report" 'PASS|FAIL')"
  if [[ -z "$evaluation_status" ]]; then
    invalid+=("40-evaluation-report.md must include a standalone or labeled PASS or FAIL decision")
  elif [[ "$stage" == "final" && "$mode" != "review-only" && "$evaluation_status" != "PASS" ]]; then
    invalid+=("final gate requires 40-evaluation-report.md decision PASS")
  fi
fi

if [[ "$mode" != "review-only" ]]; then
  contract="${workspace%/}/25-iteration-contract.md"
  if [[ "$mode" == "simplified-final-review" ]]; then
    contract="${workspace%/}/25-final-review-contract.md"
  fi
  if [[ -s "$contract" ]]; then
    contract_status="$(extract_status "$contract" 'AGREED|COORDINATOR-ARBITRATED|BLOCKED')"
    if [[ -z "$contract_status" ]]; then
      invalid+=("$(basename "$contract") must include a standalone or labeled status: AGREED, COORDINATOR-ARBITRATED, or BLOCKED")
    elif [[ "$stage" == "final" ]]; then
      if [[ "$contract_status" == "BLOCKED" ]]; then
        invalid+=("final gate cannot pass while $(basename "$contract") status is BLOCKED")
      elif [[ "$contract_status" != "AGREED" && "$contract_status" != "COORDINATOR-ARBITRATED" ]]; then
        invalid+=("final gate requires $(basename "$contract") status AGREED or COORDINATOR-ARBITRATED")
      fi
    fi
  fi
fi

if (( ${#missing[@]} || ${#empty[@]} || ${#invalid[@]} )); then
  echo "Agent Harness gate FAILED"
  echo "Workspace: $workspace"
  echo "Mode: $mode"
  echo "Stage: $stage"
  if (( ${#missing[@]} )); then
    echo
    echo "Missing artifacts:"
    printf '  - %s\n' "${missing[@]}"
  fi
  if (( ${#empty[@]} )); then
    echo
    echo "Empty artifacts:"
    printf '  - %s\n' "${empty[@]}"
  fi
  if (( ${#invalid[@]} )); then
    echo
    echo "Invalid artifacts:"
    printf '  - %s\n' "${invalid[@]}"
  fi
  exit 1
fi

echo "Agent Harness gate passed"
echo "Workspace: $workspace"
echo "Mode: $mode"
echo "Stage: $stage"
