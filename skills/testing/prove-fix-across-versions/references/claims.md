# Listing and re-verifying claims

## Step 1: list the claims

Read the release notes for every tag in `OLD..NEW`, the public API diff, and each PR
that reaches consumers. Write one row per behaviour change: the claim, the upstream
reference, and the symptom you expect on OLD (an error code, a wrong value, an
exception).

Done when every consumer-visible change has a row or a one-line "not shown" reason.

## Step 5: re-verify carried claims

Existing "verified on OLD", "on OLD" and "pinned to OLD" lines change to NEW only
after a run on NEW re-confirms them, including opt-in or explicit tests re-run
through their filters. Dated history ("fixed in X", "new in X") stays as written.

Done when every version claim in the docs either carries NEW backed by a run, or
dates an older change.
