# Feature: Register Customer

> Initiative: INI-01 Customer Onboarding · Status: SPEC READY · Example feature for the playbook

## TL;DR

An operator registers a new customer — a company name and a primary contact email — and the
customer enters the system in a `PENDING` state, ready to be activated. This is the entry point
of the Customer lifecycle and the seed of the event stream the rest of onboarding (INI-01) folds
on. It's deliberately small: the point is to show the *shape* of a clean vertical slice with a
real domain invariant, not to be impressive.

## The spec, in order

An agent should read these top-to-bottom, then implement one task at a time, stopping at the
acceptance gate. This is the spec-driven pattern (`requirements → design → tasks → acceptance`)
that GitHub Spec Kit and AWS Kiro converged on.

| File | What it pins down |
|---|---|
| [requirements.md](./requirements.md) | The behavior, as testable acceptance criteria (EARS style) |
| [design.md](./design.md) | The domain model, the CQRS messages, which rules apply |
| [tasks.md](./tasks.md) | The build, as phases — each phase is one commit with a risk rating |
| [acceptance.md](./acceptance.md) | The executable gate: exact commands that prove it's done |

## What this is NOT

- **Not lifecycle transitions.** Activating, suspending, or churning a customer is a separate
  feature (`activate-customer`, INI-03). This one only *registers*; it produces the
  `CustomerRegisteredEvent` those features later build on.
- **Not authentication or user accounts.** A customer is the *company/account*, not a login.
  Users, roles, and auth are a different bounded context.
- **Not billing.** Subscriptions and invoicing live in the Billing context; registration just
  creates the customer a subscription can later attach to.
- **Not a contacts system.** We capture one primary contact email, not a full contact book or
  arbitrary custom fields.

Defining the boundary is half the spec. Most agent over-build comes from an unstated "while I'm
here…" — so it's stated here, explicitly, as out of scope.
