#!/usr/bin/env bash
# Print a fitness-test stub for a rule ID, ready to paste into
# examples/<shape>/test/architecture.fitness.test.ts and fill in the predicate.
#
# Usage: scaffold.sh <RULE-ID> "<what it checks>"
#   e.g. scaffold.sh API-001 "controllers import no domain types"
set -euo pipefail

RULE="${1:?usage: scaffold.sh <RULE-ID> \"<what it checks>\"}"
DESC="${2:-describe the invariant this rule defends}"

cat <<EOF
// ${RULE}: ${DESC}
// Defends the principle behind ${RULE} — see standards/architecture.rules.md.
test("${RULE}: ${DESC}", () => {
  const offenders = sourceFiles("src/**/*.ts").filter(
    // TODO: express the violation as a predicate (prefer dependency-cruiser/ts-arch
    //       over raw string matching for import/dependency rules).
    (f) => false,
  );
  expect(
    offenders,
    \`${RULE} violated by:\n\${offenders.join("\n")}\`,
  ).toEqual([]);
});
EOF
