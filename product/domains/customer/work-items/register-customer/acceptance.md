# Acceptance Gate — Register Customer

The feature is done when **every command below passes**. This is the executable definition of
"done" — not a vibe, a gate. An agent should run these and stop; a reviewer should re-run them.

Run from the bounded context you're implementing in (see [`arch-examples/`](../../../../../arch-examples/README.md) for the structure — flat, feature-driven, or core + features).

## Behavior (maps to requirements.md)

```bash
npm test -- register-customer        # all acceptance criteria #1–#6 covered by unit/integration tests
```

Each EARS criterion has a named test:
- `registers a pending customer and returns id for valid input`   → req #1
- `rejects an invalid email, persists nothing`                    → req #2
- `rejects a blank or over-long company name`                     → req #3
- `rejects a duplicate email with a conflict`                     → req #4
- `emits exactly one CustomerRegisteredEvent`                     → req #5
- `new customer is always PENDING, never ACTIVE`                  → req #6

## Structure & rules (the fitness functions)

```bash
npm test -- architecture.fitness     # the rules the code cannot violate
```

Must be green:
- **ARCH-001/004** — no file under `domain/**` imports from `api/**`, `infrastructure/**`, or any framework/SDK.
- **DOM-002** — no exported aggregate class exposes a public constructor.
- **DOM-004** — no aggregate exposes a public setter (status changes only via `register`/`activate`).
- **API-001** — no file under `api/**` imports a `domain/**` type directly.
- **CQRS-002** — exactly one handler per command.

## Hygiene

```bash
npm run typecheck                    # TS-001: strict, no stray any
npm run lint                         # TS-003 naming, CQRS-003 message naming
```

## Done means

1. `npm test` green (behavior + fitness).
2. `npm run typecheck && npm run lint` clean.
3. Every commit on the feature cites its rule IDs and `(INI-01)`.
4. No code exists outside the boundary in [README.md](./README.md).
