# Architecture examples — the playbook *inside* real source

This folder answers one question: **what does the playbook's structure actually look like once
it's living inside a real codebase?** The specs in `product/`, the rules in `standards/`, and the
tooling in `.claude/` are conventions — here is how they land in source organized the way we
actually build.

The architecture is **Feature-Driven, living inside DDD.** The bounded context is the boundary;
*inside* it you pick a vertical-slice pattern by the context's complexity. These aren't competing
philosophies — they're a progression. (Full argument: *"Feature-Driven Lives Inside DDD."*)

The same **Customer** context is shown at each level of complexity, so you can see the structure
grow — not four different domains, one domain sliced four ways.

---

## The wrong way (what most people call "DDD")

Technical layers as the top-level cut. God services. Anemic models. No bounded context.

```
src/
├── controllers/   CustomerController  SubscriptionController
├── services/      CustomerService          ← 2000-LOC god class
├── repositories/  CustomerRepository
├── models/        Customer                 ← anemic data bag
└── utils/                                   ← the junk drawer
```

It tells you what the system is *made of*, never what it *does*. An agent can't reason about
intent here — it sees file types, not capability. People who "tried DDD and didn't like it"
usually built this.

## Pattern A — Flat CQRS

Bounded context at the top; layers at the context level. Commands and queries split.

```
customer/                              ← bounded context
├── api/
│   ├── controller/   CustomerController          # API-001: thin
│   └── dto/          command/  query/            # API-002: DTOs at the edge
├── application/
│   ├── command/      RegisterCustomerCommand  ActivateCustomerCommand  SuspendCustomerCommand
│   ├── query/        GetCustomerQuery
│   └── handler/      command/  query/            # CQRS-002: one handler per message
├── domain/
│   ├── model/        Customer  CompanyName  ContactEmail  CustomerStatus   # DOM-002/003
│   └── event/        CustomerRegisteredEvent  CustomerActivatedEvent        # ES-001
└── infrastructure/
    ├── entity/                                    # BE-INFRA: DB shape only
    └── repository/                                # ARCH-003: implements a domain port
```

**Use it when** the context is small — under ~10 commands + queries. Everything fits in your head;
an agent scans `command/` in one shot. It breaks down past ~10 ops: the folder becomes a wall of
files with no "what does this context *do*?" signal.

## Pattern B — Feature-Driven

Same context, but **features** are the top-level cut *inside* it. Each feature is a vertical slice
owning its own `api/` and a single command **or** query. The domain stays shared at the context
level — features operate *within* it, they don't own it.

```
customer/                              ← bounded context
├── feature/
│   ├── register-customer/            ← feature (command)
│   │   ├── api/          controller/
│   │   └── application/  command/   RegisterCustomerCommand  RegisterCustomerHandler
│   ├── activate-customer/            ← feature (command)
│   ├── suspend-customer/
│   └── get-customer/                 ← feature (query)
│       ├── api/
│       └── application/  query/      GetCustomerQuery  GetCustomerHandler
├── domain/                            ← SHARED across features (not duplicated per feature)
│   ├── model/   Customer  CompanyName  ContactEmail  CustomerStatus
│   └── event/   CustomerRegisteredEvent  …
└── infrastructure/   entity/  repository/
```

**Use it when** the context has many operations (10+). Features are isolated — change `change-plan`
without touching `cancel`. An agent points at `activate-customer/` and instantly has the scope. A
playbook **work-item** maps 1:1 to a feature here.

## Pattern C — Core + Features + Event Sourcing

When the domain is rich — aggregate roots, domain events, value objects — `core/` holds the shared
domain truth and `feature/` holds the use cases that operate on it.

```
customer/                              ← bounded context
├── core/                              ← shared domain truth
│   ├── domain/
│   │   ├── aggregate/   Customer       ← aggregate root; enforces every invariant (DOM-001)
│   │   ├── model/       CompanyName  ContactEmail  CustomerStatus
│   │   ├── event/       CustomerRegisteredEvent  CustomerActivatedEvent  CustomerSuspendedEvent
│   │   ├── port/                       ← interfaces (hexagonal)
│   │   └── repository/                 ← interface only
│   └── infrastructure/   entity/  mapper/  repository/    ← implementations
└── feature/
    ├── register-customer/   api/  application/  command/  listener/   ← reacts to domain events
    ├── activate-customer/   application/  command/
    ├── suspend-customer/
    └── get-customer/        application/  query/
```

`core/` is the truth, `feature/` is the actions. Features can't bypass the aggregate; domain events
drive cross-feature communication. An agent reads it instantly: **core = the truth, features = the
actions.**

---

## Choosing the pattern

| Pattern | When | Operations | Domain complexity |
|---|---|---|---|
| **A** Flat CQRS | small context | < 10 | low |
| **B** Feature-Driven | many operations | 10+ | low–medium |
| **C** Core + Features + ES | rich domain | 10+ | high |

Pick by the complexity of *this* context — not one rule for the whole system. (In the real
codebase, simple contexts like `identity` are Pattern A; rich ones like `cognis` are Pattern C.)

## Where the playbook attaches

| Playbook artifact | Lands here |
|---|---|
| Spec — `product/domains/customer/work-items/<work-item>/` | a **feature** slice (B/C) or a context-level command/query (A) |
| Rule IDs (`ARCH-/DOM-/CQRS-/API-`) | cited in commits + as comments at the structure they govern |
| Fitness tests | `customer/test/architecture.fitness.test.ts` — fail the build on a boundary violation |
| `standards-gate` hook + `fitness-test` skill | operate on edits to this source; gate before code, scaffold the test that promotes a rule to enforced |

The hard rule: the **domain is shared** (in `core/`, or the context's `domain/`) and is **never
duplicated per feature**. A feature owns its `api/` and its one command or query — nothing more.

> **Status:** skeleton. These are the structural shapes (and where the playbook conventions sit),
> not running code yet — the same honesty the rest of the repo holds to.
