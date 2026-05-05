# Agent Harness Skill: Put Model Capability Inside an Evolving Work System

Agent Harness is a platform-neutral skill for structured AI collaboration. It is inspired by practical harness engineering patterns, but it is not a copy of any single article or implementation. This repository turns those ideas into a portable, installable, auditable work protocol.

One-sentence summary:

**With the same model and the same request, outcomes often differ less because of raw intelligence and more because of the system wrapped around that intelligence.**

This skill changes AI work from "let one agent run end to end" into a process with role separation, contracts, verification, and iteration.

## What Problem Does It Solve?

Many AI tasks fail not because the model is incapable, but because the workflow around the model is too loose:

- A one-line request is under-scoped by the model.
- Upstream planning becomes too specific, so a wrong technical assumption cascades downstream.
- The generator reviews its own work and becomes too lenient.
- Subjective quality is never turned into a concrete feedback signal.
- Verification stops at "looks done" instead of running, clicking, reproducing, or inspecting logs.
- Long tasks accumulate context weight until the model loses state or finishes prematurely.
- Harness components pile up without being tested for whether they still matter.

Agent Harness turns these failure modes into roles, files, and protocols.

## Core Roles

The system has three isolated role passes inside one agent:

- **Planner**: expands a user request into a high-level product/task spec.
- **Generator**: creates the actual code, document, design, or other output.
- **Evaluator**: acts as an independent judge and verifies whether the result meets the bar.

There is also one host role that is not counted as one of the three role passes:

- **Coordinator**: orchestrates the workflow, passes files, applies system and repository constraints, arbitrates disputes, and decides whether to iterate or finish.

The point is not to make several agents all write answers. If every role is generating, you only have multiple writers. Agent Harness creates checks and balances: planning, generation, and evaluation stay separate.

## Design Principles

### 1. Upstream Planning Should Be Restrained

Planner answers what should exist, not every detail of how it should be built.

It defines outcome, target user, scope, non-goals, constraints, risks, and acceptance criteria. Unless a constraint requires it, Planner avoids fragile implementation mandates.

This prevents error cascades: a confident but wrong upstream technical decision can distort everything that follows.

### 2. Generation and Evaluation Must Be Separated

Generator can self-check, but self-checks are preliminary. The final quality gate belongs to an independent Evaluator.

This is the core invariant. Teaching the generator to become a truly harsh critic of itself is difficult. Making a separate evaluator stricter is easier to tune and easier to inspect.

### 3. Subjective Quality Needs Concrete Scoring Signals

Evaluator starts with four baseline dimensions:

- **Design quality**: color, typography, layout, hierarchy, and interaction patterns form a coherent whole.
- **Originality**: the output contains task-specific decisions instead of generic templates or obvious AI tropes.
- **Craft**: technical execution, consistency, contrast, maintainability, and attention to detail.
- **Functionality**: users can complete the intended core tasks.

Weights should reflect model weak spots. For product and design work, design quality and originality often matter more because models easily produce polished but generic output. For engineering work, add dimensions such as correctness, safety, observability, rollback, and validation.

### 4. Negotiate the Contract Before Each Build Cycle

Planner deliberately keeps the product spec high-level. Generator and Evaluator bridge the gap by negotiating `25-iteration-contract.md` before each build cycle.

The contract translates high-level intent into testable work:

- cycle goal
- concrete deliverables
- exact acceptance criteria
- verification method
- out-of-scope items
- file/artifact ownership
- stop condition
- negotiation log

By default, one cycle should focus on one feature, one user-visible flow, or one testable vertical slice. Generator proposes the scope. Evaluator adds stricter criteria. They continue file-based handoffs until Evaluator marks the contract `AGREED`.

The value is simple: do not wait until after implementation to discover that everyone had a different definition of done.

### 5. The Evaluator Must Be Calibrated

An independent Evaluator is not automatically strict. It can still be too forgiving, miss bugs, or be fooled by surface-level completeness.

Use a calibration loop:

1. Add a few excellent, acceptable, and failing examples.
2. Break each scoring dimension into observable signals.
3. State penalties for generic output, unverifiable claims, missing core flows, and obvious AI-looking shortcuts.
4. Require score explanations and evidence.
5. Read evaluation logs and find mismatches with human judgment.
6. Update the rubric, prompt, weights, or few-shot examples.
7. Rerun the same case and inspect the new log.

Evaluator is not a one-prompt component. It is itself an artifact that needs iteration.

### 6. Prefer File Handoffs Over Long Shared Chat

Recommended artifacts:

```text
00-request.md
10-product-spec.md
20-evaluation-rubric.md
25-iteration-contract.md
25-final-review-contract.md
30-generation-report.md
35-context-transition.md
40-evaluation-report.md
50-final-summary.md
```

Files are a better coordination substrate than one long shared transcript: they are concise, traceable, reviewable, and less likely to pollute each role's context.

### 7. Context Reset Means a Fresh Instance, Not Just Compression

When Generator starts losing state, finishing too early, or repeatedly failing during a long task, do not only compress the old conversation and continue with the same instance.

Start a fresh Generator when possible and hand it `35-context-transition.md`:

- current goal
- completed work
- changed files/artifacts
- active contract
- failing checks
- next steps
- constraints that still matter

This gives the model a clean board instead of forcing it to carry an increasingly heavy history.

### 8. Harness Components Must Be Removable

Every component encodes an assumption:

- Planner exists because the model may under-scope or misread the request.
- Evaluator exists because generator self-review is unreliable.
- Iteration contract exists because high-level specs need a bridge to testable implementation.
- Context reset exists because long contexts can damage coherence.

Those assumptions can expire as models improve. Do not remove half the harness at once. Remove, simplify, or move one component at a time and compare quality, defects, cost, latency, and completeness.

Keep the simplification only if quality does not regress. Restore the component if quality drops or the failure source is unclear.

## Full Mode and Simplified Mode

### Full Cycle Mode

Use this for complex, subjective, high-risk, or scope-drifting tasks.

Workflow:

1. Planner writes `10-product-spec.md`.
2. Evaluator writes `20-evaluation-rubric.md`.
3. Generator and Evaluator negotiate `25-iteration-contract.md`.
4. Generator builds and writes `30-generation-report.md`.
5. Evaluator independently verifies and writes `40-evaluation-report.md`.
6. Coordinator decides whether to start another cycle or finish.

### Simplified Final Review Mode

Use this only after Component Audit shows that the current model/runtime can sustain longer coherent generation.

Workflow:

1. Keep Planner.
2. Freeze `25-final-review-contract.md` before continuous generation.
3. Let Generator work across a larger scope.
4. Move Evaluator to one strict final review.

This mode can remove per-cycle structure. It must not remove Evaluator. The closer the task is to the model's capability boundary, the more valuable independent evaluation becomes.

## Install

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

Treat `SKILL.md` as the canonical method document and map Planner, Generator, Evaluator, Coordinator, and artifact files to your runtime's tools. The default mode is one agent running isolated sequential role passes.

## Relationship to the Reference Ideas

This repository intentionally absorbs several important harness engineering ideas: restrained planning, generation/evaluation separation, strict evaluator design, iteration contracts, file handoffs, context reset, evaluator calibration, component ablation, and workflow simplification as models improve.

It also makes its own abstractions:

- It is packaged as a platform-neutral skill rather than a runtime-specific harness.
- It explicitly separates Planner, Generator, and Evaluator role passes from the Coordinator.
- It names reusable handoff artifacts.
- It supports both full cycle mode and final review mode.
- It provides bilingual documentation for wider sharing.

This is not a copied prompt. It is a portable AI work protocol.
