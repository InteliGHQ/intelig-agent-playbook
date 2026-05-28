# Standards

The rules an agent must obey while writing code here. They exist so that "good" is not a matter
of taste or vigilance — it's defined, citable, and (for the ones that matter most) enforced by
tests the code cannot pass while broken.

## The chain: Paradigm → Principle → Rule → Pattern

Every rule traces up to a reason and down to an example. This is what keeps the rule set from
becoming a pile of arbitrary preferences.

| Level | Question it answers | Example |
|---|---|---|
| **Paradigm** | What worldview are we building in? | Domain-Driven Design + CQRS + Event Sourcing |
| **Principle** | What does that worldview demand? | The domain must not depend on infrastructure |
| **Rule** | What concrete, checkable line follows? | `DOM-002` — aggregates are created via factory methods, never a public constructor |
| **Pattern** | What does compliant code look like? | the `Customer.register(...)` example in `architecture.patterns.md` |

When you cite `DOM-002` in a commit, a reader can walk the chain up to *why* and down to *how*.

## How to use this folder

1. **Start at [`STANDARDS_INDEX.md`](./STANDARDS_INDEX.md)** — it maps the kind of change you're
   making to the rule families you must read.
2. **Skim [`STANDARDS_DIGEST.md`](./STANDARDS_DIGEST.md)** — one line per rule. Fits in context.
3. **Open the family file** (e.g. [`architecture.rules.md`](./architecture.rules.md)) for full
   text + the **Enforcement Map** before any non-trivial change.
4. **Cite the rule ID** when an edit triggers a rule.

## Advisory vs. enforced — the part that matters

A rule is only as strong as its enforcement. Each rule carries an enforcement tag:

- **`fitness`** — an automated architecture test fails if the rule is broken. *Mandatory.* The
  code physically cannot merge while violating it. (See `architecture.rules.md` → Enforcement Map,
  and the runnable tests in `examples/*/`.)
- **`ci`** — a linter, type check, or unit test enforces it.
- **`manual-review`** — a human (or a review subagent) checks it. Advisory. The weakest tier;
  promote rules out of this tier as they prove load-bearing.

> **The loop that makes this work:** reviewer finds a violation → instead of writing a sterner
> sentence in `AGENTS.md`, add a `fitness` test that encodes the rule → the violation can never
> recur. Feedback compounds into guarantees. That is the whole thesis of this repo.

## Changing the standards

Adding or altering a rule updates **three files in the same change**:
`STANDARDS_DIGEST.md` + `STANDARDS_INDEX.md` + the matching `*.rules.md`. Never let the digest
drift from the prose.
