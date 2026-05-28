---
name: fitness-test
description: Author an architecture fitness test that makes a standards rule unbreakable — promoting it from advisory (manual-review/ci) to enforced. Use when the code-reviewer finds the same rule violated again, or when moving a rule UP the Enforcement Map in standards/architecture.rules.md. Bundles the test template, the file conventions, and the rule-ID-in-failure contract. Do NOT use for invariants a type-checker or linter already catches.
---

# Author a fitness test (advisory → enforced)

The repo's core move: when a rule keeps getting broken, you don't write a sterner sentence — you
write a test the build cannot pass while the rule is violated. This skill packages how to do that
*here*, with the conventions and a scaffold script, so it's one operation instead of a from-scratch
guess each time.

## When to use
- A `manual-review` rule was violated again (the `code-reviewer` flagged a repeat offender).
- You're promoting a rule UP the Enforcement Map in `standards/architecture.rules.md`.

## When NOT to use
- The invariant is already enforced by `tsc` (types) or the linter — that's the `ci` tier. Don't
  duplicate it as a fitness test.
- You can't state the rule as a checkable property over the source. Sharpen the rule first; a vague
  rule makes a flaky test.

## The contract (non-negotiable)
- The test lives in `examples/<monolith|microservice>/test/architecture.fitness.test.ts`.
- The test name starts with the rule ID, e.g. `test("API-001: controllers import no domain types", …)`.
- On failure it prints the rule ID **and** the offending files — so the next agent gets the ID in
  the red build and the lesson isn't taught twice.
- For dependency rules, prefer a real architecture-test tool (dependency-cruiser / ts-arch) over
  ad-hoc string matching; string scans miss re-exports, path aliases, and dynamic imports.

## Steps
1. Read the rule in `standards/architecture.rules.md` for its **principle** (the why), not just the
   wording — the test should defend the principle.
2. State the invariant as a property over `src/**` (e.g. "no file in `api/**` imports `domain/**`").
3. Scaffold the test: run `scaffold.sh <RULE-ID> "<what it checks>"` from this skill for a stub,
   then fill in the predicate.
4. Make it go **red** against a known violation, then **green**. A test you've only seen pass is not
   yet a wall.
5. Promote the rule: change its tag in `STANDARDS_DIGEST.md` and its row in the Enforcement Map to
   `fitness`, citing the new test.

## Honest limit
A fitness test enforces *exactly* the property you assert — no more. If it checks one facet of a
rule, say so; don't claim it guards the whole rule. Same discipline as the rest of this repo:
don't claim enforcement you haven't watched fire.
