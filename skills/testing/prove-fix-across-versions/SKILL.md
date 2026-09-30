---
name: prove-fix-across-versions
description: >-
  Prove behaviour changes between dependency versions with a test red on OLD,
  green on NEW. Use when bumping a package and writing "fixed in X" or
  "changed in X", re-verifying version claims in docs or changelogs, confirming an
  upstream fix, or diagnosing a bug before reporting it upstream. Not for plain
  bumps with no behavioural claim.
---

# Prove a fix across versions

"Fixed in NEW" is true only when one test is **red on OLD and green on NEW**, each
state observed, not reasoned. Release notes, PR text and diffs show where to look;
they are not evidence.

1. **List the claims**: one row per consumer-visible change in `OLD..NEW` (claim,
   upstream reference, expected symptom on OLD) or a one-line "not shown" reason.
   Sources: [claims.md](references/claims.md).
2. **Green on NEW**: one test per claim in the owning project, through the public
   entrypoint, dated `// Fixed in NEW (#PR): on OLD <symptom>.` 0 warnings; it
   passes for the right reason. Read [red-green.md](references/red-green.md) before
   steps 2 and 3.
3. **Red on OLD, one claim at a time**, in an isolated scratch copy outside the
   repository; record the exact red and its kind.
4. **Symptom is not cause**: observe the mechanism before writing a cause, run every
   probe on NEW as a control, label the rest as guesses. Read
   [cause.md](references/cause.md) before stating a cause.
5. **Re-verify carried claims**: "on OLD" lines move to NEW only after a run on NEW;
   dated history stays. See [claims.md](references/claims.md).
6. **Record the evidence** in the changelog, commit message or issue: test name, red
   on OLD with codes, green on NEW, how the red was isolated, so someone else can
   repeat it from that record alone.

For .NET commands (scratch copy, pinning, MSBuild items, a Roslyn workspace probe),
read [dotnet.md](references/dotnet.md).
