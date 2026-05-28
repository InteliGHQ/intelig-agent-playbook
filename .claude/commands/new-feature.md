---
description: Scaffold a new spec-first feature work-item under product/domains/<domain>/ from the standard template.
argument-hint: <feature description>
---

Create a new feature work-item for: **$ARGUMENTS**

Do this:

1. Determine the target domain (bounded context) and a short kebab-case `<work-item>` slug from
   the description. If it's unclear which existing domain owns this, ask before scaffolding.
2. Read `product/domains/customer/register-customer/` to mirror the work-item shape exactly
   (README, requirements, design, tasks, acceptance), and `product/domains/customer/README.md`
   for the domain-overview shape.
3. Read `standards/STANDARDS_INDEX.md` and the families this feature will touch.
4. Hand off to the **architect** subagent to produce the four files in
   `product/domains/<domain>/<work-item>/`. If the domain is new, the architect creates its
   `README.md` context overview first. The architect must fill in real content — a user story,
   EARS acceptance criteria, a domain model with cited rule IDs, a phased task table, and a hard
   "what this is NOT" boundary. No placeholders.
5. Map the feature to an initiative in `product/initiatives.md` (or propose a new one if none
   fits — but keep initiatives coarse, a handful per quarter).

Stop after the spec exists. Do not write implementation code — that's a separate session driven
by the spec you just wrote.
