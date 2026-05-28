# Design — Create Short Link

Read [`standards/architecture.rules.md`](../../../standards/architecture.rules.md) before
implementing. The rule IDs each decision triggers are cited inline.

## Domain model

- **`ShortLink`** (aggregate) — created via `ShortLink.create(code, target)` (`DOM-002`). Holds
  `id`, `code`, `target`, `visits` (starts 0). State changes only through methods that emit
  events (`DOM-004`). Invariant — a link always has a valid code and target (`DOM-001`).
- **`ShortCode`** (value object) — 4–10 url-safe chars, validated on construction (`DOM-003`).
  `ShortCode.of(raw)` for a desired code; `ShortCode.random()` to generate.
- **`TargetUrl`** (value object) — a valid absolute `http(s)` URL, validated on construction
  (`DOM-003`).
- **`ShortLinkId`** (value object) — opaque identity, generated.

## Events (`ES-001`)

- **`ShortLinkCreatedEvent`** — `{ id, code, target, occurredAt }`. The single fact this feature
  produces. Click Analytics (INI-01) and the read projection both fold from here.

## CQRS messages

- **`CreateShortLinkCommand`** `{ target: string, desiredCode?: string }` (`CQRS-003`).
- **`CreateShortLinkHandler`** — one handler (`CQRS-002`): build the value objects (validation
  happens there), call `ShortLink.create`, persist, return the new id (`CQRS-001`). It
  orchestrates; it makes no domain decisions itself (`DOM-001`).
- No query in this feature — reads belong to the analytics slice (`CQRS-004`).

## Persistence (`ARCH-003`)

- The domain declares the port `ShortLinkRepository { save(link): Promise<void> }`.
- Infrastructure provides the adapter (in-memory for tests; Postgres in the examples). The
  adapter depends on the domain interface, never the reverse (`ARCH-001`, `ARCH-004`).
- Uniqueness of `code` is a DB constraint (`DB-003`), surfaced as the conflict error in
  requirement #4 — not a read-then-write check that races.

## Transport (`API-001`, `API-002`)

- `POST /links` → parse a `CreateShortLinkRequest` DTO, call the handler, return `201` with
  `{ id, code }`. Validation errors → `400`, conflict → `409`, mapped centrally (`API-003`).

## Why this shape

Everything that can be wrong about a short link is unrepresentable: you cannot construct an
invalid `ShortCode` or `TargetUrl`, and you cannot build a `ShortLink` except through the
factory that validates and emits the event. The handler has no room to "decide" anything, which
is exactly why it's boring — and boring handlers are the goal.
