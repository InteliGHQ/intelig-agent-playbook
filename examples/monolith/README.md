# Example: Modular Monolith

One deployable, many bounded contexts, clean seams. Linkforge's features
(`create-short-link`, `record-visit`, analytics) live as **vertical slices** inside a single
app and a single database. The seams between them are enforced in code, not by network calls.

```
examples/monolith/
├── src/
│   ├── features/
│   │   ├── create-short-link/      api/ application/ domain/ infrastructure/
│   │   ├── record-visit/           api/ application/ domain/ infrastructure/
│   │   └── analytics/              api/ application/ domain/ infrastructure/
│   └── shared/                     cross-cutting kernel (ids, events, errors)
├── test/
│   └── architecture.fitness.test.ts   # the rules, as tests (ARCH-001, DOM-002, API-001, …)
└── migrations/
```

## How the spec maps here

`product/features/create-short-link/` builds into `src/features/create-short-link/`. The spec
doesn't change for the monolith — the same `requirements/design/tasks/acceptance` drive it. The
`ShortLinkRepository` port is implemented by a Postgres adapter against the shared database.

## When to choose this shape

- One team, one deploy cadence, strong consistency needs.
- You want microservice-style boundaries (so you *could* split later) without the operational
  cost of distributed systems now.
- The fitness tests (`ARCH-001`, `ARCH-003`) are what keep the modular monolith *modular* — they
  fail the build if one slice reaches into another's internals. Without them, a monolith rots
  into a big ball of mud; with them, splitting to services later is a refactor, not a rewrite.

## Status

Skeleton. The spec, standards, and fitness-test contract are defined; the runnable
implementation is built by following `product/features/create-short-link/tasks.md`.
