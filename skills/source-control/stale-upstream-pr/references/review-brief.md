# Review brief

The reviewer is a fresh agent with none of your context. Hand it the PR and the
evidence, and keep your own conclusion out of the brief.

```text
Review this pull request the way a maintainer of the target project would, before
the author asks a maintainer for review. Report only what you can back with
file:line, diff or log evidence.

PR: <url>. Read its title, description, thread and diff with gh.
Local clone at the pushed head: <clone>, with the remote upstream fetched.
Evidence: <logs of the runs on main and on the branch>.

Answer in order of importance:
1. Is the PR's central justification true on current main? Is it overstated?
2. Is the scope right? Trace every caller of the changed code. Does it catch too
   much or too little? Would a maintainer prefer another place, judging by how the
   project handles similar cases?
3. Code and tests: bugs, platform or lint risks, vacuous or redundant tests. Do the
   new tests fail without the change?
4. Is every claim in the title, description, comments, commit message and changelog
   true, and readable for a busy maintainer?

Read-only: no builds, pushes, comments or edits.
Return a verdict (ready / fix first / wrong approach), then the findings, most
serious first, each with evidence and a concrete fix. Separate what you verified
from what you infer.
```

## After the review

- A finding made by reading code is a lead. Probe it before acting on it or
  describing it in the PR.
- Fix, push, then send the same reviewer the list of what changed and ask what
  remains.
- The maintainer is mentioned once the verdict is "ready" and CI on that commit is
  green.
