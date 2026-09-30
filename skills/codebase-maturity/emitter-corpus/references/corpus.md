# Corpus coverage

Example for Cobertura XML: Coverlet (default and DeterministicSourcePaths), gcovr, coverage.py (`--cov-report=xml`, with and without branch data), JaCoCo-to-Cobertura converters (cover2cover), grcov, ReportGenerator.

Structural edge cases: source-root declarations (absolute vs relative filenames), the same relative filename under different roots (monorepo), duplicate entries for one file (partial classes), empty containers, attribute variants, huge and unusual-but-legal values.
