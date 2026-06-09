---
name: forgejo-direct-api
description: Use when working directly with Forgejo v15 APIs, private repositories, Actions workflows, runners, pull requests, reviews, statuses, releases, packages, webhooks, organizations, users, or admin operations. Prefer Forgejo's live Swagger and direct endpoints over GitHub-shaped assumptions.
metadata:
  short-description: Direct Forgejo v15 API and Actions guide
---

# Forgejo Direct API

Use this skill for Forgejo-first work. Do not start from GitHub names unless the user explicitly asks for GitHub comparison.

## Rules

- Use live Swagger as authority: `<instance>/swagger.v1.json`.
- Use Forgejo names: repository, actions runner, workflow, run, task, pull request, review, issue comment, commit status, package, release, webhook.
- Prefer direct Forgejo API calls over wrappers or compatibility shims.
- Keep tokens out of logs and responses.
- Use `Authorization: token $FORGEJO_TOKEN` unless the instance documents another auth scheme.
- Treat ActivityPub endpoints as federation only; they are not part of qyl CI, review, package, or repo automation.

## Reference files

- `references/forgejo-api-map.md`: Forgejo-native endpoint map by task.
- `references/forgejo-v15-endpoints.md`: generated full v15 route inventory from live Swagger.
- `references/forgejo-actions-runner.md`: Actions workflow, runner, label, secret, variable, dispatch, and run/task notes.
- `references/forgejo-ai-review.md`: Forgejo-native AI review flow using pull request, review, issue comment, and status APIs.

## qyl private repo path

```text
GET /user
GET /repos/{owner}/{repo}
authenticated git push
.forgejo/workflows/*.yml
runner label matches runs-on
GET /repos/{owner}/{repo}/actions/runs
GET /repos/{owner}/{repo}/actions/tasks
```

## Refresh and verify

```bash
/Users/ancplua/.claude/skills/forgejo-direct-api/scripts/fetch-forgejo-swagger.sh https://v15.next.forgejo.org
```

```bash
FORGEJO_TOKEN=... /Users/ancplua/.claude/skills/forgejo-direct-api/scripts/verify-forgejo-skill.sh https://v15.next.forgejo.org ANcpLua qyl
```

Without `FORGEJO_TOKEN`, verification still checks documented routes against Swagger and skips private repo probes.
