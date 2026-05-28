# Domain: Customer

> A **bounded context** of the B2B SaaS platform. This file is the *durable* description of the
> Customer domain — it outlives any single work item. Work items under it (`register-customer/`,
> …) are *disposable*: a spec you write once, implement, and leave as record. When you want to
> know "what is the Customer domain and what is true about it," read this; when you want to know
> "how was registration built," read the work item.

## What this context owns

Customers as **accounts** — a company plus a primary contact — and their **lifecycle**. A customer
is the thing a subscription later attaches to, that users later belong to, that onboarding moves
through. It is *not* a login and *not* an invoice (see the boundary below).

## Ubiquitous language

| Term | Meaning here |
|---|---|
| **Customer** | The account aggregate: a company + a primary contact, with a status. The consistency boundary. |
| **Company name** | The customer's display name. Non-empty, ≤ 120 chars. |
| **Contact email** | The primary contact address. Unique across customers; the natural key. |
| **Status** | Where the customer sits in its lifecycle: `PENDING → ACTIVE → SUSPENDED`. |
| **Register** | Bring a customer into existence, in `PENDING`. |
| **Activate / Suspend** | Guarded transitions between statuses — never free `set` calls. |

## The model (full rules: [`standards/`](../../../standards/architecture.rules.md))

- **`Customer`** — aggregate root, created via the `Customer.register(...)` factory (`DOM-002`);
  state changes only through intent methods that emit events (`DOM-004`). Always valid (`DOM-001`).
- **Value objects** — `CustomerId`, `CompanyName`, `ContactEmail`, `CustomerStatus`. Each validates
  on construction and cannot hold an invalid value (`DOM-003`).
- **Lifecycle** — `PENDING → ACTIVE → SUSPENDED`. Registration always yields `PENDING`; only
  `activate()` / `suspend()` move between states, each emitting an event.

### Events this context owns (`ES-001`)

Other contexts subscribe to these; they are this domain's public, append-only contract.

- `CustomerRegisteredEvent` — `{ id, companyName, email, occurredAt }`
- `CustomerActivatedEvent` — `{ id, occurredAt }`
- `CustomerSuspendedEvent` — `{ id, reason?, occurredAt }`

## Work items

Each is a self-contained spec-first work-item (`requirements → design → tasks → acceptance`).
The context above is stable; this list grows over time.

| Work item | Does | Initiative | Status |
|---|---|---|---|
| [`register-customer/`](./register-customer/) | Create a customer in `PENDING` | INI-01 Customer Onboarding | SPEC READY |
| `activate-customer/` | `PENDING → ACTIVE` | INI-03 Lifecycle Automation | planned |
| `suspend-customer/` | `ACTIVE → SUSPENDED` | INI-03 Lifecycle Automation | planned |
| `customer-directory/` | Read side / projection over the events above | INI-04 Account Health Signals | planned |

Strategy these serve: [`../../initiatives.md`](../../initiatives.md).

## The boundary — what the Customer context is NOT

Defining the edge is half the value of a bounded context; most over-build is an unstated
"while I'm here…" that belongs to a *different* context.

- **Not authentication or users.** A customer is the company/account, not a login. Identity, users,
  roles, and sessions are a separate context.
- **Not billing.** Subscriptions, plans, and invoicing live in the Billing context; registration
  only creates the account a subscription can later attach to.
- **Not CRM / contacts.** We hold one primary contact email, not a contact book or arbitrary
  custom fields.

A second context (e.g. Billing) would be a **sibling** here: `product/domains/billing/`.
