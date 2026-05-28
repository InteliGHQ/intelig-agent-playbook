#!/usr/bin/env bash
# PreToolUse gate — turns AGENTS.md directive #2 from advice into a wall.
#
# "Read the matching standards family BEFORE writing code in an area" is, by default, an advisory
# nudge the agent may ignore. This hook makes it structural: an Edit/Write/MultiEdit to
# implementation code is BLOCKED unless the standards were consulted earlier in the session.
# A PreToolUse hook denies a call by exiting 2 with the reason on stderr; the model sees that
# reason, reads the standards, and retries. That is the advisory→enforced move this repo preaches.
#
# Wired in .claude/settings.json: PreToolUse matcher "Edit|Write|MultiEdit".
#
# HONEST LIMITATION (on brand for this repo): this enforces "did you consult the standards this
# session" — it scans the session transcript for a read of STANDARDS_INDEX / STANDARDS_DIGEST /
# architecture.rules — NOT "did you read the *exact* matching family." Per-family proof isn't
# cheaply checkable from a stateless hook, and claiming it would be an overclaim. The gate is
# deliberately permissive: it fails OPEN (allows) whenever data is missing or ambiguous, so it
# nudges without becoming a nuisance. Tighten it only if you can actually verify the stronger claim.
set -euo pipefail

PAYLOAD=$(cat)

# Parse just the fields we need. python3 is already a dependency (initiatives-loader.sh); this
# avoids requiring jq. Any parse failure leaves the var empty → the gate fails open below.
jqp() { printf '%s' "$PAYLOAD" | python3 -c "$1" 2>/dev/null || true; }
TOOL=$(jqp 'import sys,json; print(json.load(sys.stdin).get("tool_name",""))')
FILE=$(jqp 'import sys,json; d=json.load(sys.stdin); print((d.get("tool_input") or {}).get("file_path",""))')
TRANSCRIPT=$(jqp 'import sys,json; print(json.load(sys.stdin).get("transcript_path",""))')

# Only gate edits to implementation code under an example's src/.
# Specs, standards, docs, config, and tests are intentionally NOT gated.
case "$TOOL" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

case "$FILE" in
  */examples/*/src/*.ts|*/examples/*/src/*.tsx|*/examples/*/src/*.js|*/examples/*/src/*.jsx|*/examples/*/src/*.mjs) ;;
  *) exit 0 ;;
esac

# Satisfied if the standards were consulted this session (heuristic; fails open on missing data).
if [[ -n "$TRANSCRIPT" && -f "$TRANSCRIPT" ]]; then
  if grep -Eq 'STANDARDS_INDEX\.md|STANDARDS_DIGEST\.md|architecture\.rules\.md' "$TRANSCRIPT"; then
    exit 0
  fi
else
  exit 0
fi

# Block: no standards consulted yet this session.
cat >&2 <<EOF
[standards-gate] Blocked editing $(basename "$FILE") — standards not consulted yet this session.

AGENTS.md directive #2: read the matching standards family BEFORE writing code in an area.
Do this first, then retry the edit:
  1. standards/STANDARDS_INDEX.md  → which families apply to this change
  2. standards/STANDARDS_DIGEST.md → one line per rule (or architecture.rules.md for full text)
Then cite the rule IDs your edit triggers (e.g. // DOM-002).
EOF
exit 2
