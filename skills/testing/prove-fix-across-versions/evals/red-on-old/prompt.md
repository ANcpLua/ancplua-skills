---
max_turns: 80
timeout_seconds: 1800
allowed_tools: [Read, Write, Edit, Glob, Grep, Bash, Skill]
runs: 1
---

I just bumped TUnit and TUnit.Mocks from 1.68.0 to 1.68.17 in this project. The release notes say mocks of types with `init`-only properties and indexers work now (thomhurst/TUnit#6833). Can you add a test for that, and back up the "fixed in 1.68.17" claim properly in CHANGELOG.md? No network here, but both versions are already in the local NuGet cache.
