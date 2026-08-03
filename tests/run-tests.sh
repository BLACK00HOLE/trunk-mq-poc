#!/usr/bin/env bash
# Dummy test suite for the Trunk merge-queue POC.
#
# It simulates a real multi-test suite that takes a little time to run, so that
# speculative / batching / bisection behavior is actually observable.
#
# Same invariant as check.sh: every VALUE across changes/*.txt must be UNIQUE.
# A PR alone always passes; a COMBINATION fails only if two PRs share a value.
# The "orders_create" test is the one that enforces that invariant; every other
# test always passes.
set -uo pipefail

echo "Running dummy test suite (5 tests)..."
echo "-----------------------------------"

TESTS=(auth_login auth_logout orders_create orders_cancel billing_invoice)
FAILED=0

# True when two or more changes/*.txt files declare the same VALUE=<n>.
dup_values() { grep -rhoE '^VALUE=[0-9]+' changes 2>/dev/null | sort | uniq -d | grep -q .; }

# Per-test duration in seconds. Kept short for the POC so queue behavior is quick
# to observe; raise for a more "realistic" long-suite run.
PER_TEST_SECONDS="${PER_TEST_SECONDS:-20}"

i=0
for t in "${TESTS[@]}"; do
  i=$((i + 1))
  echo "-> running $t (~${PER_TEST_SECONDS}s)..."
  sleep "$PER_TEST_SECONDS"   # simulate a real, slow test
  if [ "$t" = "orders_create" ] && dup_values; then
    echo "not ok $i - $t   (duplicate VALUE across changes/*.txt — combination conflict)"
    FAILED=1
  else
    echo "ok $i - $t"
  fi
done

echo "-----------------------------------"
if [ "$FAILED" -ne 0 ]; then
  echo "Test suite FAILED ($i tests run)"
  exit 1
fi
echo "Test suite PASSED ($i tests run)"
exit 0
