#!/usr/bin/env bash
set -euo pipefail

instance="${1:-https://v15.next.forgejo.org}"
owner="${2:-ANcpLua}"
repo="${3:-qyl}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "$script_dir/.." && pwd)"
swagger="$(mktemp)"
routes="$(mktemp)"
doc_routes="$(mktemp)"
missing="$(mktemp)"
trap 'rm -f "$swagger" "$routes" "$doc_routes" "$missing"' EXIT

curl -fsSL "${instance%/}/swagger.v1.json" > "$swagger"

jq -r '
  .paths
  | to_entries[]
  | .key as $path
  | .value
  | to_entries[]
  | select(.key | test("^(get|post|put|patch|delete)$"))
  | ((.key | ascii_upcase) + " " + $path)
' "$swagger" | sort -u > "$routes"

python3 - "$skill_dir" > "$doc_routes" <<'PY'
import pathlib
import re
import sys
skill_dir = pathlib.Path(sys.argv[1])
files = [skill_dir / "SKILL.md", *sorted((skill_dir / "references").glob("*.md"))]
pattern = re.compile(r'\b(GET|POST|PUT|PATCH|DELETE)\s+(/[A-Za-z0-9_{}./:-]+)')
seen = set()
for path in files:
    text = path.read_text(encoding="utf-8")
    for method, route in pattern.findall(text):
        route = route.rstrip('`),.;')
        if route.startswith('/api/v1/'):
            route = route[len('/api/v1'):]
        if route.startswith('//'):
            continue
        seen.add(f"{method} {route}")
for item in sorted(seen):
    print(item)
PY

comm -23 "$doc_routes" "$routes" > "$missing"
if [[ -s "$missing" ]]; then
  echo "swagger_route_check=fail" >&2
  cat "$missing" >&2
  exit 1
fi

echo "swagger_route_check=pass documented_routes=$(wc -l < "$doc_routes" | tr -d ' ') swagger_routes=$(wc -l < "$routes" | tr -d ' ')"

if [[ -z "${FORGEJO_TOKEN:-}" ]]; then
  echo "live_private_probe=skipped reason=FORGEJO_TOKEN_not_set"
  exit 0
fi

api="${instance%/}/api/v1"
auth=(-H "Authorization: token ${FORGEJO_TOKEN}")
probe() {
  local name="$1"
  local path="$2"
  local code
  code="$(curl -sS -o /dev/null -w '%{http_code}' "${auth[@]}" "$api$path")"
  if [[ "$code" -lt 200 || "$code" -ge 300 ]]; then
    echo "probe=$name status=fail http=$code path=$path" >&2
    return 1
  fi
  echo "probe=$name status=pass http=$code"
}

probe user /user
probe version /version
probe repo "/repos/$owner/$repo"
probe branches "/repos/$owner/$repo/branches"
probe refs "/repos/$owner/$repo/git/refs"
probe commits "/repos/$owner/$repo/commits?limit=1"
probe contents_root "/repos/$owner/$repo/contents"
probe actions_runners "/repos/$owner/$repo/actions/runners"
probe actions_runs "/repos/$owner/$repo/actions/runs"
probe actions_tasks "/repos/$owner/$repo/actions/tasks"
probe packages "/packages/$owner"
