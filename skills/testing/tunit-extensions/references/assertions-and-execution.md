# Assertions and execution

Start with TUnit's existing assertions. Extract a domain expectation only when
its name and failure message hide repeated domain reasoning—not a single
`IsEqualTo` call. Observe assertion results, usually with `await`; returning an
assertion task to an observing caller is also valid.

TUnit's `[GenerateAssertion]` turns a check into a fluent assertion using its
own source generator. The example below targets 1.67.0; compile it against the
consumer's installed version. No custom `IIncrementalGenerator` or additional
assertion library is required.

The documentation also describes these generated return types; verify support
in the installed package before using them:

| Return type | Use |
| --- | --- |
| `bool` | Simple pass/fail |
| `AssertionResult` | Domain-specific failure details |
| `Task<bool>` | An asynchronous check |
| `Task<AssertionResult>` | An asynchronous check with failure details |

Async evaluation and custom messages alone do not require a handwritten assertion
class. Generated negation has return-type restrictions; check the documentation
before promising a negative fluent counterpart.

```csharp
using System.ComponentModel;
using TUnit.Assertions.Attributes;

public static partial class MeasurementAssertions
{
    [EditorBrowsable(EditorBrowsableState.Never)]
    [GenerateAssertion(ExpectationMessage = "to represent a measured pass")]
    public static bool IsMeasuredPass(this Measurement value) =>
        value.HasData && value.ThresholdMet;
}
```

Keep the predicate independent of the production decision implementation.
Include positive, negative, and boundary cases. Execute the generated assertion's
failure path and inspect a meaningful message fragment; testing the predicate
alone does not verify the generated assertion. Use a manual assertion type when
evaluation or diagnostics genuinely exceed the generated form's capabilities.
In a manual evaluator, handle the source's captured exception before inspecting
its value. Test a throwing source too: a domain failure or null dereference must
not conceal the evaluation failure. Do not add a handwritten fallback merely
because the generated API has not yet been compiled.

Exception assertions should protect the promised contract. Exact type, base
type, inner exception, and cancellation-token identity are different contracts.
`Throws<Exception>` is not an adequate check for a specific failure mode, but
does still distinguish throwing from successful completion.

`ITestExecutor` controls invocation of the test delegate; it is not a replacement
for fixture lifecycle. Await the delegate and propagate its exception/cancellation.
Never turn a failed test green in an executor. A dedicated thread requires an
actual affinity constraint; `Task.Run` alone does not preserve continuations on
that thread. Hooks have their own executor path—do not assume a test executor
also schedules setup and teardown. Check the installed interfaces before writing
version-sensitive executor or event-receiver methods.

Sources: [generated assertions](https://tunit.dev/docs/assertions/extensibility/source-generator-assertions/),
[manual assertions](https://tunit.dev/docs/assertions/extensibility/custom-assertions/),
[execution extension points](https://tunit.dev/docs/extending/extension-points/).
