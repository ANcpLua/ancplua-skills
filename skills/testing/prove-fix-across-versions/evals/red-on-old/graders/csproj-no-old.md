---
# No package in the real project is left pinned to 1.68.0.
type: regex
weight: 1
target: { source: file, path: Shop.Tests.csproj }
pattern: '1\.68\.0"'
match: not_contains
---
