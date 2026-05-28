# Architecture Patterns (TypeScript reference)

What compliant code looks like. The rules in [`architecture.rules.md`](./architecture.rules.md)
are language-agnostic; these are one concrete reference in TypeScript. The same shapes apply in
Java, Go, C#, etc. — only the syntax changes.

## A vertical slice

```
features/register-customer/
├── api/            register-customer.controller.ts       # API-001: thin
├── application/
│   ├── command/    register-customer.command.ts           # CQRS-003: imperative name
│   └── handler/    register-customer.handler.ts           # CQRS-002: one handler
├── domain/
│   ├── model/      customer.ts                             # the aggregate
│   ├── model/      email-address.ts  company-name.ts       # DOM-003: value objects
│   └── event/      customer-registered.event.ts            # ES-001: past-tense fact
└── infrastructure/ customer.repository.ts                  # ARCH-003: implements a domain port
```

## Aggregate — factory creation, events, no setters (DOM-002, DOM-004)

```ts
// domain/model/customer.ts
export class Customer {
  private constructor(                       // DOM-002: private — only the factory builds one
    readonly id: CustomerId,
    readonly companyName: CompanyName,
    readonly email: EmailAddress,
    private _status: CustomerStatus,
    private readonly _events: DomainEvent[],
  ) {}

  static register(name: CompanyName, email: EmailAddress): Customer {  // DOM-002: the one path in
    const customer = new Customer(CustomerId.next(), name, email, "PENDING", []);
    customer.raise(new CustomerRegisteredEvent(customer.id, name, email)); // DOM-004: change = event
    return customer;
  }

  activate(): void {                          // DOM-004: intent method, not setStatus("ACTIVE")
    if (this._status !== "PENDING") throw new IllegalCustomerTransition(this._status);
    this._status = "ACTIVE";
    this.raise(new CustomerActivatedEvent(this.id));
  }

  get status(): CustomerStatus { return this._status; }    // read ok; no public setter
  private raise(e: DomainEvent) { this._events.push(e); }
}
```

## Value object — immutable, validates on construction (DOM-003)

```ts
// domain/model/email-address.ts
export class EmailAddress {
  private constructor(readonly value: string) {}
  static of(raw: string): EmailAddress {
    const normalized = raw.trim().toLowerCase();
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(normalized)) throw new InvalidEmail(raw); // can't exist if invalid
    return new EmailAddress(normalized);
  }
}
```

## Command + handler — mutate, return id, one responsibility (CQRS-001, CQRS-002)

```ts
// application/command/register-customer.command.ts
export type RegisterCustomerCommand = { companyName: string; email: string };

// application/handler/register-customer.handler.ts
export class RegisterCustomerHandler {
  constructor(private readonly customers: CustomerRepository) {}  // ARCH-003: depends on the port
  async handle(cmd: RegisterCustomerCommand): Promise<CustomerId> {
    const customer = Customer.register(                            // DOM-001: invariant lives in the aggregate
      CompanyName.of(cmd.companyName),
      EmailAddress.of(cmd.email),
    );
    await this.customers.save(customer);
    return customer.id;                                           // CQRS-001: returns id, no query data
  }
}
```

## Controller — thin, no business logic (API-001, API-002)

```ts
// api/register-customer.controller.ts
export async function registerCustomer(req: Request, res: Response) {
  const dto = parseRegisterCustomer(req.body);         // API-002: DTO in
  const id = await handler.handle({ companyName: dto.companyName, email: dto.email });
  res.status(201).json({ id: id.value });              // map result out — no domain decisions here
}
```

## Port + adapter — domain declares, infrastructure implements (ARCH-003)

```ts
// domain/model/customer.repository.ts   (the PORT — lives in domain)
export interface CustomerRepository { save(customer: Customer): Promise<void>; }

// infrastructure/customer.repository.ts  (the ADAPTER — depends on domain, never the reverse)
export class PgCustomerRepository implements CustomerRepository { /* … */ }
```

## TS family quick rules
- `TS-001` strict mode, no unjustified `any`.
- `TS-002` throw typed errors at boundaries; never swallow.
- `TS-003` name files for the concept (`customer.ts`), not the layer.
