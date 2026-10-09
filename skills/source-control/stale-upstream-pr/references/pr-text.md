# PR text

Every sentence is something a maintainer can check. Output shown in the text is
pasted from a run.

## Description

| Section | Holds |
|---|---|
| Title | What changes for a user, in the repo's own words. |
| Problem | The scenario and the actual output on main. |
| Change | Where the change sits and the actual output on the branch. |
| Behavior change | "None" with the reason, or each flow that works on main and changes, as probed. |
| Why not ... | The placements that were tried and what each broke on main. Tested ones only. |
| Not changed | The adjacent thing a reviewer would expect, and why it is out of scope. |
| Tests | Test names, and that they fail on main. |

A motivating example that went stale while the PR waited is updated, with a link to
where it changed.

## Commit

One commit on current main. The subject is the PR title. The body gives the problem
in two lines, the change, and the reason for its placement. The repo's trailer and
sign-off rules apply; CLA checks are in [github.md](github.md).

## Comment to the maintainer

A new comment, since an edit reaches nobody's inbox:

1. What differs from the version they reviewed.
2. Why, in one or two sentences, pointing to the description.
3. The CI link for this exact commit: the fork's run while upstream workflows await
   approval.
4. The @-mention and the ask for a fresh look.

## Code comments and style

The repo's style doc decides. Where it is silent: one line saying what the code
does, with the reason only when the code cannot show it. Test names carry the intent.
