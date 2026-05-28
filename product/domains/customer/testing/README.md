# Customer — testing

Context-level testing for the Customer bounded context: things that cover the *whole* context, not
a single work-item. (Per-work-item acceptance criteria live with their work item, e.g.
[`../work-items/register-customer/acceptance.md`](../work-items/register-customer/acceptance.md).)

What belongs here:

- **Test plans** — how acceptance criteria get exercised end to end (E2E/browser plans, scenarios).
- **Acceptance evidence** — recorded runs proving a work-item's acceptance gate actually passed.
- **The fitness-test contract** — the architecture tests that must stay green for this context
  (`ARCH-`/`DOM-`/`API-` …), authored with the [`fitness-test`](../../../../.claude/skills/fitness-test/)
  skill and run as `customer/test/architecture.fitness.test.ts`.

Keeping these here — not scattered across work-items — is what lets you answer "is the *Customer
context* healthy?" in one place, the same reason work items get their own [`../work-items/`](../work-items/) home.

> Status: skeleton — the contract and the shape, not yet running tests.
