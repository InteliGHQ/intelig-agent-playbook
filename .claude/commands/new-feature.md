---
description: Scaffold a new spec-first feature work-item under product/features/ from the standard template.
argument-hint: <feature description>
---

Create a new feature work-item for: **$ARGUMENTS**

Do this:

1. Derive a short kebab-case `<slug>` from the description.
2. Read `product/features/create-short-link/` to mirror its shape exactly (README, requirements,
   design, tasks, acceptance).
3. Read `standards/STANDARDS_INDEX.md` and the families this feature will touch.
4. Hand off to the **architect** subagent to produce the four files in
   `product/features/<slug>/`. The architect must fill in real content — a user story, EARS
   acceptance criteria, a domain model with cited rule IDs, a phased task table, and a hard
   "what this is NOT" boundary. No placeholders.
5. Map the feature to an initiative in `product/initiatives.md` (or propose a new one if none
   fits — but keep initiatives coarse, a handful per quarter).

Stop after the spec exists. Do not write implementation code — that's a separate session driven
by the spec you just wrote.
