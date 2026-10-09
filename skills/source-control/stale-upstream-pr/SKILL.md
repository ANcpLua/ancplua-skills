---
name: stale-upstream-pr
description: >-
  Revive a stale pull request in a repository someone else maintains until a
  maintainer can review and merge it. Use when an upstream PR is labelled stale,
  conflicts with main, waits on re-review after requested changes, has a red CLA
  check, or needs a maintainer pinged from a fork. Not for PRs in the owner's
  own repositories.
---

# Stale upstream PR

While the PR waited, **main moved**. The work is done when a maintainer can read one
commit and a short description in which every claim was observed in a run.

1. **Read the requests.** The whole thread, every review, the diff. One row per
   reviewer request: what was asked, answered or open.
2. **Read their rules before the first edit.** CONTRIBUTING, agent instructions, the
   style and knowledge docs they link, the PR template, the CLA and stale workflows.
   Done when every rule that binds the change is quoted with its file.
3. **Find the drift.** Merge main without committing, then read what main changed in
   everything the PR touches. Done when every new caller and test of the touched code
   is marked compatible or named as a conflict. See [drift.md](references/drift.md).
4. **Choose the smallest change that fits main as it is now.** A change that only
   improves a failure sits where that failure already happens. Scope that grew
   becomes a proposed split for the owner.
5. **Prove it by running**: red on main, green on the branch, and every flow that
   works on main still works. Read [probe.md](references/probe.md) first.
6. **Verify in a sandbox, then on the fork's CI**: format, lint and the full suites
   of the touched packages through [sandbox-run.sh](scripts/sandbox-run.sh); the
   fork's own run covers the other platforms.
7. **Deliver one commit on current main** with text from
   [pr-text.md](references/pr-text.md).
8. **Get a fresh review before the ping.** A reviewer with none of your context
   returns "ready"; brief it from [review-brief.md](references/review-brief.md).
9. **Close the loop on GitHub**: answer and resolve every thread, notify the
   maintainer in a new comment, confirm the stale label will clear. What a fork
   author can and cannot do is in [github.md](references/github.md).
