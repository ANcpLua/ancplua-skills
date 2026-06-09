# Forgejo AI review

Forgejo-native AI review is a runner job plus Forgejo API output.

## Flow

```text
pull_request event
fetch pull request
fetch files/diff/commits
run reviewer
post review or issue comment
post commit status
```

## Input endpoints

```text
GET /repos/{owner}/{repo}/pulls/{index}
GET /repos/{owner}/{repo}/pulls/{index}/files
GET /repos/{owner}/{repo}/pulls/{index}.{diffType}
GET /repos/{owner}/{repo}/pulls/{index}/commits
GET /repos/{owner}/{repo}/contents/{filepath}
GET /repos/{owner}/{repo}/raw/{filepath}
```

Use `{diffType}` as `diff` or `patch`.

## Output endpoints

```text
POST /repos/{owner}/{repo}/pulls/{index}/reviews
POST /repos/{owner}/{repo}/pulls/{index}/reviews/{id}/comments
POST /repos/{owner}/{repo}/issues/{index}/comments
PATCH /repos/{owner}/{repo}/issues/comments/{id}
POST /repos/{owner}/{repo}/statuses/{sha}
GET /repos/{owner}/{repo}/commits/{ref}/statuses
```

Prefer one sticky issue comment when inline review payload support is uncertain. Use a marker:

```text
<!-- forgejo-ai-review:codex -->
```

## Security

- Do not expose secrets to untrusted pull request code.
- Do not print model keys, PATs, runner tokens, package tokens, or webhook secrets.
- Do not send private diffs to third-party services unless the user accepted that data path.
- Run destructive fixes only when explicitly requested.
