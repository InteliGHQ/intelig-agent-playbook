# Requirements — Create Short Link

## User story

> As a Linkforge user, I want to turn a long URL into a short link (optionally choosing the
> code), so that I can share a compact link and later see how often it's clicked.

## Acceptance criteria (EARS notation)

EARS keeps each criterion testable: a trigger, a condition, a required response. One criterion =
one test.

1. **When** a user submits a valid target URL, **the system shall** create a short link with a
   unique 4–10 character url-safe code and return its id and code.
2. **When** a user submits a desired code that is available and valid, **the system shall** use
   that code instead of generating one.
3. **If** the submitted target URL is not a syntactically valid absolute `http(s)` URL, **then
   the system shall** reject the request with a validation error and create nothing.
4. **If** the desired code is already in use, **then the system shall** reject the request with a
   conflict error and create nothing.
5. **If** the desired code is present but not 4–10 url-safe characters, **then the system shall**
   reject it as a validation error.
6. **When** a short link is created, **the system shall** emit exactly one
   `ShortLinkCreatedEvent` carrying the id, code, and target.

## Non-functional

- Creation is idempotent on `(desiredCode)` when supplied: retrying the same desired code that
  the same owner already created returns the existing link, not a conflict. *(Deferred — see
  boundary; noted so it isn't accidentally designed out.)*
- No authentication in this feature (trusted caller; auth is INI-03).

## Out of scope

Redirect/visit recording, analytics reporting, custom domains, rate limiting. See the boundary
section in [README.md](./README.md).
