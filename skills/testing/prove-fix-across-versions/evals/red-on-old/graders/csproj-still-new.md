---
# The real project must end on 1.68.17 for TUnit.Mocks (not left pinned to OLD).
type: regex
weight: 1
target: { source: file, path: Shop.Tests.csproj }
pattern: 'Include="TUnit\.Mocks" Version="1\.68\.17"'
---
