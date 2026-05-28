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
product/      ← what we're building: features as spec-first work-items + the strategy
.claude/      ← the tooling: hooks, subagents, slash commands, settings
examples/     ← proof: the same feature built as a monolith and as a microservice
```

There is one example product threaded through the whole repo — **Linkforge**, a link
shortener with click analytics. It is small enough to read in a sitting and rich enough to
show real Domain-Driven Design, CQRS, and Event Sourcing.

---

## Read these four things, in order

1. **[`AGENTS.md`](./AGENTS.md)** — what an agent loads on every session. Notice how *short*
   it is. The best practice is a lean always-on file that points to everything else rather
   than inlining it. ([Anthropic: keep CLAUDE.md lean](https://code.claude.com/docs/en/best-practices))
2. **[`standards/`](./standards/)** — the rules, expressed as a chain
   **Paradigm → Principle → Rule → Pattern**, with stable IDs (`DOM-002`) the agent cites in
   commits and PRs. Start at [`STANDARDS_INDEX.md`](./standards/STANDARDS_INDEX.md).
3. **[`product/features/create-short-link/`](./product/features/create-short-link/)** — one
   feature, spec-first: `requirements → design → tasks → acceptance`. This is how you brief an
   agent so it can one-shot a phase without guessing. (Same shape as
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

## Two shapes of the same idea

`examples/monolith/` and `examples/microservice/` implement the *same* Create-Short-Link
feature. The standards and the spec don't change — only the deployment shape does. Read both
to see what actually differs (and what doesn't) when you split a vertical slice into a service.

## The multi-repo variant

This is the single-repo version, tuned for clarity. When you run a *fleet* of repos that share
one set of standards, you keep the canonical context in one knowledge repo and sync a lean
block into each — see [`docs/multi-repo-fleet.md`](./docs/multi-repo-fleet.md).

---

Maintained by [InteliG](https://intelig.ai) — Execution Intelligence. MIT licensed; fork it,
strip Linkforge, drop in your own product, keep the structure.
