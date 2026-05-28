# Linkforge — Agent Context

> This is the canonical context file. Every agent reads it (Claude Code reads it via the
> `@AGENTS.md` line in `CLAUDE.md`; Codex, Cursor, Copilot, Gemini CLI, Aider and others read
> `AGENTS.md` natively). Keep it **lean** — it loads on every turn. Put detail in the files it
> links to, not here.

## What you are working on

**Linkforge** is a link shortener with click analytics. A user submits a long URL and gets a
short code; every visit is recorded; the owner sees click stats over time. Small surface, real
domain — the codebase is a teaching example for building cleanly with an agent.

## Prime directives

1. **Spec before code.** Every feature lives in `product/features/<slug>/` as
   `requirements → design → tasks → acceptance`. Read the spec; implement one task at a time;
   stop at the acceptance gate. Don't invent scope the spec doesn't ask for.
2. **Standards are law.** Before writing code in an area, read the matching family in
   `standards/` (start at `standards/STANDARDS_INDEX.md` → it tells you which families apply).
   Cite the rule ID where it clarifies intent (commit, PR, or a short code comment, e.g.
   `// DOM-002: factory method, no public constructor`).
3. **Advisory vs enforced.** Rules here are advisory. The *mandatory* ones are enforced by
   fitness-function tests (see `standards/architecture.rules.md` → Enforcement Map). If a test
   would stop you, the rule is not optional. If you keep wanting to break a rule, that's a
   signal to change the test, not to sneak past it.
4. **Tag work to strategy.** Active initiatives are in `product/initiatives.md` (the session
   hook prints them for you). Reference the initiative ID in the commit subject so code links
   back to why it exists.

## Architecture, in one breath

DDD + CQRS + Event Sourcing, organized as **vertical slices**. Layers, outermost in:

`api/` (transport only, zero business logic) → `application/{command,query,handler}` →
`domain/{aggregate,event,model}` → `infrastructure/` (persistence, external I/O).

Naming: commands `<Action><Entity>Command`, queries `Get<Entity><Criteria>Query`, events
`<Entity><Action>Event`. Full rules: `standards/architecture.rules.md`.

## Where to look

| You need… | Read |
|---|---|
| Which rules apply to my change | `standards/STANDARDS_INDEX.md` |
| One-line summary of every rule | `standards/STANDARDS_DIGEST.md` |
| The current feature's spec | `product/features/<slug>/` |
| The strategy this work serves | `product/initiatives.md` |
| How the two example shapes differ | `examples/monolith/` and `examples/microservice/` |

## Commit convention

`<type>(<scope>): <description> (INI-XX)` — e.g. `feat(domain): record click event on visit (INI-01)`.
Types: `feat fix refactor test docs chore`. Explain *why* in the body; the diff shows *what*.
