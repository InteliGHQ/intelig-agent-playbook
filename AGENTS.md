# Customer Platform — Agent Context

> This is the canonical context file. Every agent reads it (Claude Code reads it via the
> `@AGENTS.md` line in `CLAUDE.md`; Codex, Cursor, Copilot, Gemini CLI, Aider and others read
> `AGENTS.md` natively). Keep it **lean** — it loads on every turn. Put detail in the files it
> links to, not here.

## What you are working on

A B2B SaaS backend. This codebase is its **Customer** bounded context: registering customers
(a company + a primary contact) and moving them through a lifecycle (`PENDING → ACTIVE →
SUSPENDED`). Small surface, real invariants — a teaching example for building cleanly with an
agent.

## Prime directives

1. **Spec before code.** Work is organized by domain: each *bounded context* lives in
   `product/domains/<domain>/` (its `README.md` is the durable description), and holds spec-first
   work-items at `product/domains/<domain>/<work-item>/` (`requirements → design → tasks →
   acceptance`). Read the spec; implement one task at a time; stop at the acceptance gate. Don't
   invent scope the spec doesn't ask for.
2. **Standards are law.** Before writing code in an area, read the matching family in
   `standards/` (start at `standards/STANDARDS_INDEX.md` → it tells you which families apply).
   Cite the rule ID where it clarifies intent (commit, PR, or a brief code comment, e.g.
   `// DOM-002: factory method, no public constructor`). Rule IDs read `<FAMILY>-<NNN>` —
   families are `ARCH DOM CQRS API ES DB TS`, each listed in `standards/STANDARDS_DIGEST.md`
   (so `DOM-002` = the 2nd rule in the domain-model family).
3. **Advisory vs enforced.** Rules here are advisory. The *mandatory* ones are enforced by
   fitness-function tests (see `standards/architecture.rules.md` → Enforcement Map). If a test
   would stop you, the rule is not optional. If you keep wanting to break a rule, that's a
   signal to change the test, not to sneak past it.
4. **Tag work to strategy.** Active initiatives are in `product/initiatives.md` (the session
   hook prints them for you). Reference the initiative ID in the commit subject so code links
   back to why it exists.

## Architecture, in one breath

DDD + CQRS + Event Sourcing, organized as **vertical slices grouped by bounded context**.
Layers, outermost in:

`api/` (transport only, zero business logic) → `application/{command,query,handler}` →
`domain/{aggregate,event,model}` → `infrastructure/` (persistence, external I/O).

Naming: commands `<Action><Entity>Command`, queries `Get<Entity><Criteria>Query`, events
`<Entity><Action>Event`. Full rules: `standards/architecture.rules.md`.

## Where to look

| You need… | Read |
|---|---|
| Which rules apply to my change | `standards/STANDARDS_INDEX.md` |
| One-line summary of every rule | `standards/STANDARDS_DIGEST.md` |
| The domain (bounded context) a change belongs to | `product/domains/<domain>/README.md` |
| The current work-item's spec | `product/domains/<domain>/<work-item>/` |
| The strategy this work serves | `product/initiatives.md` |
| How the two example shapes differ | `examples/monolith/` and `examples/microservice/` |
| A name/shape for a recurring design problem | [refactoring.guru/design-patterns](https://refactoring.guru/design-patterns) — reach for a pattern only to remove pain you already feel, never preemptively |

## Commit & branch convention

- **Commit:** `<type>(<scope>): <description> (INI-XX)` — e.g.
  `feat(domain): emit CustomerRegisteredEvent on registration (INI-01)`.
  Types: `feat fix refactor test docs chore`. Explain *why* in the body; the diff shows *what*.
- **Branch:** `<type>/<work-item>` — e.g. `feat/register-customer`.

Prefixing the branch with the work-item and citing `INI-XX` in commits is what lets tooling link
every branch, commit, and PR back to the initiative that owns it.
