# Example: Microservice

The *same* Create-Short-Link feature, deployed as its own service with its own database and an
event bus to talk to the rest of Linkforge. Same spec, same standards, same domain model — only
the deployment shape and the integration seams change.

```
examples/microservice/
├── src/
│   ├── api/               POST /links  (HTTP boundary)
│   ├── application/       command/ handler/
│   ├── domain/            model/ event/   (identical to the monolith's slice)
│   └── infrastructure/    pg repository + event publisher (publishes ShortLinkCreatedEvent)
├── test/
│   └── architecture.fitness.test.ts
└── migrations/
```

## What actually differs from the monolith

This is the whole point of having both examples side by side:

| | Monolith slice | Microservice |
|---|---|---|
| Domain model | **identical** | **identical** |
| Spec (`product/features/...`) | **identical** | **identical** |
| Fitness tests | **identical** | **identical** |
| `ShortLinkCreatedEvent` consumer | in-process call/handler | published to an event bus |
| Database | shared, one schema | owned, isolated |
| Failure modes | a function throws | network, retries, idempotency, partial failure |
| Deploy | one unit | independent |

The lesson: splitting into a service is *mostly* an infrastructure-and-integration change, not a
domain change. If your domain model has to be rewritten to extract a service, your monolith
wasn't modular — which is exactly what the `ARCH-*` fitness tests prevent.

## When to choose this shape

- Independent scaling or deploy cadence for this capability.
- A different team owns it.
- You can pay the distributed-systems tax (idempotency, eventual consistency, observability).

## Status

Skeleton. Implementation follows the same `tasks.md`, plus an event-publishing adapter where the
monolith uses an in-process handler.
