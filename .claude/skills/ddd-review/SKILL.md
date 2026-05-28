---
name: ddd-review
description: Review code (or a diff) for DDD/CQRS compliance in this repo. Runs the deterministic checks — aggregate factories, no public setters, dependency direction, api↔domain boundary — then surfaces the judgment calls a fitness test can't settle. Use when reviewing a change inside a bounded context, or when the code-reviewer subagent needs a focused DDD pass. NOT a substitute for the fitness tests that hard-enforce the checkable rules.
---

# DDD review

Reviews a bounded context (or a diff within one) against the DDD/CQRS standards. It does the
**deterministic part** with a bundled script, then points you at the **judgment part** — the
`manual-review` tier — that no script or fitness test can decide.

This skill *composes*: the `code-reviewer` subagent can invoke it for the DDD-specific pass and fold
the findings into its verdict. The skill packages the *procedure + checks*; the subagent provides
the *delegated worker that returns a verdict*; the standards provide the *rules*; fitness tests
provide the *hard wall*. Different jobs — they stack.

## When to use
- Reviewing a change inside `src/<context>/…`.
- The `code-reviewer` subagent wants a focused DDD pass.

## When NOT to use
- For rules a fitness test already walls off (no public constructor, deps point inward). Those
  should **fail the build**, not wait for a review. If you keep catching one here, promote it with
  the [`fitness-test`](../fitness-test/) skill.

## The deterministic pass (bundled)
Run `check.sh [path]` (defaults to `src/`). It greps for the common, scriptable violations and
prints candidates by rule ID:

- **DOM-002** — a domain model with a non-`private` constructor (should be created via a static factory).
- **DOM-004** — a `setX(...)` setter on a domain model (mutate via intent methods that emit events).
- **ARCH-001/004** — files under `domain/` importing from `api/`, `infrastructure/`, or a framework/ORM.
- **API-001** — files under `api/` importing a `domain/` type directly.

It's string-level and intentionally simple, so treat hits as **leads, not proof** — and a clean run
doesn't mean compliant. (For a real gate, back these with the architecture fitness tests.)

## The judgment pass (you / the reviewer)
These can't be greped — read the code and decide:
- **DOM-001** — is the invariant enforced *in the aggregate*, or did it leak into a handler/service?
- **DOM-005** — does one command touch exactly one aggregate?
- **CQRS-004** — do queries read from a projection, not rehydrate aggregates?
- **API-002/003** — DTOs at the boundary; errors mapped centrally (not scattered try/catch).
- **Over-engineering** — abstractions/patterns the spec didn't ask for (itself a finding).

## Output
A short verdict (**clean / fix-then-ship / blocked**), then findings ordered by enforcement tier
(`fitness` → `ci` → `manual-review`), each with the rule ID, `file:line`, and the minimal fix. If a
`manual-review` rule keeps recurring, recommend promoting it with the `fitness-test` skill — that's
how a repeat judgment call becomes a wall.
