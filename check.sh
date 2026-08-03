#!/usr/bin/env bash
# POC gate for the Trunk Merge Queue.
#
# Rule: the build FAILS if any *.txt file under changes/ contains the word FAIL.
# Each PR adds its own file (e.g. changes/pr-a.txt) so PRs never conflict when
# the queue batches them together. To make a PR "bad", put FAIL in its file;
# to make it "good", put OK.
set -euo pipefail

echo "Scanning changes/ for FAIL markers..."
if grep -rl "FAIL" changes 2>/dev/null | grep -q .; then
  echo "::error::Found FAIL marker(s):"
  grep -rn "FAIL" changes || true
  exit 1
fi

echo "All good - no FAIL markers found."
exit 0
