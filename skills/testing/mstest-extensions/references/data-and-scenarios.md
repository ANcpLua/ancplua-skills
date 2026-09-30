# Data and scenarios

Pick the simplest source that expresses the cases. Keep scenario descriptions
immutable; create mutable resources per execution, never inside the data.

## `DataRow`

Inline, static cases. Argument count and types must match the method signature
exactly (`MSTEST0014`); duplicate rows run the same case twice (`MSTEST0042`). Use
`DisplayName` for readable names, `IgnoreMessage` (MSTest 3.8+) to skip one row with a
reason, `params` arrays for variable arguments, and `DateOnly`/`TimeOnly` arguments
from MSTest 3.10. Generic test methods (3.8+) infer type arguments from the row values.
Test methods take no `out`/`ref` parameters (`MSTEST0062`).

## `DynamicData`

Computed or typed cases. The source is a `public static` method, property, or (3.11+)
field returning `IEnumerable<T>` of:

- value tuples, the default choice: compile-time checked;
- `TestDataRow<T>` when a case needs a display name, categories, or an ignore message;
- `object[]` only in legacy code: runtime-typed and error-prone.

The source kind is auto-detected from MSTest 3.8; do not set `DynamicDataSourceType`
(`MSTEST0052`). Point at another class with the type parameter, pass arguments to a
source method with `Arguments` (3.10+), and skip every case with `IgnoreMessage`.
A custom name method is `public static string`, taking `MethodInfo` and `object[]`;
`TestDataRow<T>.DisplayName` is usually simpler. `MSTEST0018` validates the source.

## Combinatorial data

`[CombinatorialData]` with `CombinatorialValues`, `CombinatorialRange` or
`CombinatorialRandomData` builds the Cartesian product of parameter values. It is
built in from MSTest 4.4; earlier versions use the community `Combinatorial.MSTest`
package. Use it only when every combination is meaningful; otherwise list the cases.

## Custom sources

Implement `ITestDataSource` on an attribute for a reusable source; return
`TestDataRow<T>` for per-case metadata. A data-source "generator" produces test data
at discovery; it does not require writing a Roslyn generator.

## Discovery rules

MSTest evaluates every data source during discovery, before `AssemblyInitialize`,
`ClassInitialize`, or any other fixture runs. Data code must not depend on fixture
state. If a source throws during discovery, the test folds into a single node
regardless of the configured strategy.

The unfolding strategy (`Auto`, `Unfold`, `Fold`) lives on `TestMethodAttribute` in
MSTest 4 (it moved from the data attributes). Unfolded cases are separate entries that
can be filtered and rerun individually; folded cases share one node and one TRX test.
Check discovered names and counts after adding cases.

An empty source fails by default ("GetData returned empty collection");
`considerEmptyDataSourceAsInconclusive` turns that into inconclusive, which is not a pass.
`[assembly: DiscoverInternals]` lets MSTest find internal test classes and tests whose
parameters use internal types.
