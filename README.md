# intelig-agent-playbook

**How to build software efficiently with AI coding agents.**

The lesson of this repo is one sentence: **being efficient with a coding agent is a
repository-design problem, not a prompting trick.** An agent is only as good as the context,
the standards, and the structure you hand it. So the repo *is* the argument — every folder
here exists to make an agent more effective, and you can read the whole philosophy from a
single `ls`.

```
AGENTS.md     ← the canonical context every agent reads (lean, always loaded)
CLAUDE.md     ← one line: @AGENTS.md  (so Claude Code reads the same source)
standards/    ← the law: the rules the agent must obey, with stable IDs
product/      ← what we're building: spec-first work-items grouped by domain + the strategy
.claude/      ← the tooling: hooks, subagents, slash commands, skills, settings
arch-examples/ ← proof: the playbook inside real source — feature-driven slices, inside DDD
```

The example domain threaded through the whole repo is the **Customer** context of a B2B SaaS
backend — register a customer, move it through a lifecycle. Small enough to read in a sitting,
real enough to show genuine Domain-Driven Design, CQRS, and Event Sourcing (an aggregate with
invariants, value objects that can't hold invalid state, events as the source of truth).

---

> **Want the whole picture first?** [`WALKTHROUGH.md`](./WALKTHROUGH.md) tours the repo end to end —
> what loads, what fires when, and how context, standards, and enforcement interlock.

## Read these four things, in order

1. **[`AGENTS.md`](./AGENTS.md)** — what an agent loads on every session. Notice how *short*
   it is. The best practice is a lean always-on file that points to everything else rather
   than inlining it. ([Anthropic: keep CLAUDE.md lean](https://code.claude.com/docs/en/best-practices))
2. **[`standards/`](./standards/)** — the rules, expressed as a chain
   **Paradigm → Principle → Rule → Pattern**, with stable IDs (`DOM-002`) the agent cites in
   commits and PRs. Start at [`STANDARDS_INDEX.md`](./standards/STANDARDS_INDEX.md).
3. **[`product/domains/customer/`](./product/domains/customer/)** — a domain (bounded context)
   and its spec-first work-items. The durable context description lives in its `README.md`; each
   work-item under it — e.g.
   [`register-customer/`](./product/domains/customer/register-customer/) — is
   `requirements → design → tasks → acceptance`. This is how you brief an agent so it can
   one-shot a phase without guessing. (Same shape as
   [GitHub Spec Kit](https://github.com/github/spec-kit) / [AWS Kiro](https://kiro.dev/docs/specs/).)
4. **[`.claude/`](./.claude/)** — the tooling that makes it automatic: a session hook that
   injects the standards primer **and your live strategy**, two subagents, and a slash command.

## The one idea worth stealing

> **Don't ask the agent to be good. Make wrong structurally impossible.**

Reviewer feedback in this repo doesn't become a politely-worded rule that the agent may or may
not follow next time — it becomes a **fitness function**: an automated architecture test the
code cannot pass while violating the rule. Advisory guidance lives in `AGENTS.md`; *mandatory*
guarantees live in tests and hooks. That hierarchy — advisory → enforced — is the difference
between hoping and knowing. ([fitness functions](https://www.infoq.com/articles/fitness-functions-architecture/),
[agentic architecture governance](https://www.oreilly.com/radar/how-agentic-ai-empowers-architecture-governance/))

## One architecture, sliced by complexity

[`arch-examples/`](./arch-examples/) shows the *same* Customer context structured three ways — flat
CQRS, feature-driven, and `core/` + `feature/` + Event Sourcing — because **Feature-Driven lives
inside DDD**: the bounded context is the boundary, and you pick the slice pattern that fits the
context's complexity. It's also where you see exactly where the playbook's conventions (specs, rule
IDs, fitness tests) attach to real source.

## The multi-repo variant

This is the single-repo version, tuned for clarity. When you run a *fleet* of repos that share
one set of standards, you keep the canonical context in one knowledge repo and sync a lean
block into each — see [`docs/multi-repo-fleet.md`](./docs/multi-repo-fleet.md).

---

Maintained by [InteliG](https://intelig.ai) — Execution Intelligence. MIT licensed; fork it,
swap the Customer example for your own product, keep the structure.
