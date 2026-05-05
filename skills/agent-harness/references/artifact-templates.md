# Agent Harness Artifact Templates

These are minimal starter examples. Replace bracketed placeholders with task-specific content. Keep artifacts short, factual, and useful to the next role.

## 00-request.md

```markdown
# Request

## Summary
[One-paragraph safe summary of the user's newest request.]

## Constraints Digest
- [System / repository / platform constraint]
- [User-imposed constraint]

## Assumptions
- [Assumption to verify or carry forward]

## Role Permissions
- Planner: [read-only / spec only]
- Generator: [write scope]
- Evaluator: [read-only verification unless explicitly assigned fixes]

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

## Non-Goals
- [Explicitly out of scope]

## Constraints
- [Important technical, product, safety, or platform constraint]

## Acceptance Criteria
- [User-visible or verifiable criterion]

## Risks
- [Likely ambiguity, failure mode, or dependency]
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
[Goal the fresh role instance should continue.]

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

## Verification Performed
- [Command, UI flow, source check, or document QA]

## Pass / Fail
PASS | FAIL

## Residual Risks
- [Accepted risk or deferred polish]
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

