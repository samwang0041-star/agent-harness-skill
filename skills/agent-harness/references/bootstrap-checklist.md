# Agent Harness Bootstrap Checklist

Use this checklist when the runtime supports todos, task lists, or explicit progress tracking. Adapt wording to the current task, but preserve the order unless the user imposes a different constraint.

```text
[ ] Confirm the user explicitly requested agent-harness, long-job/high-quality delivery, single-agent harness mode, or QA/improvement of the harness itself.
[ ] Treat activation as delegation of an outcome, not literal minimum execution.
[ ] Choose delivery mode: standard, long-job, simplified final review, or review-only.
[ ] For long-job delivery, load references/long-job-checklist.md.
[ ] Create a private handoff workspace. Use a disposable temp workspace for short work; use a durable workspace for long-job delivery.
[ ] Write 00-request.md with request summary, intent expansion, handoff workspace path, constraints, assumptions, autonomy budget, question policy, role permissions, stop conditions, and validation expectations.
[ ] Run Planner and capture 10-product-spec.md.
[ ] For long-job delivery, ensure 10-product-spec.md includes milestones or vertical slices before build work starts.
[ ] Run or prepare Evaluator and capture 20-evaluation-rubric.md.
[ ] Run Generator to draft 25-iteration-contract.md, or create 25-final-review-contract.md in simplified mode.
[ ] Let Evaluator amend acceptance criteria and verification until the active contract is AGREED, or record why Coordinator arbitrated.
[ ] Let Generator build only the agreed scope and write 30-generation-report.md.
[ ] Let Evaluator verify direct evidence first, then read 30-generation-report.md only for cross-checking, and write 40-evaluation-report.md with findings first.
[ ] For long-job delivery, write or refresh 45-checkpoint.md after each contract cycle.
[ ] Decide whether to iterate, reset context, accept residual risk, or finish.
[ ] In long-job delivery, continue to the next milestone unless a stop condition or blocking question requires the user.
[ ] Write 50-final-summary.md and respond to the user.
[ ] Release completed role resources and clean up disposable handoff files unless the user wants to inspect them. Preserve durable long-job checkpoints until resume evidence is no longer useful.
```

Notes:

- For large requests, repeat the contract -> generate -> evaluate segment per feature, workflow, or vertical slice.
- Explicit harness activation means the Coordinator should make reasonable assumptions and proceed; ask the user only for blockers.
- For long-job delivery, prefer `<repo>/.agent-harness/<task-slug>/` only when repo-local private artifacts are acceptable and ignored; otherwise use `${CODEX_HOME:-$HOME/.codex}/harness-runs/<task-slug>-<timestamp>/` or another durable user-owned directory.
- If context reset is needed, write `35-context-transition.md` before starting a fresh Generator.
- If work stalls, follow the Stall and Resume Policy in `SKILL.md` and resume from `45-checkpoint.md`.
- If simplified final review mode is used, freeze `25-final-review-contract.md` before continuous generation starts.
