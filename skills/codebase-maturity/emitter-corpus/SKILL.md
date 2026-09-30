---
name: emitter-corpus
description: Validate a parser or importer against a corpus of files as real upstream producers write them, and land it as permanent CI fixtures. Use when asked whether a parser handles other tools' output, for format-compatibility or interop testing, "does it work with X's files", or a regression corpus or interop fixtures for an input format.
---

A parser validated only against its own ecosystem's dominant emitter has never met the format. Build an upstream-verified corpus of files as real producers emit them, run the parser/importer under test on every sample, report wrong results, crashes, and silently dropped data.

## Ground rules

- Ground every sample in upstream reality: the producer's writer source, docs, or real output (web search/fetch). Never invent a dialect from memory. Note the upstream reference per sample.
- Run the REAL tool end to end (installed binary or built artifact), not just unit-level parse calls.
- The corpus is files on disk from the first sample, with a README mapping sample -> producer -> upstream reference, built to be committed, not a scratch run.

## Steps

1. **Build**: cover at least the format's reference implementation (its DTD/schema and full element set), the project's ecosystem's dominant emitter, the major foreign emitters, and structural edge cases. See [references/corpus.md](references/corpus.md) before authoring.
2. **Expect**: per sample, compute the semantically correct result by hand from the file's meaning, never from the tool's output.
3. **Judge**: record findings, severity and evidence per [references/judge.md](references/judge.md).
4. **Ship**: not a report; commit the corpus to the target repo as permanent fixtures every future build reruns, per [references/ship.md](references/ship.md).
5. **Summarize**: producers covered, samples added, findings by severity, fixture/test paths where the corpus lives in CI.
