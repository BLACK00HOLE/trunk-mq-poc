# trunk-mq-poc

A throwaway repo to POC **Trunk.io Merge Queue** mechanics (queue, speculative
batching, bisection, anti-flake) with a fast, controllable CI check.

## How the CI gate works

The `CI / check` job runs [`check.sh`](./check.sh), which **fails if any file
under `changes/` contains the word `FAIL`**, and passes otherwise.

Each PR adds its **own** file under `changes/` (e.g. `changes/pr-a.txt`) so PRs
never conflict when the queue batches them together.

- Make a PR **pass** → its file contains `OK`
- Make a PR **fail** → its file contains `FAIL`

## Demo script (batching + bisection)

1. Open 3 PRs, each adding a different file:
   - PR-A → `changes/pr-a.txt` = `OK`
   - PR-B → `changes/pr-b.txt` = `FAIL`   ← the "culprit"
   - PR-C → `changes/pr-c.txt` = `OK`
2. Add all three to the queue (`/trunk merge` on each).
3. Watch Trunk test speculative batches, detect the failure introduced by PR-B,
   **eject PR-B**, and merge PR-A + PR-C.
