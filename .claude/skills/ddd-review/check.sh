#!/usr/bin/env bash
# Deterministic DDD checks (heuristic, string-level) against this repo's standards.
# Usage: check.sh [path]      — defaults to src/
#
# Hits are LEADS, not proof; a clean run does NOT mean compliant. The judgment rules
# (DOM-001, DOM-005, CQRS-004, API-002/003, over-engineering) are for a human/reviewer — see SKILL.md.
# For a real gate, back these checks with the architecture fitness tests (fitness-test skill).
set -uo pipefail
ROOT="${1:-src}"

if [ ! -e "$ROOT" ]; then
  echo "ddd-review: '$ROOT' not found — nothing to check yet (src/ is a skeleton until you build)."
  exit 0
fi

# Print a section header, then the piped matches — or "(no candidates)" when empty.
report() {
  printf '\n=== %s ===\n' "$1"
  if IFS= read -r line; then
    printf '%s\n' "$line"
    cat
  else
    echo "  (no candidates)"
  fi
}

# DOM-002 — a domain model constructor should be private (create via a static factory).
grep -rnE 'constructor[[:space:]]*\(' "$ROOT" --include='*.ts' 2>/dev/null \
  | grep -E '/(domain|core)/' | grep -v 'private constructor' \
  | report "DOM-002  non-private constructor in a domain model (use a static factory)"

# DOM-004 — no public setters on aggregates; mutate via intent methods that emit events.
grep -rnE 'set[A-Z][A-Za-z0-9]*[[:space:]]*\(' "$ROOT" --include='*.ts' 2>/dev/null \
  | grep -E '/(domain|core)/' \
  | report "DOM-004  setter on a domain model (mutate via intent methods that emit events)"

# ARCH-001/004 — domain must not import api/, infrastructure/, or a framework/ORM.
grep -rnE "from[[:space:]]+[\"'][^\"']*(/api/|/infrastructure/|express|typeorm|@nestjs|sequelize|mongoose)" "$ROOT" --include='*.ts' 2>/dev/null \
  | grep -E '/domain/' \
  | report "ARCH-001/004  domain importing outward (api / infrastructure / framework)"

# API-001 — controllers must not import a domain type directly.
grep -rnE "from[[:space:]]+[\"'][^\"']*/domain/" "$ROOT" --include='*.ts' 2>/dev/null \
  | grep -E '/api/' \
  | report "API-001  api/ importing a domain type directly"

echo
echo "Heuristic pass done — leads, not proof. Now handle the judgment rules by reading the code:"
echo "DOM-001 (invariant in the aggregate), DOM-005 (one aggregate per command), CQRS-004 (queries"
echo "read projections), API-002/003 (DTOs + central error mapping), over-engineering. See SKILL.md."
