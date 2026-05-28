# Standards Digest

One line per rule. Skim this; open [`architecture.rules.md`](./architecture.rules.md) for full
text and the Enforcement Map. Format: `ID — rule (enforcement)`.

## ARCH — architecture & layering
- `ARCH-001` — Dependencies point inward only: `api → application → domain`; `domain` imports nothing outward. (fitness)
- `ARCH-002` — Organize by feature (vertical slice), not by technical layer at the top level. (manual-review)
- `ARCH-003` — `infrastructure` may depend on `domain` interfaces, never the reverse. (fitness)
- `ARCH-004` — No framework or I/O types in `domain` (no HTTP, ORM, SDK imports). (fitness)

## DOM — domain model
- `DOM-001` — Business invariants live in the aggregate, never in a handler or service. (manual-review)
- `DOM-002` — Aggregates are created via a static factory, never a public constructor. (fitness)
- `DOM-003` — Value objects are immutable and validate on construction. (ci)
- `DOM-004` — State changes go through methods that emit a domain event; no public setters. (fitness)
- `DOM-005` — An aggregate is a consistency boundary; one transaction touches one aggregate. (manual-review)

## CQRS — command/query separation
- `CQRS-001` — Commands mutate and return void/id; queries read and never mutate. (fitness)
- `CQRS-002` — One handler per command/query; no handler handles more than one. (fitness)
- `CQRS-003` — Command names are imperative `<Action><Entity>Command`; queries `Get<Entity><Criteria>Query`. (ci)
- `CQRS-004` — Queries bypass the domain and read from a projection/read model. (manual-review)

## API — transport
- `API-001` — Controllers parse input, call one handler, map the result. Zero business logic. (fitness)
- `API-002` — No domain type crosses the HTTP boundary; map to/from DTOs. (manual-review)
- `API-003` — Transport errors map to status codes in one place, not scattered in handlers. (manual-review)

## ES — event sourcing
- `ES-001` — Domain events are immutable, past-tense facts: `<Entity><Action>Event`. (ci)
- `ES-002` — Aggregate state is rebuilt by replaying its events; the event log is the source of truth. (manual-review)
- `ES-003` — Projections are derived and disposable; never write to a projection as if it were truth. (manual-review)

## DB — persistence
- `DB-001` — snake_case tables and columns; singular table names. (ci)
- `DB-002` — Every schema change is a forward migration; never edit a shipped migration. (ci)
- `DB-003` — Foreign keys and NOT NULL constraints are declared, not assumed in code. (ci)

## TS — language
- `TS-001` — `strict` mode on; no `any` without a written justification. (ci)
- `TS-002` — Errors are typed and thrown at boundaries; no silent catch-and-ignore. (ci)
- `TS-003` — Files and exports are named for the concept, not the layer (`short-link.ts`, not `entity1.ts`). (ci)
