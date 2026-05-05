# Agent Harness Skill

Language: [English](README.en.md) | [中文](README.zh-CN.md)

![Agent Harness cover](assets/cover-agent-harness.png)

Agent Harness is a platform-neutral AI collaboration skill. It distills practical harness engineering ideas into an installable protocol built around Planner, Generator, Evaluator, and Coordinator roles.

核心判断：

**同一个模型、同一句需求，最终质量往往不只取决于模型本身，而取决于你在模型周围搭建了什么系统。**

Core thesis:

**With the same model and request, output quality often depends less on raw model capability and more on the system wrapped around it.**

## What Is Inside

- `skills/agent-harness/SKILL.md`: canonical portable skill for Claude Code, Codex, and other agent runtimes.
- `skills/agent-harness/SKILL.zh-CN.md`: Chinese reading version.
- `skills/agent-harness/references/bootstrap-checklist.md`: coordinator startup checklist.
- `skills/agent-harness/references/artifact-templates.md`: starter templates for the handoff artifacts.
- `README.zh-CN.md`: full Chinese explanation.
- `README.en.md`: full English explanation.
- `docs/ARTICLE.zh-CN.md`: Chinese public article draft.
- `docs/ARTICLE.en.md`: English public article draft.
- `assets/cover-agent-harness.png`: cover image for articles and sharing.
- `MAINTENANCE.md`: long-term maintenance workflow.
- `scripts/sync-local.sh`: sync the canonical skill into local Claude/Codex skill directories.

## Core Pattern

Agent Harness is not "ask three agents to all write answers."

It is a system of role separation:

- Planner expands the user's request into a restrained high-level spec.
- Generator builds only against an agreed contract.
- Evaluator independently verifies quality and catches failures.
- Coordinator orchestrates handoffs, constraints, disputes, iteration, and final synthesis.

The method emphasizes:

- restrained upstream planning
- generation/evaluation separation
- iteration contracts
- calibrated evaluators
- file-based handoffs
- context reset through structured transition artifacts
- component audit and ablation
- simplified final review mode when stronger models make per-cycle structure unnecessary

## Quick Install

Claude Code:

```bash
mkdir -p ~/.claude/skills
cp -R skills/agent-harness ~/.claude/skills/agent-harness
```

Codex:

```bash
mkdir -p ~/.codex/skills
cp -R skills/agent-harness ~/.codex/skills/agent-harness
```

Other runtimes:

Use `SKILL.md` as the canonical method document and map the role prompts and artifacts to the tools your runtime supports.

## Local Maintenance

This repository is meant to be the canonical long-term project. Update the skill here first, then sync local installs:

```bash
scripts/sync-local.sh
```

Private source material and temporary review artifacts should live under `private/`, which is ignored by git.

## Relationship to Harness Engineering

This repository is strongly informed by harness engineering practice, especially the ideas of restrained planning, strict external evaluation, contract-driven iteration, evaluator calibration, context reset, and component-by-component simplification.

It is not a transcript or a copied implementation. It is a rewritten, platform-neutral protocol meant to be installed, adapted, and audited across assistant runtimes.
