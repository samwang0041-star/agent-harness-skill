#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_src="${repo_root}/skills/agent-harness/"

if [[ ! -f "${skill_src}/SKILL.md" ]]; then
  echo "Missing ${skill_src}/SKILL.md" >&2
  exit 1
fi

mkdir -p "${HOME}/.claude/skills/agent-harness"
mkdir -p "${HOME}/.codex/skills/agent-harness"

rsync -a --delete --exclude 'agents/' "${skill_src}" "${HOME}/.claude/skills/agent-harness/"
rsync -a --delete --exclude 'agents/' "${skill_src}" "${HOME}/.codex/skills/agent-harness/"

echo "Synced agent-harness skill to:"
echo "  ${HOME}/.claude/skills/agent-harness"
echo "  ${HOME}/.codex/skills/agent-harness"

