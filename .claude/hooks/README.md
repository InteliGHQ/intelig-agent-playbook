# Hooks — what runs automatically, and why

These are small shell scripts Claude Code runs on its own at certain moments (all wired in
[`../settings.json`](../settings.json)). They exist so the engineering standards aren't just
*written down* — they're *active* in every session.

The whole idea, in plain English, is three escalating steps: **define → remind → enforce.**

### 1. Define — `standards/*.md` *(not a hook, but the foundation)*
The standards files say what "good" is. Each rule has an ID like `DOM-002`, so "that's wrong" becomes
a citable fact instead of a matter of taste. Everything below points back to this definition.
**Value:** a shared, checkable definition of correct.

### 2. Remind — `standards-loader.sh` *(runs at session start)*
Every time a session starts, this prints a short primer: the rules exist, here's where to find them,
cite the IDs. It deliberately does **not** paste the rules in — that would bloat every single turn —
it just points at them. **Value:** awareness. The agent can't say "I didn't know the rules were there."

> `initiatives-loader.sh` runs alongside it and does the same thing for *strategy*: it prints the
> active initiatives so the agent knows *why* the work exists. By default it reads the committed
> `product/initiatives.md`; set `INITIATIVES_API_URL` and it pulls from a live strategy API instead,
> falling back to the file if that's unavailable.

### 3. Enforce — `standards-gate.sh` *(runs right before an edit)*
Before the agent edits source code, this checks whether the standards were actually opened this
session. If they weren't, it **blocks the edit** and tells the agent to go read them first. The agent
reads, then retries. **Value:** compliance. The agent can't skip the rules even if it wanted to.

> **Honest limit:** it checks that the standards were *consulted*, not that the exact right family was
> read — and when it's unsure it lets the edit through. It's a nudge with teeth, not a tripwire.

## Why three steps?

Each one assumes the previous wasn't enough. Defining "good" doesn't mean anyone reads it; reminding
doesn't mean anyone follows it; only the gate makes skipping *impossible*. That progression —
**advisory → enforced** — is the core idea of the whole repo: don't ask the agent to be good, make
wrong structurally hard.

## The files at a glance

| File | When it runs | What it does |
|---|---|---|
| `standards-loader.sh` | session start | prints the standards primer (the "remind" step) |
| `initiatives-loader.sh` | session start | prints active initiatives — from the file or a live API |
| `standards-gate.sh` | before Edit/Write/MultiEdit | blocks a `src/` edit until the standards were consulted (the "enforce" step) |
