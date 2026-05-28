# Initiatives — Linkforge

Strategic work, coarse-grained (a handful per quarter, not a backlog). The session hook
(`.claude/hooks/initiatives-loader.sh`) reads this file and prints the active ones at the start
of every session, so the agent knows *why* the work exists and can tag commits to it.

This is the one source the hook parses. The format is fixed: a table with `ID | Name | Status |
Quarter`. Keep it short.

| ID | Name | Status | Quarter |
|---|---|---|---|
| INI-01 | Click Analytics | ACTIVE | Q2 2026 |
| INI-02 | Custom Domains | ACTIVE | Q2 2026 |
| INI-03 | Abuse & Rate-Limit Protection | PLANNED | Q3 2026 |
| INI-04 | Public Stats API | PLANNED | Q3 2026 |
| INI-05 | Bulk Import | DONE | Q1 2026 |

## How linking works (and the honest caveat)

Tag work with the initiative ID in the commit subject:

```
feat(domain): record click event on visit (INI-01)
```

The payoff is **context, not magic**: the agent loads the active initiatives every session, so
it tags new work to the right goal and you can later answer "what have we shipped toward Click
Analytics?" by grepping commit subjects for `(INI-01)`.

> **Honest note for anyone copying this pattern:** a commit *tag* only links code to strategy if
> something actually reads the tag. In this repo, the link is the convention + the grep. If you
> build an automated linker, verify end-to-end that it keys off the tag — it's easy to ship a
> linker that silently links on something else (repo, author, keywords) and leaves your tags
> decorative. Don't claim auto-linking you haven't watched fire.
