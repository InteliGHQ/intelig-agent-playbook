# Requirements — Register Customer

## User story

> As an operator, I want to register a new customer with a company name and a primary contact
> email, so that the customer exists in the system in a pending state and can be activated and
> onboarded.

## Acceptance criteria (EARS notation)

EARS keeps each criterion testable: a trigger, a condition, a required response. One criterion =
one test.

1. **When** an operator submits a valid company name and a valid email, **the system shall**
   create a customer in `PENDING` state and return its id.
2. **If** the email is not a syntactically valid address, **then the system shall** reject the
   request with a validation error and create nothing.
3. **If** the company name is blank or longer than 120 characters, **then the system shall**
   reject the request with a validation error and create nothing.
4. **If** a customer already exists with the same email, **then the system shall** reject the
   request with a conflict error and create nothing.
5. **When** a customer is registered, **the system shall** emit exactly one
   `CustomerRegisteredEvent` carrying the id, company name, and email.
6. **When** a customer is registered, **the system shall** record it in `PENDING` state — never
   `ACTIVE` (activation is a separate, explicit step).

## Non-functional

- Registration is idempotent on email: retrying with an email already registered returns the
  existing customer's id rather than a conflict, *for the same caller*. *(Deferred — noted here so
  it isn't accidentally designed out; not built in this feature.)*
- No authentication in this feature (trusted operator caller).

## Out of scope

Lifecycle transitions (activate/suspend/churn), authentication/users, billing, multi-contact
management. See the boundary section in [README.md](./README.md).
