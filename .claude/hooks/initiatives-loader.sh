#!/usr/bin/env bash
# SessionStart hook: injects the active strategic initiatives into the session so the agent
# knows WHY work exists and can tag commits/branches to the right goal.
#
# Two modes, one contract ("print the active initiatives + the conventions"):
#
#   • STATIC  (default) — read the committed product/initiatives.md. No API, no credentials,
#     no network: a clone Just Works, offline, forever. This is the public, forkable behavior.
#
#   • DYNAMIC (opt-in)  — if INITIATIVES_API_URL is set, fetch live strategy from that endpoint
#     (optional bearer key in INITIATIVES_API_KEY), cache it for an hour, and fall back to the
#     STATIC file on any failure. This mirrors how a real strategy API feeds sessions; the
#     output shape is identical to STATIC, so nothing downstream knows which mode produced it.
#
# Enable dynamic for a demo with, e.g.:
#   export INITIATIVES_API_URL="https://api.example.com/strategy/initiatives"
#   export INITIATIVES_API_KEY="$(security find-generic-password -a "$USER" -s my-key -w)"
#
# Wired in .claude/settings.json for SessionStart (startup, resume, clear).
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
SRC="$ROOT/product/initiatives.md"
CACHE="${TMPDIR:-/tmp}/agent-playbook-initiatives.cache.md"
CACHE_TTL=3600

emit_header() {
  echo "# Active Initiatives (auto-loaded)"
  echo
  echo "Tag work to strategy so code links back to *why* it exists:"
  echo "- commit \`<type>(<scope>): <description> (INI-XX)\` — e.g. \`feat(domain): emit CustomerRegisteredEvent on registration (INI-01)\`"
  echo "- branch \`<type>/<work-item>\` — e.g. \`feat/register-customer\`"
}

emit_table_from_file() {
  echo "| ID | Name | Status | Quarter |"
  echo "|---|---|---|---|"
  # Pull only ACTIVE / PLANNED rows out of the markdown table; skip DONE and the header.
  grep -E '^\| *INI-[0-9]+ *\|' "$SRC" \
    | grep -E '\| *(ACTIVE|PLANNED) *\|' \
    || echo "| — | (no active initiatives) | — | — |"
}

# ── STATIC fallback: committed file. Also the default when dynamic is off/unavailable. ──
emit_static() {
  [[ -f "$SRC" ]] || exit 0   # no initiatives file → start cleanly, say nothing
  emit_header
  echo
  emit_table_from_file
}

# ── DYNAMIC: opt-in via INITIATIVES_API_URL. Any failure falls through to STATIC. ──────
if [[ -n "${INITIATIVES_API_URL:-}" ]] && command -v curl >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then

  # Serve a fresh cache without touching the network.
  if [[ -f "$CACHE" ]]; then
    MTIME=$(stat -f %m "$CACHE" 2>/dev/null || stat -c %Y "$CACHE" 2>/dev/null || echo 0)
    if [[ $(( $(date +%s) - MTIME )) -lt $CACHE_TTL ]]; then
      cat "$CACHE"
      exit 0
    fi
  fi

  # Fetch. Build the call without empty-array expansion (portable to macOS bash 3.2).
  if [[ -n "${INITIATIVES_API_KEY:-}" ]]; then
    JSON=$(curl -sS --max-time 5 -H "Authorization: ApiKey ${INITIATIVES_API_KEY}" "$INITIATIVES_API_URL" 2>/dev/null) || JSON=""
  else
    JSON=$(curl -sS --max-time 5 "$INITIATIVES_API_URL" 2>/dev/null) || JSON=""
  fi

  if [[ -n "$JSON" ]]; then
    TMP=$(mktemp)
    {
      emit_header
      echo
      echo "| ID | Name | Status | Quarter |"
      echo "|---|---|---|---|"
      printf '%s' "$JSON" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    items = d.get("data", d) if isinstance(d, dict) else d
    rows = [(i.get("id"), i.get("name", "?"), i.get("status", "?"),
             ("%s %s" % (i.get("targetQuarter", ""), i.get("targetYear", ""))).strip())
            for i in items if i.get("status") in ("ACTIVE", "PLANNED")]
    rows.sort(key=lambda r: -(r[0] or 0))
    for r in rows:
        print("| INI-%s | %s | %s | %s |" % r)
except Exception as e:
    print("| — | (parse error: %s) | — | — |" % e)
'
    } > "$TMP"

    # Promote to cache only if it really produced initiative rows (guards against junk/empty).
    if grep -q '^| INI-' "$TMP"; then
      cp "$TMP" "$CACHE"
      cat "$TMP"
      rm -f "$TMP"
      exit 0
    fi
    rm -f "$TMP"
  fi
  # Dynamic path failed (network, auth, empty, or unparseable) → degrade to STATIC below.
fi

emit_static
