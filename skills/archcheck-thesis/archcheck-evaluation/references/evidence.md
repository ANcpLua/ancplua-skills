# Establishing the evidence

- Catalogue commit IDs and group labels are declared metadata, not proof of the current checkout or its architecture. Distinguish the inference solution from an optional narrower `buildSolution` and its `buildScope`.
- Inference tries AppHost, then Compose, then executable projects; `--declared` instead reads `.editorconfig`. Check boundaries, shared projects, allowed edges, and `leftOut` in `inference.json`. Inferred ownership and allow rules are hypotheses derived from implementation, not an independent architectural specification.
- Coverage: `ReadSarif` skips malformed files, and reporting can succeed without logs. Compare expected owned, non-test projects and frameworks with emitted files; inspect build/report warnings and raw configuration diagnostics. Explain omitted projects and missing evidence before reporting a clean result.

| Evidence in `artifacts/runs/<name>/` | What it establishes |
| --- | --- |
| `commands.txt`, `*.exit`, `*.log` | Commands, individual step outcomes, and diagnostics |
| `inference.json`, `owners.props`, `boundaries.editorconfig` | Ownership model, generated MSBuild owners, and readable boundary configuration |
| `sarif/*.project`, `sarif/*.sarif` | Projects reaching the compiler hook and the emitted diagnostics per framework |
| `report.json`, `report.txt` | Aggregated findings and reported completion state |
