# src — where you build

This is the application source root. The rest of the repo tells you *what* to build and *how*; this
is where the code actually goes. Clone the repo and start here.

## Start building (the first work-item)

1. **Read the spec.**
   [`product/domains/customer/work-items/register-customer/`](../product/domains/customer/work-items/register-customer/)
   — read `requirements → design → tasks`, then implement `tasks.md` one commit at a time and
   **stop at `acceptance.md`**.
2. **Read the standards** for what you're touching — start at
   [`../standards/STANDARDS_INDEX.md`](../standards/STANDARDS_INDEX.md). (The `standards-gate` hook
   blocks your first `src/` edit until you have — that's by design, not a bug.)
3. **Shape the context** by complexity: pick flat CQRS, feature-driven, or core + features — see
   [`../arch-examples/`](../arch-examples/README.md). The first context's code lives in `src/customer/`.
4. **Cite rule IDs** where they clarify intent (`// DOM-002`) and tag the initiative in commits
   (`(INI-01)`).

## Layout

Code is organized **by bounded context**, then by the slice pattern the context's complexity calls
for (see [`../arch-examples/`](../arch-examples/README.md)):

```
src/
└── customer/            ← first bounded context (mirrors product/domains/customer/)
    ├── …                  flat CQRS, or feature/<slice>/, or core/ + feature/
    └── test/             ← the context's fitness tests (ARCH / DOM / API …)
```

> Status: empty on purpose — this is the starting line. The build/test setup (`npm`, etc.) and the
> first context are yours to add as you follow the spec. That's the whole point: clone, and go.
