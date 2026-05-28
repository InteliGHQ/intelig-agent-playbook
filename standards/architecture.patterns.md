# Architecture Patterns (TypeScript reference)

What compliant code looks like. The rules in [`architecture.rules.md`](./architecture.rules.md)
are language-agnostic; these are one concrete reference in TypeScript. The same shapes apply in
Java, Go, C#, etc. — only the syntax changes.

## A vertical slice

```
features/create-short-link/
├── api/            create-short-link.controller.ts      # API-001: thin
├── application/
│   ├── command/    create-short-link.command.ts          # CQRS-003: imperative name
│   └── handler/    create-short-link.handler.ts          # CQRS-002: one handler
├── domain/
│   ├── model/      short-link.ts                          # the aggregate
│   ├── model/      short-code.ts  target-url.ts           # DOM-003: value objects
│   └── event/      short-link-created.event.ts            # ES-001: past-tense fact
└── infrastructure/ short-link.repository.ts               # ARCH-003: implements a domain port
```

## Aggregate — factory creation, events, no setters (DOM-002, DOM-004)

```ts
// domain/model/short-link.ts
export class ShortLink {
  private constructor(                       // DOM-002: private — only the factory builds one
    readonly id: ShortLinkId,
    readonly code: ShortCode,
    readonly target: TargetUrl,
    private _visits: number,
    private readonly _events: DomainEvent[],
  ) {}

  static create(code: ShortCode, target: TargetUrl): ShortLink {   // DOM-002: the one path in
    const link = new ShortLink(ShortLinkId.next(), code, target, 0, []);
    link.raise(new ShortLinkCreatedEvent(link.id, code, target));  // DOM-004: state change = event
    return link;
  }

  recordVisit(): void {                       // DOM-004: intent method, not setVisits()
    this._visits += 1;
    this.raise(new VisitRecordedEvent(this.id, new Date()));
  }

  get visits(): number { return this._visits; }            // read ok; no public setter
  private raise(e: DomainEvent) { this._events.push(e); }
}
```

## Value object — immutable, validates on construction (DOM-003)

```ts
// domain/model/short-code.ts
export class ShortCode {
  private constructor(readonly value: string) {}
  static of(raw: string): ShortCode {
    if (!/^[A-Za-z0-9_-]{4,10}$/.test(raw)) throw new InvalidShortCode(raw); // can't exist if invalid
    return new ShortCode(raw);
  }
}
```

## Command + handler — mutate, return id, one responsibility (CQRS-001, CQRS-002)

```ts
// application/command/create-short-link.command.ts
export type CreateShortLinkCommand = { target: string; desiredCode?: string };

// application/handler/create-short-link.handler.ts
export class CreateShortLinkHandler {
  constructor(private readonly links: ShortLinkRepository) {}  // ARCH-003: depends on the port
  async handle(cmd: CreateShortLinkCommand): Promise<ShortLinkId> {
    const link = ShortLink.create(                              // DOM-001: invariant lives in the aggregate
      cmd.desiredCode ? ShortCode.of(cmd.desiredCode) : ShortCode.random(),
      TargetUrl.of(cmd.target),
    );
    await this.links.save(link);
    return link.id;                                            // CQRS-001: returns id, no query data
  }
}
```

## Controller — thin, no business logic (API-001, API-002)

```ts
// api/create-short-link.controller.ts
export async function createShortLink(req: Request, res: Response) {
  const dto = parseCreateShortLink(req.body);          // API-002: DTO in
  const id = await handler.handle({ target: dto.target, desiredCode: dto.code });
  res.status(201).json({ id: id.value });              // map result out — no domain decisions here
}
```

## Port + adapter — domain declares, infrastructure implements (ARCH-003)

```ts
// domain/model/short-link.repository.ts   (the PORT — lives in domain)
export interface ShortLinkRepository { save(link: ShortLink): Promise<void>; }

// infrastructure/short-link.repository.ts  (the ADAPTER — depends on domain, never the reverse)
export class PgShortLinkRepository implements ShortLinkRepository { /* … */ }
```

## TS family quick rules
- `TS-001` strict mode, no unjustified `any`.
- `TS-002` throw typed errors at boundaries; never swallow.
- `TS-003` name files for the concept (`short-link.ts`), not the layer.
