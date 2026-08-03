#!/usr/bin/env bash
# POC gate for the Trunk Merge Queue — BISECTION / culprit-ejection scenario.
#
# Convention: each PR adds its OWN file changes/pr-<name>.txt containing a single
# line `VALUE=<number>`. Because every PR touches a *different* file, PRs never
# cause a git conflict when the queue stacks/batches them together.
#
# Invariant: every VALUE across all changes/*.txt must be UNIQUE.
#   - A PR tested ALONE (only its own VALUE present) always PASSES.
#   - A COMBINATION FAILS only if two PRs declare the SAME value — an emergent
#     conflict that neither PR shows on its own. That is exactly what a merge
#     queue exists to catch, and what forces the culprit-hunt (bisection).
set -euo pipefail

echo "Checking VALUE uniqueness across changes/ ..."
vals=$(grep -rhoE '^VALUE=[0-9]+' changes 2>/dev/null | sort)
dups=$(printf '%s\n' "$vals" | uniq -d)

if [ -n "$dups" ]; then
  echo "::error::Duplicate VALUE(s) detected — this combination conflicts:"
  printf '%s\n' "$dups"
  echo "-- offending files --"
  for d in $dups; do grep -rl "^${d}$" changes; done
  exit 1
fi

echo "All VALUEs unique - no conflict."
exit 0
