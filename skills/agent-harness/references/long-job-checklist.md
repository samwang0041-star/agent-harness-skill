# Long-Job Checklist

Use this checklist when `agent-harness` is explicitly activated for long-running, high-quality, or advanced deliverable work. Keep it task-specific and do not let the checklist become a substitute for evidence.

```text
[ ] Confirm explicit agent-harness activation and treat it as delegated outcome ownership.
[ ] Choose long-job delivery mode, or record why standard/simplified/review-only is safer.
[ ] If shell scripts will be used, resolve the absolute skill directory into HARNESS_SKILL_DIR before running them.
[ ] Create or reuse a durable handoff workspace and record its path in 00-request.md.
[ ] Write 00-request.md with intent expansion, durable handoff workspace path, autonomy budget, question policy, stop conditions, and validation expectations.
[ ] Write 10-product-spec.md with milestones or vertical slices.
[ ] Build or refresh 20-evaluation-rubric.md with task-specific blocking criteria and verification plan.
[ ] Select the next milestone or vertical slice.
[ ] Draft and agree 25-iteration-contract.md for that slice.
[ ] Write 05-self-supervision.md with exact gate commands, monitor decision, failure rule, and resume instruction before implementation starts.
[ ] If shell execution is available, start "$HARNESS_SKILL_DIR/scripts/harness-monitor.sh" from this same agent session, or record why it was skipped.
[ ] Generate only the agreed scope.
[ ] Run self-checks and write 30-generation-report.md.
[ ] Evaluate direct evidence first, then read 30-generation-report.md only for cross-checking, and write 40-evaluation-report.md.
[ ] Write or refresh 45-checkpoint.md with completed work, verification evidence, failed attempts, next action, and whether the user is needed.
[ ] Run "$HARNESS_SKILL_DIR/scripts/harness-gate.sh" --workspace "$HANDOFF_WORKSPACE" --mode long-job --stage checkpoint, or manually check the same artifacts if shell execution is unavailable.
[ ] For unattended continuation, the active agent may run "$HARNESS_SKILL_DIR/scripts/harness-runner.sh" with an appropriate --agent-cmd instead of relying on memory or chat continuity.
[ ] If the task is running in Claude Code or another interactive agent, the active session should have started "$HARNESS_SKILL_DIR/scripts/harness-monitor.sh" against the same workspace.
[ ] If blocking issues remain, narrow the next contract and iterate.
[ ] If a stall signal appears, follow the Stall and Resume Policy from SKILL.md.
[ ] If context/state is degrading, write 35-context-transition.md before starting a fresh role pass.
[ ] Continue to the next milestone unless stop condition, blocker, or user question requires a pause.
[ ] Finish with 50-final-summary.md, including validation evidence and residual risks.
[ ] Run "$HARNESS_SKILL_DIR/scripts/harness-gate.sh" --workspace "$HANDOFF_WORKSPACE" --mode long-job --stage final, or manually check the final gate before responding to the user.
[ ] Respond to the user only after the final gate passes, unless the final response is a blocker question with the contract marked BLOCKED.
```

## Default Stop Conditions

Choose task-specific stop conditions in `00-request.md`. Useful defaults:

- all agreed milestones pass evaluation
- a blocking ambiguity requires user choice
- the same substantive failure occurs twice
- verification cannot be run and the residual risk is unacceptable
- runtime/tooling is unavailable
- user-imposed time, budget, or scope limit is reached

## Checkpoint Discipline

Write `45-checkpoint.md` after each contract cycle in long-job mode. It should be short enough to resume from and concrete enough to avoid replaying the full transcript.

If interrupted, resume from the latest checkpoint and active contract, not from memory alone.

Use a durable workspace for long-job checkpoints. Prefer `<repo>/.agent-harness/<task-slug>/` only when repo-local private artifacts are acceptable and ignored; otherwise use `${CODEX_HOME:-$HOME/.codex}/harness-runs/<task-slug>-<timestamp>/` or another durable user-owned directory. Do not delete the durable checkpoint workspace until final delivery no longer needs resume evidence, or until the user asks for cleanup.

## Gate Discipline

The checkpoint and final gates are hard stops. If the gate reports a missing, empty, or invalid artifact, do not summarize success to the user. Continue the role cycle, write the missing evidence, or mark the contract blocked. The final gate requires a `PASS` evaluation and a non-`BLOCKED` contract; `FAIL` or `BLOCKED` can only be checkpoint/resume evidence or a blocker question state.

For long unattended work, the runner can be used by the active agent as the outer loop. It should be configured with a bounded `--max-cycles` and a concrete `--agent-cmd`; each cycle must leave enough artifact evidence for the next cycle to resume without reading the full transcript.

For Claude Code-style interactive work, the monitor should be started by the active session as its watchdog. It does not drive the process; it watches the handoff workspace and turns a quiet premature stop into a concrete continuation prompt.
