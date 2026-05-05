# Agent Harness Bootstrap Checklist

Use this checklist when the runtime supports todos, task lists, or explicit progress tracking. Adapt wording to the current task, but preserve the order unless the user imposes a different constraint.

```text
[ ] Confirm the user explicitly requested agent-harness, long-job/high-quality delivery, single-agent harness mode, or QA/improvement of the harness itself.
[ ] Treat activation as delegation of an outcome, not literal minimum execution.
[ ] Choose delivery mode: standard, long-job, simplified final review, or review-only.
[ ] Choose outcome class: proposal-only, first implementation slice, or full delivery.
[ ] For codebase/product repair, default to first implementation slice unless the user explicitly requested proposal-only or no file edits.
[ ] For long-job delivery, load references/long-job-checklist.md.
[ ] If shell scripts will be used, resolve the absolute skill directory into HARNESS_SKILL_DIR before running them.
[ ] Create a private handoff workspace. Use a disposable temp workspace for short work; use a durable workspace for long-job delivery.
[ ] Write 00-request.md with request summary, intent expansion, delivery mode, outcome class, handoff workspace path, constraints, assumptions, autonomy budget, question policy, role permissions, stop conditions, and validation expectations.
[ ] Run Planner and capture 10-product-spec.md.
[ ] For long-job delivery, ensure 10-product-spec.md includes milestones or vertical slices before build work starts.
[ ] Run or prepare Evaluator and capture 20-evaluation-rubric.md.
[ ] Run Generator to draft 25-iteration-contract.md, or create 25-final-review-contract.md in simplified mode.
[ ] Let Evaluator amend acceptance criteria and verification until the active contract is AGREED, or record why Coordinator arbitrated.
[ ] If outcome class is first implementation slice or full delivery, ensure the active contract includes tangible product/code/document/data changes, not only a plan.
[ ] For long-job delivery, write 05-self-supervision.md with gate commands, monitor decision, failure rule, and resume instruction.
[ ] For long-job delivery in shell-capable runtimes, start "$HARNESS_SKILL_DIR/scripts/harness-monitor.sh" from this same agent session, then health-check the PID/logs, or record why it was skipped/unavailable.
[ ] Let Generator build only the agreed scope and write 30-generation-report.md.
[ ] Let Evaluator verify direct evidence first, then read 30-generation-report.md only for cross-checking, and write 40-evaluation-report.md with findings first.
[ ] For long-job delivery, write or refresh 45-checkpoint.md after each contract cycle.
[ ] For long-job delivery, run "$HARNESS_SKILL_DIR/scripts/harness-gate.sh" --workspace "$HANDOFF_WORKSPACE" --mode long-job --stage checkpoint, or manually check equivalent artifacts.
[ ] For unattended long-job delivery, the active agent may use "$HARNESS_SKILL_DIR/scripts/harness-runner.sh" with a bounded --max-cycles and an explicit --agent-cmd.
[ ] For Claude Code-style work, confirm the active session started "$HARNESS_SKILL_DIR/scripts/harness-monitor.sh" against the same handoff workspace and verified it stayed alive, or documented why not.
[ ] Decide whether to iterate, reset context, accept residual risk, or finish.
[ ] In long-job delivery, continue to the next milestone unless a stop condition or blocking question requires the user.
[ ] Do not ask "should I implement this?" after a plan when a safe next slice is available; write the next contract and continue.
[ ] Write 50-final-summary.md.
[ ] Before responding to the user, run "$HARNESS_SKILL_DIR/scripts/harness-gate.sh" --workspace "$HANDOFF_WORKSPACE" --mode "$DELIVERY_MODE" --stage final, or manually check equivalent artifacts.
[ ] Respond to the user only after the final gate passes, unless the final response is a blocker question with the contract marked BLOCKED. Gate output alone is not a final response.
[ ] Release completed role resources and clean up disposable handoff files unless the user wants to inspect them. Preserve durable long-job checkpoints until resume evidence is no longer useful.
```

Notes:

- For large requests, repeat the contract -> generate -> evaluate segment per feature, workflow, or vertical slice.
- Explicit harness activation means the Coordinator should make reasonable assumptions and proceed; ask the user only for blockers.
- Plans and roadmaps are intermediate unless proposal-only mode is explicit.
- For long-job delivery, prefer `<repo>/.agent-harness/<task-slug>/` only when repo-local private artifacts are acceptable and ignored; otherwise use `${CODEX_HOME:-$HOME/.codex}/harness-runs/<task-slug>-<timestamp>/` or another durable user-owned directory.
- If context reset is needed, write `35-context-transition.md` before starting a fresh Generator.
- If work stalls, follow the Stall and Resume Policy in `SKILL.md` and resume from `45-checkpoint.md`.
- If simplified final review mode is used, freeze `25-final-review-contract.md` before continuous generation starts.
- Gate failure means the workflow is not done. Missing artifacts must be written, failed verification must be handled, or the active contract must be marked blocked before final response. In product-delivery modes, final delivery requires a `PASS` evaluation and a non-`BLOCKED` contract.
- Do not use the final-stage gate as a preflight before `50-final-summary.md` exists. Use a checkpoint-stage gate for preflight checks.
