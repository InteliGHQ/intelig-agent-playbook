# Walkthrough — how this repo works, end to end

This repo is a **machine for making an AI coding agent produce correct work by construction** —
not by being asked nicely. The thesis: *working fast with an agent is a repository-design problem,
not a prompting trick.* Everything here is either **context** the agent loads or **structure and
enforcement** that constrains what it can do.

There is one example product threaded through the whole thing — a B2B SaaS backend's **Customer**
context (register a customer; move it through `PENDING → ACTIVE → SUSPENDED`). Small enough to read
in a sitting, real enough to show genuine DDD, CQRS, and Event Sourcing. Fork it, swap the example,
keep the structure.

## The mental model

Two layers, one axis:

- **Context** — what the agent reads (`AGENTS.md`, `standards/`, the spec for the current work).
- **Structure & enforcement** — what stops it from going wrong (hooks, fitness tests, the
  spec-first flow).

The axis everything sits on is **advisory → enforced**. Docs are advisory; hooks fire
deterministically; fitness tests are walls. The discipline is to push rules *down* that axis over
time, and to reach for the *lightest deterministic* primitive that does the job.

> **Don't ask the agent to be good. Make wrong structurally impossible.**

---

## What happens, in order

### 1. Session start — the agent loads the rules and the strategy
`CLAUDE.md` is one line — `@AGENTS.md` — so Claude Code reads the same canonical brief every other
agent reads. [`AGENTS.md`](./AGENTS.md) is the **lean, always-on** context: it states the prime
directives and a "Where to look" table, and inlines almost nothing (it pays rent on every turn).

Two `SessionStart` hooks (wired in [`.claude/settings.json`](./.claude/settings.json)) then fire:

- [`standards-loader.sh`](./.claude/hooks/standards-loader.sh) prints the **standards primer** —
  "rules apply; start at the index; cite the rule ID; fitness rules are walls, manual-review is
  advisory."
- [`initiatives-loader.sh`](./.claude/hooks/initiatives-loader.sh) prints the **active strategy**.
  It is dual-mode: by default it reads the committed [`product/initiatives.md`](./product/initiatives.md)
  (offline, forkable); if `INITIATIVES_API_URL` is set it fetches a live strategy API, caches for an
  hour, and falls back to the file on any failure. Same output either way.

The agent now knows *the rules exist*, *where they live*, and *why the work exists*.

### 2. Specifying a feature — spec before code
Work is **spec-first and grouped by domain**:

```
product/domains/<domain>/            ← bounded context (durable): README is the context overview
        └── <work-item>/             ← one unit of work (disposable): the four-file spec
              requirements → design → tasks → acceptance
```

`/new-feature` ([command](./.claude/commands/new-feature.md)) derives the domain + work-item and
hands off to the [`architect`](./.claude/agents/architect.md) subagent, which writes the four files
(and the domain `README.md` if the domain is new). The architect writes *specs, not code*:

- **requirements.md** — behavior as testable EARS criteria (one criterion = one test).
- **design.md** — the domain model + the rule IDs each decision triggers.
- **tasks.md** — the build as phases, one commit each, with a LOC budget.
- **acceptance.md** — the **executable gate**: the exact commands that prove "done."

An implementing agent then does **one task at a time and stops at the acceptance gate**. That gate
is the anti-over-build mechanism. See the worked example:
[`product/domains/customer/register-customer/`](./product/domains/customer/register-customer/).

The **durable vs disposable** distinction matters: the *domain* (Customer) owns the aggregate,
lifecycle, and events and lives forever; a *work-item* (register-customer) is a spec you write once,
implement, and leave as record.

### 3. Writing code — the standards are the law
[`standards/`](./standards/) is a chain: **Paradigm → Principle → Rule → Pattern**.

- [`STANDARDS_INDEX.md`](./standards/STANDARDS_INDEX.md) maps work-type → which families to read.
- [`STANDARDS_DIGEST.md`](./standards/STANDARDS_DIGEST.md) — one line per rule.
- [`architecture.rules.md`](./standards/architecture.rules.md) — full text for
  `ARCH / DOM / CQRS / API / ES / DB`, each with its *principle* (so you can reason about edge
  cases), plus the **Enforcement Map**.
- [`architecture.patterns.md`](./standards/architecture.patterns.md) — compliant TypeScript
  reference code.

Every rule has a stable ID with the grammar `<FAMILY>-<NNN>` (so `DOM-002` = the 2nd rule in the
Domain-model family). You cite the ID in commits, PRs, and code comments.

### 4. Enforcement — the actual point
This is the spine of the argument: **advisory → enforced**.

| Tier | What it is | Enforced by |
|---|---|---|
| `manual-review` | advisory; a judgment call | the [`code-reviewer`](./.claude/agents/code-reviewer.md) subagent — reviews the diff by tier, flags over-engineering, proposes tests |
| `ci` | linter / type-check / unit test | the toolchain |
| `fitness` | an architecture test that **fails the build** | the test suite — a wall the code can't pass while broken |

Two mechanisms make this real beyond the prose:

- **[`standards-gate.sh`](./.claude/hooks/standards-gate.sh)** (a `PreToolUse` hook) turns "read the
  rules before coding" from advice into a wall: it **blocks** an edit to example `src/` code until
  the standards were consulted this session, and hands the reason back to the agent, which reads and
  retries. It fails *open* on ambiguity (a nudge, not a nuisance) and is honest that it enforces
  *consulted the standards*, not *read the exact family*.
- **The [`fitness-test`](./.claude/skills/fitness-test/) skill** closes the loop: when the
  reviewer catches a repeat violation, this skill scaffolds the architecture test (with a real
  bundled `scaffold.sh`) that promotes the rule *up* the Enforcement Map. That is the literal
  "feedback becomes a test, not a sterner sentence" move — tooled, not just described.

### 5. Linking code to strategy
[`product/initiatives.md`](./product/initiatives.md) lists coarse initiatives (`INI-01` …). The
commit and branch conventions — `feat(domain): … (INI-01)` and `feat/<work-item>` — tag work so it
traces back to the goal. The repo is **honest** that the link here is "convention + grep"; true
auto-linking is a product problem, not a hook.

### 6. One architecture, sliced by complexity
[`arch-examples/`](./arch-examples/) shows the *same* Customer context structured three ways — flat
CQRS, feature-driven, and `core/` + `feature/` + Event Sourcing. **Feature-Driven lives inside
DDD:** the bounded context is the boundary; you pick the slice pattern that fits its complexity, and
the domain stays shared (in `core/`), never duplicated per feature. The spec, the rule IDs, and the
fitness-test contract are identical across patterns.
[`docs/multi-repo-fleet.md`](./docs/multi-repo-fleet.md) covers running many repos off one set of
standards.

---

## Choosing a primitive (and when *not* to add one)

Skills, subagents, slash commands, hooks, MCP, and the context file all overlap. Reach for the
lightest, most deterministic one that fits:

- **Hook** — fires on an event, deterministically. Best for "always do X at session start / before
  this tool."
- **Slash command** — invoked explicitly by a human. Best for "scaffold / run this on demand."
- **Subagent** — a focused worker with its own context. Best for "go review / go design this."
- **Skill** — bundles *procedure + executable code*, surfaced on a precise trigger. Best only when
  you have real procedure and code to package — not as a dressed-up prompt. This repo has exactly
  one (`fitness-test`) because that is the one place it earns its keep.

If a five-line rule in `AGENTS.md`, a hook, or a command does the job, prefer it over a skill whose
value depends on relevance-guessed triggering.

---

## Honest caveats (current state)

The repo's brand is intellectual honesty, so:

- The structures in [`arch-examples/`](./arch-examples/) are **skeletons** — the spec, the standards, and the fitness-test
  *contract* are defined, but there is no running implementation yet. The gate and the fitness tests
  are demonstrated and contracted, not yet firing against real `src/`.
- The **dynamic initiatives API** and the **fitness tests** are capabilities the design provides
  (opt-in / to-be-implemented), not live in this instance.
- The standards-gate enforces *that the standards were consulted*, not *that the exact matching
  family was read* — it's a nudge with teeth, deliberately permissive.

That advisory→enforced hierarchy — being explicit about what is a wall and what is a nudge — is the
difference between hoping and knowing.
