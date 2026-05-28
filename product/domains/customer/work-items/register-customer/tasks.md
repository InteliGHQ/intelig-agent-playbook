# Tasks — Register Customer

Each task is one commit. Build top-to-bottom; don't start a task until the one above is green.
Net LOC is a rough budget — a task that balloons past it is a signal the design drifted, stop and
re-read [design.md](./design.md).

| # | Task | Triggers | Net LOC | Risk |
|---|---|---|---|---|
| 1 | Value objects: `EmailAddress`, `CompanyName`, `CustomerId` (+ unit tests on validation) | DOM-003, TS-002 | +90 | Low |
| 2 | `CustomerStatus` enum; `CustomerRegisteredEvent`; `Customer` aggregate with private ctor + `register()` factory | DOM-002, DOM-004, ES-001 | +80 | Low |
| 3 | `CustomerRepository` port (domain) + in-memory adapter (infrastructure) | ARCH-003 | +40 | Low |
| 4 | `RegisterCustomerCommand` + `RegisterCustomerHandler` (+ handler test) | CQRS-001..003 | +60 | Low |
| 5 | Postgres adapter + migration with unique constraint on `email` | DB-001..003 | +70 | Med |
| 6 | `POST /customers` controller + DTOs + central error mapping | API-001..003 | +80 | Med |
| 7 | Fitness tests that lock the gain (see acceptance.md) | ARCH-001, DOM-002, API-001 | +50 | Low |

## Notes for the agent

- **Stop at task 7's green build.** That's the acceptance gate; don't add features past it.
- **Cite the rule ID** in each commit subject body, e.g.
  `feat(domain): Customer factory + registration event (INI-01)` with a body line `// DOM-002`.
- **One aggregate per transaction** (`DOM-005`) — task 4 touches only `Customer`.
- If a task tempts you toward activation, suspension, or billing, that's out of scope (see README
  boundary). Note it and move on; don't build it here.
