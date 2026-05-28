# The Multi-Repo Fleet Variant

This repo is the **single-repo** version of the playbook, tuned for clarity: standards, product,
and tooling all sit at the root where a visitor sees them immediately. That's the right shape for
teaching, and for most projects.

When you outgrow it — when you run *many* repos that must share one set of standards — the shape
changes. This is the genuinely hard version, and it's worth understanding even if you never need
it.

## The problem a fleet has

You have, say, a backend, a frontend, an infra repo, and a website. They must obey the *same*
engineering standards and reference the *same* product context. If each repo keeps its own copy,
the copies drift, and "the standards" stop meaning anything.

## The pattern

1. **One knowledge repo is canonical.** A dedicated repo (e.g. `knowledge/`) holds the standards,
   the product/initiative context, and a *lean* shared-context block. Nothing else is allowed to
   author standards — other repos only reference.
2. **Each code repo's `AGENTS.md`/`CLAUDE.md` imports a synced block.** A small script copies the
   canonical lean block into a marked region of each repo's context file. The copies are
   generated, never hand-edited; a `--check` mode runs in CI to fail a build if a copy has
   drifted from canon.
3. **Standards live once, are read everywhere.** A repo's context file points at the shared
   `standards/` (vendored or submoduled), so the digest/index/rules have a single source of truth.

```
fleet/
├── knowledge/                 ← canonical: standards/, product/, SHARED-CONTEXT.md
│   └── scripts/sync.sh        ← writes the lean block into each repo (--check in CI)
├── backend/   CLAUDE.md        ← @imports the synced block
├── frontend/  CLAUDE.md        ← @imports the synced block
└── website/   CLAUDE.md        ← @imports the synced block
```

## Why the single-repo version drops all of this

In one repo there's no second copy to drift, so the sync script is pure overhead. There,
`CLAUDE.md` is just `@AGENTS.md` (a one-line import or a symlink) — zero drift, zero machinery.
**Use the simplest thing that can't drift.** Reach for the fleet pattern only when you actually
have a fleet.

## Honest cost

The sync-and-check machinery is real work to build and maintain. Don't adopt it speculatively —
it earns its keep at roughly the third repo that shares standards, not the first.
