# Ship: the corpus becomes CI

- Commit the samples under the repo's test-fixture layout, each with its hand-computed semantic expectations encoded as test assertions. The expected numbers came from the file's meaning, so they never need the tool under test to regenerate them.
- Commit the corpus README alongside (sample -> producer -> upstream reference), so a failing fixture immediately names whose output broke and where its format is documented.
- Wire the samples into the existing test suite so the normal build runs them; a one-off script that must be remembered is not a gate.
- Findings fixed during the run get their sample as the regression test; samples that pass today are the tripwire for tomorrow's parser change.
