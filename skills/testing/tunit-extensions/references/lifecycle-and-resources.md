# Lifecycle and resources

`ClassDataSource<T>` injects a fixture. Choose constructor or property injection
for a dependency on the receiving test class, not both. The fixture type created
by `ClassDataSource<T>` needs a public parameterless constructor; use property
injection for its nested dependencies. With TUnit 1.67.0, `SharedType.None` is the
default: a fresh instance per injection point, not one common instance per test.
Widening the scope changes ownership and concurrency, not just performance.

Use `IAsyncInitializer.InitializeAsync()` for actual async initialization and
`IAsyncDisposable.DisposeAsync()` for async cleanup. A synchronous disposable
helper can remain synchronous. Keep constructors resource-light: framework
discovery may instantiate objects before the test body runs. Roll back partial
initialization when a later acquisition fails; do not depend on a successfully
initialized fixture's teardown to cover every setup failure.

Shared resources require an explicit isolation policy: immutable data, separate
per-test partitions, or synchronized access. Sharing a mutable fake server just
to avoid constructing it is usually the wrong lifetime. Process-global state
requires coordination of both writers and affected readers.

For local HTTP tests, bind loopback with an OS-selected port, expose readiness,
capture the request, and configure the response or disconnect. Exercise the real
client. Describe the fixture's protocol limits rather than silently treating a
minimal server as a general-purpose HTTP implementation.

## Async ownership and termination

Establish what makes the **whole operation** terminate. A stream honoring a token
does not prove that its parser honors cancellation elsewhere. `Resume()` releases
a read; it does not finish subsequent parsing or other waits. When that contract
is unknown, state the missing guarantee. For potentially uncooperative work that
needs a hard bound, use an owned child process with explicit termination and
reaping. A timeout attribute alone cannot make it safe to dispose live resources.

For controlled, cooperative async tests:

1. Signal when the dependency reaches the intended pause.
2. Observe that the operation is still pending, then resume or cancel it.
3. Join the operation before disposing its dependencies on every exit path.

`TaskCompletionSource` with asynchronous continuations provides a handshake;
`Task.Delay` does not establish ordering. Assert recorded outcomes after joining.
If both an observation and cleanup can fail, retain both failures (for example,
as an aggregate with the original first); an unguarded await in `finally` can
replace the original exception. Only best-effort diagnostics swallow failures.

Observe the **original operation**, not only a timed proxy from `WaitAsync`.
When that proxy times out, the original task can still be using the stream.
Swallowing the timeout and leaving a `using` scope would dispose a live dependency.
For a finite copy through the sample's cooperative stream, race the handshake
against the operation itself so a pre-handshake fault is observed promptly.
Release the non-throwing pause, then join before asserting:

```csharp
var operation = source.CopyToAsync(destination, cancellationToken);
bool wasPending;
try
{
    await Task.WhenAny(source.Paused, operation);
    wasPending = source.Paused.IsCompletedSuccessfully && !operation.IsCompleted;
}
finally
{
    source.Resume();
}
await operation;
await Assert.That(wasPending).IsTrue();
```

Here the test owns `source` and `destination` in surrounding `using` declarations.
`WhenAny` does not propagate the operation's exception; the final await does.
This observation block has no throwing assertions or independently cancelled
wait. If it grows to include them, joining must also cover that failure path and
preserve its exception. The cancellation case cancels the operation's token and
observes its expected cancellation while joining. Never substitute a timed proxy
for that join or claim that releasing one dependency guarantees termination.

## Failure-only diagnostics

Use hooks such as `[Before(Test)]` / `[After(Test)]` for test-level concerns;
class, assembly, session, and discovery hooks have different lifetimes. Use the
installed version's `TestContext` to capture failure diagnostics. Verify hook and
fixture-disposal ordering before depending on a live resource; otherwise record
an independent snapshot while it is available. Use an event receiver only when
the same policy genuinely needs reusable attribute-based application.

TUnit's lifecycle documentation says cleanup phases continue after failures and
collect their exceptions together. That is different from an ordinary throwing
`finally` replacing an exception. Contain optional diagnostic failures to avoid
adding teardown errors; keep actual cleanup failures visible to the framework.

Protect both capture and output, including the fallback's formatting and write:

```csharp
static void WriteDiagnostics(TextWriter output, Func<string> capture)
{
    try
    {
        output.WriteLine(capture());
    }
    catch (Exception captureFailure)
    {
        try
        {
            output.WriteLine($"diagnostics unavailable: {captureFailure.Message}");
        }
        catch (Exception)
        {
            // Optional diagnostics must leave the original test failure intact.
        }
    }
}
```

Use this containment only for optional failure output, not assertions, resource
cleanup, or application exceptions. A broken sink may lose diagnostics; it must
not replace the test failure. Check capture failure, sink failure, and both
together, asserting that the same original exception survives. This handles
exceptions, not hung capture/output: use non-blocking snapshots and a suitable
sink rather than promising a timeout around arbitrary logging.

Sources: [class data](https://tunit.dev/docs/writing-tests/class-data-source/),
[lifecycle](https://tunit.dev/docs/writing-tests/lifecycle/),
[hooks](https://tunit.dev/docs/writing-tests/hooks/),
[test context](https://tunit.dev/docs/writing-tests/test-context/),
[Task.WaitAsync](https://learn.microsoft.com/en-us/dotnet/api/system.threading.tasks.task.waitasync?view=net-10.0).
