# Probe

A **probe** is a throwaway test that prints what the code does. It runs unchanged on
unmodified main and on the branch, and stays out of every commit.

## Setup

- Two checkouts: the branch, and `git worktree add --detach <dir> upstream/main`.
- One build cache per checkout. An incremental build keyed by relative path and
  mtime (cargo is one) reuses the other checkout's compiled code and prints the
  branch's behaviour for "main". `sandbox-run.sh` names the cache from the checkout
  path.
- Confirm in the build log that the changed package was compiled from the checkout
  under test.

## What to run

| Claim in the PR | Run | Expect |
|---|---|---|
| The fix works | the new committed tests, applied alone to the main checkout | fail on main, pass on the branch |
| "Before" and "after" output | the scenario, printing its result | both outputs, pasted into the PR verbatim |
| Everything that works on main still works | a probe of each flow the change sits in front of: cached, optional and lazily used inputs | the same result on both |
| Another placement is better or worse | the same probes on a local branch holding that placement | ship the placement that passes all of them |

A probe prints through a failing assertion, so the test runner shows the value:

```rust
assert!(false, "PROBE {result:?}");
```

## Record

Keep the exact command and output of each run. They are the evidence in the PR text
and the answer when a reviewer asks how it was verified.
