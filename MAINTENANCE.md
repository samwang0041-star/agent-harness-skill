# Maintenance Guide

This repository is the canonical maintenance project for the Agent Harness skill.

## Canonical Sources

- `skills/agent-harness/SKILL.md`: canonical installable skill.
- `skills/agent-harness/SKILL.zh-CN.md`: Chinese reading version.
- `skills/agent-harness/references/`: starter templates and checklist used by the skill.
- `README.md`, `README.zh-CN.md`, `README.en.md`: public project documentation.
- `docs/ARTICLE.zh-CN.md`, `docs/ARTICLE.en.md`: shareable article drafts.
- `assets/cover-agent-harness.png`: public cover image for sharing.

## Local-Only Sources

`private/` is intentionally ignored by git.

Use it for local reference material that should not be published, such as source transcripts, drafts with sensitive notes, or temporary review artifacts.

The original source document used during this iteration lives locally at:

```text
private/source/douyin_harness_engineering_原文.docx
```

Do not commit raw source transcripts or copyrighted reference documents. Distill ideas into original notes, docs, and skill instructions instead.

## Update Workflow

1. Edit the canonical files in this repository.
2. Run the local sync script:

   ```bash
   scripts/sync-local.sh
   ```

3. Verify no secret or private source file is staged:

   ```bash
   git status --short
   rg -n "sk-|ANTHROPIC|api[_-]?key|token|password|secret" .
   ```

4. Commit and push:

   ```bash
   git add .
   git commit -m "Describe the change"
   git push
   ```

## Local Install Targets

The sync script updates:

- Claude Code: `~/.claude/skills/agent-harness`
- Codex: `~/.codex/skills/agent-harness`

Codex-specific metadata under `~/.codex/skills/agent-harness/agents/` is not managed by this repository.

