# Source of truth

| Area | Source |
| --- | --- |
| Ownership inference and SARIF aggregation | `src/ArchCheck/Program.cs`: `Inferred`, `Declared`, `Report`, `ReadSarif` |
| Static rule definitions, settings, and ownership metadata | `src/ArchCheck.Analyzers/Analyzer.cs`: `RuleCatalog`, `FileSettings`, `AnalysisDate` |
| Runtime trace parsing, service mapping, and RT1-RT3 | `src/ArchCheck/Spans.cs` |
| Compiler participation and emitted logs | `build/ArchCheckRun.targets` |
| Corpus selection and declared study metadata | `repositories.json` |
| Declared sample boundaries and allowed dependencies | `samples/Monolith/.editorconfig` |
