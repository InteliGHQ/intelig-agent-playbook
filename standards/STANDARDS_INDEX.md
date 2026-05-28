# Standards Index

Find the kind of change you're making; read those families *before* you write code.
Full text lives in the linked `*.rules.md`. One-line summaries are in
[`STANDARDS_DIGEST.md`](./STANDARDS_DIGEST.md).

| If you are touching… | Read these families | In |
|---|---|---|
| Project layout, layering, vertical slices | `ARCH` | [architecture.rules.md](./architecture.rules.md) |
| Aggregates, value objects, domain events | `DOM` | [architecture.rules.md](./architecture.rules.md) |
| Commands, queries, handlers | `CQRS` | [architecture.rules.md](./architecture.rules.md) |
| Controllers / HTTP / transport | `API` | [architecture.rules.md](./architecture.rules.md) |
| Event store, replay, projections | `ES` | [architecture.rules.md](./architecture.rules.md) |
| Persistence, schema, migrations | `DB` | [architecture.rules.md](./architecture.rules.md) |
| TypeScript specifics, naming, errors | `TS` | [architecture.patterns.md](./architecture.patterns.md) |

## Rule families at a glance

| Family | Scope | Default enforcement |
|---|---|---|
| **ARCH** | Layering and dependency direction | `fitness` |
| **DOM** | Domain model integrity | `fitness` + `manual-review` |
| **CQRS** | Read/write separation | `fitness` |
| **API** | Transport carries no business logic | `fitness` + `manual-review` |
| **ES** | Events are the source of truth | `manual-review` |
| **DB** | Naming, migrations, integrity | `ci` |
| **TS** | Language idioms, errors, naming | `ci` |

## Re-read triggers

Read the family again — don't trust memory — when you:

- start a new work-item in `product/domains/`,
- cross a layer boundary (e.g. wiring `application/` to `infrastructure/`),
- add a new aggregate, command, query, or event,
- touch anything tagged `fitness` (the test will tell you the rule ID it enforced).
