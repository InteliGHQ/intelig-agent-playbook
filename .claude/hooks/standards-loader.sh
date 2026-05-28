#!/usr/bin/env bash
# SessionStart hook: prints the standards primer so every session starts knowing the rules
# exist and where they live. It does NOT inline the rules (that would bloat always-on context) —
# it points at them. The agent reads the full text on demand.
#
# Wired in .claude/settings.json for SessionStart (startup, resume, clear).
set -euo pipefail

cat <<'PRIMER'
# Linkforge — Standards Primer

Engineering rules apply to every code edit in this repo.

1. Before writing code in an area, read the matching family. Start at
   `standards/STANDARDS_INDEX.md` (work-type → families), skim `standards/STANDARDS_DIGEST.md`
   (one line per rule), open the `*.rules.md` family for full text + the Enforcement Map.
2. Cite the rule ID when an edit triggers a rule (commit, PR, or a short code comment),
   e.g. `// DOM-002: factory method, no public constructor`.
3. Advisory vs enforced: rules tagged `fitness` are enforced by architecture tests the build
   runs — they are not optional. `manual-review` rules are advisory; you are the reviewer.
4. Features are spec-first: `product/features/<slug>/` holds requirements → design → tasks →
   acceptance. Implement one task at a time; stop at the acceptance gate.
PRIMER
