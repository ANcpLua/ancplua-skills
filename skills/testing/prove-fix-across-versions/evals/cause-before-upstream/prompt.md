---
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Write, Edit, Glob, Grep, Bash, Skill]
---

Using the new experimental internals access in TUnit.Mocks 1.68.0 (repro is in this folder: SdkLib + Tests). My editor shows CS0122 on `IQuotaPolicy.Mock()` but `dotnet build` is clean and the test passes. I already found why, it's in evidence.txt: ReferencePath keeps the original SdkLib.dll, only ReferencePathWithRefAssemblies gets the publicized copy, so the IDE reads the wrong one. Please write the bug report for thomhurst/TUnit into ISSUE.md, with the root cause, so I can paste it straight into GitHub.
