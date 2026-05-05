# Agent Harness Bootstrap Checklist

Use this checklist when the runtime supports todos, task lists, or explicit progress tracking. Adapt wording to the current task, but preserve the order unless the user imposes a different constraint.

```text
[ ] Confirm the user explicitly requested agent-harness, three-agent collaboration, or QA/improvement of the harness itself.
[ ] Create a private handoff workspace, preferably ${TMPDIR:-/tmp}/agent-harness-<task-slug>-<timestamp>/.
[ ] Write 00-request.md with request summary, constraints, assumptions, role permissions, and validation expectations.
[ ] Run Planner and capture 10-product-spec.md.
[ ] Run or prepare Evaluator and capture 20-evaluation-rubric.md.
[ ] Run Generator to draft 25-iteration-contract.md, or create 25-final-review-contract.md in simplified mode.
[ ] Let Evaluator amend acceptance criteria and verification until the active contract is AGREED, or record why Coordinator arbitrated.
[ ] Let Generator build only the agreed scope and write 30-generation-report.md.
[ ] Let Evaluator independently verify and write 40-evaluation-report.md with findings first.
[ ] Decide whether to iterate, reset context, accept residual risk, or finish.
[ ] Write 50-final-summary.md and respond to the user.
[ ] Release completed role agents/resources and clean up disposable handoff files unless the user wants to inspect them.
```

Notes:

- For large requests, repeat the contract -> generate -> evaluate segment per feature, workflow, or vertical slice.
- If context reset is needed, write `35-context-transition.md` before starting a fresh Generator.
- If simplified final review mode is used, freeze `25-final-review-contract.md` before continuous generation starts.

