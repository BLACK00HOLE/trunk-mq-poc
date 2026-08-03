#!/usr/bin/env bash
# Dummy test suite for the Trunk merge-queue POC.
#
# It simulates a real multi-test suite that takes a little time to run, so that
# speculative batching / parallel queue behavior is actually observable.
#
# Pass/fail stays fully controllable per-PR using the same convention as
# check.sh: a PR is "bad" if any file under changes/ contains the word FAIL.
# The "orders_create" test is the one that reflects that marker; every other
# test always passes.
set -uo pipefail

echo "Running dummy test suite (5 tests)..."
echo "-----------------------------------"

TESTS=(auth_login auth_logout orders_create orders_cancel billing_invoice)
FAILED=0

bad_marker() { grep -rl "FAIL" changes 2>/dev/null | grep -q .; }

i=0
for t in "${TESTS[@]}"; do
  i=$((i + 1))
  sleep 3   # simulate a real test taking time
  if [ "$t" = "orders_create" ] && bad_marker; then
    echo "not ok $i - $t   (a changes/*.txt file contains FAIL)"
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
