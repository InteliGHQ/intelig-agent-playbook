# Design — Register Customer

Read [`standards/architecture.rules.md`](../../../../standards/architecture.rules.md) before
implementing. The rule IDs each decision triggers are cited inline.

## Domain model

- **`Customer`** (aggregate) — created via `Customer.register(name, email)` (`DOM-002`). Holds
  `id`, `companyName`, `email`, and `status` (starts `PENDING`). State changes only through
  methods that emit events (`DOM-004`) — e.g. a later `activate()` moves `PENDING → ACTIVE`.
  Invariant — a customer always has a valid name + email and a legal status (`DOM-001`).
- **`CustomerStatus`** — enum `PENDING | ACTIVE | SUSPENDED`. Registration always yields
  `PENDING`; transitions are guarded by aggregate methods, not set freely (`DOM-004`).
- **`EmailAddress`** (value object) — a syntactically valid address, normalized to lowercase,
  validated on construction (`DOM-003`). Cannot exist in an invalid form.
- **`CompanyName`** (value object) — non-empty, ≤ 120 chars, trimmed; validated on construction
  (`DOM-003`).
- **`CustomerId`** (value object) — opaque identity, generated.

## Events (`ES-001`)

- **`CustomerRegisteredEvent`** — `{ id, companyName, email, occurredAt }`. The single fact this
  feature produces. Onboarding (INI-01) and the read projection both fold from here.

## CQRS messages

- **`RegisterCustomerCommand`** `{ companyName: string, email: string }` (`CQRS-003`).
- **`RegisterCustomerHandler`** — one handler (`CQRS-002`): build the value objects (validation
  happens there), call `Customer.register`, persist, return the new id (`CQRS-001`). It
  orchestrates; it makes no domain decisions itself (`DOM-001`).
- No query in this feature — reads belong to the customer-directory slice (`CQRS-004`).

## Persistence (`ARCH-003`)

- The domain declares the port `CustomerRepository { save(customer): Promise<void> }`.
- Infrastructure provides the adapter (in-memory for tests; Postgres in the examples). The
  adapter depends on the domain interface, never the reverse (`ARCH-001`, `ARCH-004`).
- Uniqueness of `email` is a DB constraint (`DB-003`), surfaced as the conflict error in
  requirement #4 — not a read-then-write check that races two concurrent registrations.

## Transport (`API-001`, `API-002`)

- `POST /customers` → parse a `RegisterCustomerRequest` DTO, call the handler, return `201` with
  `{ id }`. Validation errors → `400`, duplicate email → `409`, mapped centrally (`API-003`).

## Why this shape

Everything that can be wrong about a customer is unrepresentable: you cannot construct an invalid
`EmailAddress` or `CompanyName`, you cannot build a `Customer` except through the factory that
validates and emits the event, and you cannot land in `ACTIVE` by accident because only
`activate()` moves you there. The handler has no room to "decide" anything — which is exactly why
it's boring, and boring handlers are the goal.
