# GitHub as a fork author

| Situation | Fact | Do |
|---|---|---|
| CLA check (EasyCLA and similar) | Every author and every `Co-authored-by` trailer must have signed. An AI co-author trailer turns the check red. | Commit with the contributor's identity alone. When the check is red, rewrite the commits and force-push. |
| Upstream CI | Workflows on a fork PR wait at `action_required` until a maintainer approves the run. | Push to the fork: workflows with `on: push` run there. Link that run. |
| Requesting a reviewer | `gh pr edit --add-reviewer` is refused without repo permission. The sidebar re-request exists for people who submitted a review, not for commenters. | @-mention in a new comment; the timeline records a `mentioned` event. |
| Copilot review | A manually requested review is charged to whoever requests it. | Re-request it on the owner's word only. |
| Review threads | Threads on code the PR no longer contains show as Outdated and stay open. | Reply where a change answers the thread, then resolve each one. |
| Superseded comment | It stays visible and contradicts the new one. | Hide it as Outdated. Where hiding is unavailable, open the new comment with "This supersedes my comment above". |
| Stale bot | The workflow states the schedule and the days to stale and to close. `actions/stale` removes the label on its next run after an update unless `remove-stale-when-updated` is false. | After pushing and commenting, check the label once the next scheduled run has passed. |
| Merge rules | CONTRIBUTING states the approvals needed, often two from different companies. | Name who can give the second approval, and mention them once after the first. |
| Force-push | It discards nothing a reviewer needs while no human has reviewed the new version. | After a human review, add commits unless they ask for a rebase. |

Ask the owner first: closing the PR, opening an issue or a second PR, changing
scope, deleting comments, and whether comments and thread resolution go through the
web UI.
