#!/usr/bin/env bash
# SessionStart hook: injects the active strategic initiatives into the session so the agent
# knows WHY work exists and tags commits to the right goal.
#
# This is the public, self-contained version of the pattern: it reads a local file
# (product/initiatives.md) — no API, no credentials, no network. Anyone who clones the repo
# gets the behavior for free. (In a real product you'd point this at your strategy API instead;
# the contract — "print active initiatives + the commit convention" — stays identical.)
#
# Wired in .claude/settings.json for SessionStart (startup, resume, clear).
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
SRC="$ROOT/product/initiatives.md"
[[ -f "$SRC" ]] || exit 0   # no initiatives file → start cleanly, say nothing

echo "# Active Initiatives (auto-loaded)"
echo
echo "Cite the initiative ID in commit subjects so code links back to strategy — e.g."
echo '`feat(domain): record click event on visit (INI-01)`.'
echo
echo "| ID | Name | Status | Quarter |"
echo "|---|---|---|---|"
# Pull only ACTIVE / PLANNED rows out of the markdown table; skip DONE and the header.
grep -E '^\| *INI-[0-9]+ *\|' "$SRC" \
  | grep -E '\| *(ACTIVE|PLANNED) *\|' \
  || echo "| — | (no active initiatives) | — | — |"
echo
echo "Commit convention: \`<type>(<scope>): <description> (INI-XX)\`."
