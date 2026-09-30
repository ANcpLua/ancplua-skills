#!/usr/bin/env bash
set -euo pipefail

instance="${1:-https://v15.next.forgejo.org}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "$script_dir/.." && pwd)"
out="$skill_dir/references/forgejo-v15-endpoints.md"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL "${instance%/}/swagger.v1.json" > "$tmp"

{
  echo '# Forgejo v15 endpoint inventory'
  echo
  echo "Generated from: ${instance%/}/swagger.v1.json"
  echo
  jq -r '"API title: `\(.info.title)`\n\nAPI version: `\(.info.version)`\n\nBase path: `\(.basePath)`\n"' "$tmp"
  jq -r '
    .paths
    | to_entries
    | map(.key as $path | .value | to_entries[] | {
        tag: ((.value.tags[0] // "untagged") | tostring),
        method: (.key | ascii_upcase),
        path: $path,
        summary: ((.value.summary // .value.description // "") | gsub("\\n"; " "))
      })
    | sort_by(.tag, .path, .method)
    | group_by(.tag)
    | .[]
    | "## " + .[0].tag + "\n\n" + (map("- `" + .method + " " + .path + "` - " + .summary) | join("\n")) + "\n"
  ' "$tmp"
} > "$out"

echo "$out"
