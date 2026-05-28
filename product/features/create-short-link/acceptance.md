# Acceptance Gate — Create Short Link

The feature is done when **every command below passes**. This is the executable definition of
"done" — not a vibe, a gate. An agent should run these and stop; a reviewer should re-run them.

Run from whichever example you're implementing in (`examples/monolith` or `examples/microservice`).

## Behavior (maps to requirements.md)

```bash
npm test -- create-short-link        # all acceptance criteria #1–#6 covered by unit/integration tests
```

Each EARS criterion has a named test:
- `creates a link and returns id+code for a valid URL`            → req #1
- `uses a valid available desired code`                           → req #2
- `rejects an invalid target URL, persists nothing`               → req #3
- `rejects a duplicate code with a conflict`                      → req #4
- `rejects a malformed desired code`                              → req #5
- `emits exactly one ShortLinkCreatedEvent`                       → req #6

## Structure & rules (the fitness functions)

```bash
npm test -- architecture.fitness     # the rules the code cannot violate
```

Must be green:
- **ARCH-001/004** — no file under `domain/**` imports from `api/**`, `infrastructure/**`, or any framework/SDK.
- **DOM-002** — no exported aggregate class exposes a public constructor.
- **DOM-004** — no aggregate exposes a public setter.
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
