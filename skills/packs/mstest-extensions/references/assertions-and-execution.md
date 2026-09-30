# Assertions and execution control

## Assertions

Use the `Assert` class; `StringAssert` and `CollectionAssert` are kept for
compatibility and are likely to be deprecated. Prefer the specific assertion to
`Assert.IsTrue(a == b)`. Check the version before using newer members:

- 3.8: `Contains`, `DoesNotContain`, `HasCount`, `IsEmpty`, `IsNotEmpty`, `ContainsSingle`;
  `Assert.That(() => condition)` explains a failing Boolean expression.
- 3.10: `IsInRange`, `IsGreaterThan[OrEqualTo]`, `IsLessThan[OrEqualTo]`, `IsPositive`,
  `IsNegative`, `StartsWith`, `EndsWith`, `MatchesRegex` and their negations.
- 4.1: `IsExactInstanceOfType`/`IsNotExactInstanceOfType` reject derived types.
- 4.3: `AreSequenceEqual`/`AreNotSequenceEqual`, with `SequenceOrder.InAnyOrder` to
  ignore order.

MSTest 4 changes: messages are a single string (use interpolation instead of format
arguments), and `Assert.IsInstanceOfType<T>(x)` returns the typed instance instead of
an `out` parameter.

## Exceptions

Use `Assert.Throws`, `Assert.ThrowsExactly`, `Assert.ThrowsAsync`, or
`Assert.ThrowsExactlyAsync`; they return the exception for further checks.
`ExpectedException` and `Assert.ThrowsException` are removed in MSTest 4
(`MSTEST0006`, `MSTEST0039` migrate them). Prefer the async assertion methods for async
code (`MSTEST0064`), never assert in `async void` (`MSTEST0040`), and avoid blocking
calls such as `.Result` (`MSTEST0067`). An async assertion alone does not require
making a synchronous action under test asynchronous.

## Custom assertions

Add a repeated domain expectation as an extension method on the `Assert` type, throw
`AssertFailedException` on failure, and call it as `Assert.That.MyCheck(...)`. Do not
target `StringAssert.That` or `CollectionAssert.That` in new code. The `Assert.That`
property (extension hook) differs from the `Assert.That(() => ...)` method. Test a custom
assertion's rejecting path as well as its accepting path.

## Execution control

- Thread affinity: `STATestClass`, `STATestMethod`, `UITestMethod`, only for a real
  apartment or UI-thread requirement.
- Conditions: `OSCondition`, `ArchitectureCondition`, `CICondition` instead of runtime
  checks (`MSTEST0061`, `MSTEST0079`, `MSTEST0080`). `Ignore` needs a reason, ideally
  with `WorkItem` or `GitHubWorkItem`.
- Retry: `[Retry]` hides flakiness; fix the cause first and keep retries out of
  flakiness measurements.
- Dependencies: `[DependsOn]` and `testconfig.json` dependency chains exist from MSTest
  4.4 and only on MTP (`MSTEST0078`).
- Metadata: `TestCategory`, `TestProperty`, `Owner`, `Priority` feed filters and reports.

## Custom test attributes

A `TestMethodAttribute` subclass overrides `ExecuteAsync` in MSTest 4 (not `Execute`)
and forwards `[CallerFilePath]` and `[CallerLineNumber]` constructor parameters to the
base. Set a display name through the `DisplayName` property. Create one only for a
real execution policy that attributes and fixtures cannot express.
