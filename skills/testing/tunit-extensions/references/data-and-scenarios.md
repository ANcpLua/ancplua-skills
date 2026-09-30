# Data and scenarios

Select the data shape before selecting its attribute:

- Explicit rows preserve relationships between inputs and expected results.
- A matrix forms a Cartesian product. Calculate its size and ensure each pair
  means something; expected results are usually derived from the case, not another axis.
- A method source is sufficient for one local collection of cases.
- A custom typed source earns its own attribute when reused or when it hides
  scenario construction. Return factories so each execution can get fresh objects.

In TUnit 1.67.0, an external custom source overrides `GenerateDataSources` with
`protected`, not `public`. Verify signatures on a different installed version.

```csharp
public sealed record ReadScenario(int ChunkSize)
{
    public override string ToString() => $"chunks of {ChunkSize} bytes";
}

public sealed class ReadScenariosAttribute : DataSourceGeneratorAttribute<ReadScenario>
{
    protected override IEnumerable<Func<ReadScenario>> GenerateDataSources(
        DataGeneratorMetadata metadata)
    {
        yield return () => new ReadScenario(1);
        yield return () => new ReadScenario(7);
        yield return () => new ReadScenario(64);
    }
}
```

Keep discovery cheap and repeatable: yield descriptions/factories, not opened
ports, files, or running tasks. Async sources can do discovery-time I/O; that
means unavailable infrastructure can prevent discovery entirely. Prefer runtime
fixture initialization when the case list is already known.

For replayable combinatorial tests, record seeds if randomness is necessary,
include distinguishing values in case names, and assert a domain invariant.
Generating many permutations does not help if the oracle reuses the production
algorithm or the inputs cannot distinguish the outcomes.

Use `ToString()` for a straightforward scenario label. Add an argument formatter
only when presentation cannot reasonably live on the scenario type. Discover the
suite to verify that the names actually appear.

Sources: [data sources](https://tunit.dev/docs/extending/data-source-generators/),
[matrices](https://tunit.dev/docs/writing-tests/matrix-tests/),
[argument formatters](https://tunit.dev/docs/extending/argument-formatters/).
