# I Turned AI Collaboration into an Agent Harness: Not More Agents, But a System of Checks and Balances

Why does AI sometimes look busy, confident, and complete, while the result still feels unstable?

It writes quickly. It self-checks. It tells you the task is done. But the real problem is simple: the generator is evaluating itself.

That is not a reliable quality gate.

So I turned this method into a reusable skill called Agent Harness.

The point is not to summon more agents. The point is to build a structured production system for AI work.

The system has three role passes inside one agent:

1. Planner
2. Generator
3. Evaluator

And one hidden role: Coordinator.

The Coordinator is not one of the three role passes. It behaves more like a director or project lead: preserve intent, assign roles, enforce boundaries, manage file handoffs, and decide whether to iterate or finish.

## Why Not Let Multiple Agents All Write?

When people hear "agent harness," they may imagine several agents brainstorming or writing in parallel.

That can easily become chaos.

If every role is generating answers, they are just several writers. You may end up with similar, conflicting, or hard-to-merge outputs.

What I want is not more writing.

I want role separation.

Planner does not implement.
Generator does not decide final quality.
Evaluator does not produce the work.

That separation is the core.

## Planner: Define What, Not How

Planner turns a vague request into a high-level task or product spec.

It answers:

- What is the outcome?
- Who is the target user?
- What is in scope?
- What is out of scope?
- What constraints matter?
- What counts as done?

Planner should not over-prescribe implementation details.

Many AI failures happen because the model is locked into a premature and fragile plan. Planner should define the problem clearly without pretending to be the builder.

## Generator: Build Only Inside the Contract

Generator creates the actual output.

But it should not start immediately. First it reads the product spec. Then it negotiates an iteration contract with Evaluator.

That contract defines what this cycle will deliver, how it will be evaluated, what verification is required, and what is explicitly out of scope.

By default, one cycle should focus on one feature, one user-visible flow, or one testable vertical slice.

Generator can self-check, but self-checks are preliminary. They are not the final quality gate.

Generator self-review must never replace independent evaluation.

## Evaluator: Not a Polite Reviewer, But a Strict Gate

Evaluator is the most important role in the harness.

It is not there to praise Generator. It is not there to add suggestions politely. Its job is to independently verify whether the output meets the contract.

If tests can run, run them.
If a UI can be clicked, click it.
If screenshots help, capture them.
If logs exist, inspect them.
If claims are cited, check the sources.

Evaluator must not accept Generator self-report as evidence.

The default rubric has four dimensions:

- Design quality
- Originality
- Craft
- Functionality

For product, design, and content tasks, AI often produces work that looks polished but generic. Evaluator should penalize template output, decorative choices unrelated to the task, missing core flows, and obvious AI tropes.

For backend, data, and operations tasks, add dimensions such as correctness, safety, observability, rollback, and validation.

## The Key Step: Negotiate the Contract First

Before each build cycle, Generator and Evaluator negotiate the iteration contract.

Generator proposes the scope.
Evaluator adds stricter acceptance criteria and edge cases.
Generator may counter with evidence that something is out of scope or better deferred.
They continue file-based handoffs until Evaluator marks the contract AGREED.

Only then does Generator build.

This avoids a common failure mode: discovering after the work is done that everyone had a different definition of "done."

## Why File Handoffs?

I prefer each role to write small files:

- `10-product-spec.md`
- `20-evaluation-rubric.md`
- `25-iteration-contract.md`
- `30-generation-report.md`
- `40-evaluation-report.md`
- `50-final-summary.md`

Files keep the roles isolated. They preserve evidence. They make failures easier to diagnose. They also support context reset: when a long-running Generator loses coherence, a fresh Generator can resume from a structured handoff instead of inheriting a messy chat transcript.

This turns context management from a prompting trick into an engineering structure.

## The Harness Should Evolve

No harness should stay complex forever.

Every component encodes an assumption.

Planner exists because the model may under-specify requirements.
Evaluator exists because Generator self-review is unreliable.
Iteration contracts exist because scope drifts.
Context reset exists because long contexts lose state.

If the model gets stronger, a component can be removed, moved later, or simplified.

For example, a stronger model/runtime may use simplified final review mode: keep Planner, freeze a final review contract before continuous generation, let Generator work longer, and move Evaluator to one strict final review.

But one invariant remains:

Generation and evaluation must stay separate.

You can simplify the process. You should not let Generator become the final judge.

## Closing

In the AI era, the important thing is not only writing longer prompts.

It is designing structures that make AI work stable.

A good prompt is a sentence.
A good skill is a habit.
A good harness is an operating system for collaboration.

Agent Harness helps AI work become checkable, reviewable, and iterative instead of merely confident.
