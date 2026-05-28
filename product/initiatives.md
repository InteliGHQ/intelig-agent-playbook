# Initiatives — Customer Platform

Strategic work, coarse-grained (a handful per quarter, not a backlog). The session hook
(`.claude/hooks/initiatives-loader.sh`) reads this file and prints the active ones at the start
of every session, so the agent knows *why* the work exists and can tag commits to it.

This is the one source the hook parses. The format is fixed: a table with `ID | Name | Status |
Quarter`. Keep it short.

| ID | Name | Status | Quarter |
|---|---|---|---|
| INI-01 | Customer Onboarding | ACTIVE | Q2 2026 |
| INI-02 | Self-Serve Signup | ACTIVE | Q2 2026 |
| INI-03 | Lifecycle Automation | PLANNED | Q3 2026 |
| INI-04 | Account Health Signals | PLANNED | Q3 2026 |
| INI-05 | Legacy Customer Import | DONE | Q1 2026 |

## How linking works (and the honest caveat)

Tag work with the initiative ID in the commit subject:

```
feat(domain): emit CustomerRegisteredEvent on registration (INI-01)
```

The payoff is **context, not magic**: the agent loads the active initiatives every session, so
it tags new work to the right goal and you can later answer "what have we shipped toward Customer
Onboarding?" by grepping commit subjects for `(INI-01)`.

> **Honest note for anyone copying this pattern:** a commit *tag* only links code to strategy if
> something actually reads the tag. In this repo, the link is the convention + the grep. If you
> build an automated linker, verify end-to-end that it keys off the tag — it's easy to ship a
> linker that silently links on something else (repo, author, keywords) and leaves your tags
> decorative. Don't claim auto-linking you haven't watched fire.

## Static vs dynamic loading

The session hook (`.claude/hooks/initiatives-loader.sh`) has two modes behind one identical output:

- **Static (default).** It reads *this file*. No API, no credentials, no network — a clone works
  offline, forever. This is the forkable default.
- **Dynamic (opt-in).** Set `INITIATIVES_API_URL` (and optionally `INITIATIVES_API_KEY`) and the
  hook fetches your live strategy from that endpoint, caches it for an hour, and **falls back to
  this file** on any failure. Same output shape, so nothing downstream can tell which mode ran.

The contract is identical either way — *print the active initiatives + the conventions* — so
flipping a repo from a committed file to a live strategy API is a one-env-var change, not a
rewrite. Dynamic mode only changes *where the list comes from*; it still does **not** auto-link
your commits. Wiring commits, PRs, and branches to initiatives automatically — via a matcher chain
over file globs, branch prefixes, and message keywords — is a product problem, not a hook (see the
honest note above).
