# Architecture Rules

Full text for the `ARCH`, `DOM`, `CQRS`, `API`, `ES`, and `DB` families. One-liners are in
[`STANDARDS_DIGEST.md`](./STANDARDS_DIGEST.md); compliant code is in
[`architecture.patterns.md`](./architecture.patterns.md). Each rule states the **Principle** it
serves so you can reason about edge cases instead of pattern-matching.

---

## ARCH — Architecture & Layering

**Paradigm:** Domain-Driven Design. **Principle:** the domain is the center; everything else is
detail that can be swapped without touching it.

- **ARCH-001 — Dependencies point inward.** The allowed direction is `api → application → domain`.
  `domain` imports nothing from the outer layers. A query in `application` may not import a
  controller; a domain model may not import a repository implementation. *Why:* the domain stays
  testable and portable; you can replace HTTP, the database, or the framework without rewriting
  business rules. *Enforcement:* `fitness`.
- **ARCH-002 — Vertical slices first.** The top-level cut is by feature
  (`features/create-short-link/...`), not by technical layer (`controllers/`, `services/`,
  `repositories/`). Within a slice, use the layer folders. *Why:* a feature's code, tests, and
  spec sit together; an agent can load one slice and have everything it needs. *Enforcement:*
  `manual-review`.
- **ARCH-003 — Infrastructure depends on domain, never the reverse.** A Postgres repository
  *implements* a domain-defined interface. The domain declares the port; infrastructure provides
  the adapter. *Enforcement:* `fitness`.
- **ARCH-004 — No I/O types in the domain.** No HTTP request objects, ORM entities, SDK clients,
  or framework annotations inside `domain/`. If the domain needs the outside world, it defines an
  interface and lets infrastructure satisfy it. *Enforcement:* `fitness`.

## DOM — Domain Model

**Principle:** an aggregate is always valid. It is impossible to hold one in an invalid state.

- **DOM-001 — Invariants live in the aggregate.** "A short code is 4–10 url-safe characters" is
  enforced inside `ShortLink`, not in the handler that calls it. Handlers orchestrate; they do not
  decide domain truth. *Enforcement:* `manual-review`.
- **DOM-002 — Factory creation, no public constructor.** Create aggregates through a static
  factory (`ShortLink.create(...)`) that validates and emits the creation event. The constructor
  is private. *Why:* there is exactly one path into existence, and it cannot produce an invalid
  object. *Enforcement:* `fitness`.
- **DOM-003 — Value objects are immutable and self-validating.** `ShortCode`, `TargetUrl` validate
  in their constructor and expose no mutators. An invalid value object cannot be constructed.
  *Enforcement:* `ci`.
- **DOM-004 — State changes emit events; no public setters.** Mutation happens through intent-named
  methods (`recordVisit()`), each of which appends a domain event. No `setStatus(...)`. *Why:*
  every change is an auditable fact, which is what makes Event Sourcing possible. *Enforcement:*
  `fitness`.
- **DOM-005 — One aggregate per transaction.** A single command modifies one aggregate. Cross-
  aggregate consistency is reached via events, eventually — not via a transaction spanning two.
  *Enforcement:* `manual-review`.

## CQRS — Command / Query Separation

**Principle:** the model that changes state and the model that answers questions are different
shapes with different owners.

- **CQRS-001 — Commands mutate, queries read.** A command handler returns nothing meaningful
  (or an id); it never returns query data. A query handler never writes. *Enforcement:* `fitness`.
- **CQRS-002 — One handler per message.** Each command/query has exactly one handler. No
  "god handler." *Enforcement:* `fitness`.
- **CQRS-003 — Names declare intent.** `CreateShortLinkCommand`, `RecordVisitCommand`,
  `GetShortLinkStatsQuery`. Imperative for commands, `Get…` for queries. *Enforcement:* `ci`.
- **CQRS-004 — Queries read from a projection.** Reads don't rehydrate aggregates; they hit a
  read model built for the question being asked. *Enforcement:* `manual-review`.

## API — Transport

**Principle:** HTTP is a delivery mechanism, not where the application lives.

- **API-001 — Thin controllers.** A controller does three things: parse/validate input, invoke one
  handler, map the result to a response. Any `if` that encodes a business decision is misplaced.
  *Enforcement:* `fitness`.
- **API-002 — DTOs at the boundary.** Domain objects never serialize directly to the wire. Map to
  request/response DTOs. *Why:* the public contract evolves independently of the domain.
  *Enforcement:* `manual-review`.
- **API-003 — Centralized error mapping.** Domain/application errors map to HTTP status in one
  place (an error handler/filter), not with scattered try/catch in controllers. *Enforcement:*
  `manual-review`.

## ES — Event Sourcing

**Principle:** the log of what happened is the truth; current state is a fold over it.

- **ES-001 — Events are immutable past-tense facts.** `ShortLinkCreatedEvent`, `VisitRecordedEvent`.
  Once written, never changed. *Enforcement:* `ci`.
- **ES-002 — State is replayed from events.** An aggregate's current state is the result of
  applying its event stream in order. *Enforcement:* `manual-review`.
- **ES-003 — Projections are disposable.** Read models are derived from events and can be rebuilt
  by replay. Never treat a projection row as the system of record. *Enforcement:* `manual-review`.

## DB — Persistence

- **DB-001 — snake_case, singular.** `short_link`, `visit_event`. *Enforcement:* `ci`.
- **DB-002 — Forward-only migrations.** Every change is a new migration; shipped migrations are
  immutable. *Enforcement:* `ci`.
- **DB-003 — Constraints in the schema.** Foreign keys, NOT NULL, uniqueness are declared in the
  database, not merely hoped for in code. *Enforcement:* `ci`.

---

## Enforcement Map

This is the load-bearing table. `manual-review` is advisory; `fitness` is a guarantee. The goal
over time is to move rules *up* this list as they prove they matter.

| Rule | Enforcement | Mechanism |
|---|---|---|
| ARCH-001, ARCH-003, ARCH-004 | `fitness` | dependency-direction test (`examples/*/test/architecture.fitness.test.ts`) |
| DOM-002 | `fitness` | "no exported aggregate has a public constructor" test |
| DOM-004 | `fitness` | "no public setter on an aggregate" test |
| CQRS-001, CQRS-002 | `fitness` | "command handlers return void/id; one handler per message" test |
| API-001 | `fitness` | "controllers import no `domain/**` types directly" test |
| DOM-003, CQRS-003, DB-*, TS-*, ES-001 | `ci` | type checker / linter / unit tests |
| DOM-001, DOM-005, API-002, API-003, CQRS-004, ES-002, ES-003, ARCH-002 | `manual-review` | reviewer or `code-reviewer` subagent |

## How feedback becomes a fitness function (worked example)

A reviewer notices a controller reaching into a domain aggregate directly — a violation of
**API-001**. The wrong fix is to add a sentence to `AGENTS.md` and hope. The right fix:

```ts
// examples/microservice/test/architecture.fitness.test.ts
test("API-001: controllers contain no domain imports", () => {
  const offenders = sourceFiles("src/api/**/*.ts")
    .filter(f => f.imports.some(i => i.from.includes("/domain/")));
  expect(offenders).toEqual([]); // fails the build if a controller imports a domain type
});
```

Now the rule is not a request — it's a wall. The next agent that tries the same shortcut gets a
red build with the rule ID in the failure message. **That is how you stop teaching the same
lesson twice.**
