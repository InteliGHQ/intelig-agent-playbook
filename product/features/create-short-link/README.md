# Feature: Create Short Link

> Initiative: INI-01 Click Analytics · Status: SPEC READY · Example feature for the playbook

## TL;DR

A user submits a long URL (optionally a desired code) and gets back a short link. This is the
write side of Linkforge and the seed of the event stream that Click Analytics (INI-01) reports
on. It's deliberately small — the point is to show the *shape* of a clean vertical slice, not to
be impressive.

## The spec, in order

An agent should read these top-to-bottom, then implement one task at a time, stopping at the
acceptance gate. This is the spec-driven pattern (`requirements → design → tasks → acceptance`)
that GitHub Spec Kit and AWS Kiro converged on.

| File | What it pins down |
|---|---|
| [requirements.md](./requirements.md) | The behavior, as testable acceptance criteria (EARS style) |
| [design.md](./design.md) | The domain model, the CQRS messages, which rules apply |
| [tasks.md](./tasks.md) | The build, as phases — each phase is one commit with a risk rating |
| [acceptance.md](./acceptance.md) | The executable gate: exact commands that prove it's done |

## What this is NOT

- **Not redirect/visit handling.** Recording a visit is a separate feature (`record-visit`); this
  one only *creates* the link. Keeping them separate keeps each slice one-aggregate, one-purpose.
- **Not analytics.** Reporting clicks is the read side (INI-01's `GetShortLinkStatsQuery`), spec'd
  elsewhere. This feature only produces the `ShortLinkCreatedEvent` that analytics later folds.
- **Not custom domains.** That's INI-02. A code here resolves under the default domain only.
- **Not auth/quota.** Abuse protection is INI-03 (PLANNED). Assume a trusted caller for now.

Defining the boundary is half the spec. Most agent over-build comes from an unstated "while I'm
here…" — so it's stated here, explicitly, as out of scope.
