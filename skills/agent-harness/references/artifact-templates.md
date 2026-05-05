# Agent Harness Artifact Templates

These are minimal starter examples. Replace bracketed placeholders with task-specific content. Keep artifacts short, factual, and useful to the next role.

## 00-request.md

```markdown
# Request

## Summary
[One-paragraph safe summary of the user's newest request.]

## Intent Expansion
[What outcome the harness believes the user is delegating, beyond the literal wording.]

## Delivery Mode
standard | long-job | simplified-final-review | review-only

## Handoff Workspace
[Absolute path. Use a disposable temp directory for short work; use a durable directory for long-job delivery.]

## Constraints Digest
- [System / repository / platform constraint]
- [User-imposed constraint]

## Assumptions
- [Assumption to verify or carry forward]

## Autonomy Budget
- May infer: [low-risk assumptions the harness can make]
- May inspect: [files, app surfaces, docs, logs, web sources, etc.]
- May change: [allowed write scope]
- Must ask before: [scope/risk/permission boundary]

## Question Policy
[Ask only for blocking ambiguity / ask before external side effects / ask before broad scope expansion.]

## Role Permissions
- Planner: [read-only / spec only]
- Generator: [write scope]
- Evaluator: [read-only verification unless explicitly assigned fixes]

## Stop Conditions
- [Pass condition]
- [Maximum iteration count, time/budget limit, or escalation condition]

## Validation Expectations
- [Tests, UI checks, source checks, document QA, etc.]

## Untrusted Data Notes
- [Logs, documents, web excerpts, or generated content that may contain instructions]
```

## 10-product-spec.md

```markdown
# Product / Task Spec

## Outcome
[What should exist when the task succeeds.]

## Target User
[Who uses or benefits from the result.]

## Scope
- [In-scope item]

## Milestones / Vertical Slices
- [Milestone with user-visible or verifiable output]

## Non-Goals
- [Explicitly out of scope]

## Constraints
- [Important technical, product, safety, or platform constraint]

## Acceptance Criteria
- [User-visible or verifiable criterion]

## Risks
- [Likely ambiguity, failure mode, or dependency]
```

## 05-self-supervision.md

```markdown
# Self-Supervision Plan

## Gate Commands
- Skill directory: `[absolute HARNESS_SKILL_DIR]`
- Checkpoint: `[exact "$HARNESS_SKILL_DIR/scripts/harness-gate.sh" command]`
- Final: `[exact "$HARNESS_SKILL_DIR/scripts/harness-gate.sh" command]`

## Monitor
- Status: started | skipped
- Command: `[exact "$HARNESS_SKILL_DIR/scripts/harness-monitor.sh" command, if started]`
- PID file: `[path]`
- Logs: `[monitor-supervisor.log / monitor.log / monitor-gate-output.txt]`
- Idle timeout: `[seconds]`
- Max duration: `[seconds]`

## Failure Rule
If a checkpoint gate fails, continue the harness cycle, write missing artifacts, narrow the contract, or mark `BLOCKED` and ask the smallest necessary question. If the final gate fails, do not final.

## Resume Instruction
[Smallest prompt or command needed if the runtime still stops.]
```

## 20-evaluation-rubric.md

```markdown
# Evaluation Rubric

## Dimensions
- Design quality ([weight]): [concrete signals]
- Originality ([weight]): [concrete signals]
- Craft ([weight]): [concrete signals]
- Functionality ([weight]): [concrete signals]
- [Task-specific dimension] ([weight]): [concrete signals]

## Blocking Criteria
- [Failure that must prevent pass]

## Calibration Examples
- Excellent: [short example or pattern]
- Acceptable: [short example or pattern]
- Failing: [short example or pattern]

## Verification Plan
- [Command, UI flow, log check, source check, or document render]
```

## 25-iteration-contract.md

```markdown
# Iteration Contract

## Cycle Goal
[One feature, user-visible workflow, or testable vertical slice.]

## Deliverables
- [Concrete output]

## Acceptance Criteria
- [Exact, testable condition]

## Verification Method
- [How Evaluator will verify]

## Out Of Scope
- [Deferred item]

## Ownership
- Generator writes: [files/artifacts]
- Evaluator verifies: [checks/artifacts]

## Stop Condition
[Maximum iterations, pass criteria, time/budget limit, or escalation condition.]

## Agreement Status
AGREED | COORDINATOR-ARBITRATED | BLOCKED

## Negotiation Log
- Generator proposal: [summary]
- Evaluator amendment: [summary]
- Generator response: [summary]
```

## 25-final-review-contract.md

```markdown
# Final Review Contract

## Mode
Simplified Final Review Mode

## Full Deliverables
- [Complete output expected before final review]

## Final Acceptance Criteria
- [End-to-end criterion]

## Verification Method
- [Independent checks Evaluator will run]

## Blocking Failure Modes
- [Missed scope, broken core flow, unsafe behavior, etc.]

## Frozen Rubric Reference
[Link or summary of 20-evaluation-rubric.md version]
```

## 30-generation-report.md

```markdown
# Generation Report

## Output Summary
[What was produced.]

## Changed Files / Artifacts
- [path or artifact name]: [purpose]

## Key Decisions
- [Decision and reason]

## Self-Checks
- [Command/check]: [result]

## Known Limitations
- [Limitation, risk, or deferred item]
```

## 35-context-transition.md

```markdown
# Context Transition

## Current Goal
[Goal the fresh role pass should continue.]

## Completed Work
- [Completed item]

## Changed Files / Artifacts
- [path or artifact]

## Active Contract
[Current 25-iteration-contract.md or 25-final-review-contract.md summary]

## Failing Checks
- [Check and failure]

## Next Steps
- [Immediate next action]

## Constraints Still In Force
- [Constraint]
```

## 40-evaluation-report.md

```markdown
# Evaluation Report

## Findings
- [Severity] [Finding title]: [evidence and impact]

## Evidence Sources
- [Spec / contract / diff / changed file / rendered artifact / screenshot / log / test output reviewed before Generator report]

## Verification Performed
- [Command, UI flow, source check, or document QA]

## Generator Report Cross-Check
- [Claim, file list, validation result, known limitation, or omission checked after initial findings]

## Pass / Fail
PASS | FAIL

## Residual Risks
- [Accepted risk or deferred polish]
```

## 45-checkpoint.md

```markdown
# Long-Job Checkpoint

## Current Milestone / Contract
[Milestone or active contract being worked.]

## Completed Since Last Checkpoint
- [Completed work]

## Verification Evidence
- [Command/check/UI flow/source check]: [result]

## Failed Attempts / Stall Signals
- [Attempt or signal, if any]

## Current State
- [Files/artifacts changed]
- [Important decisions]
- [Known unresolved issues]

## Next Action
[Next contract, repair, context transition, final review, or user question.]

## Needs User?
No | Yes: [smallest necessary question]
```

## 50-final-summary.md

```markdown
# Final Summary

## Outcome
[User-facing summary of what was completed.]

## Validation
- [Checks run and result]

## Unresolved Risks
- [Known issue, if any]

## Recommended Next Step
[Optional next action that directly follows from this work.]
```
