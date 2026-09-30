---
# Behavioural, not keyword: the prompt names no error codes and the run has no network, so
# `error CS8853/CS8854/CS8855` can only enter the trace as real `dotnet build` output from a
# build against TUnit.Mocks 1.68.0 (on 1.68.17 these errors do not occur).
type: regex
weight: 2
target: trace
pattern: 'error CS885[345]'
---
