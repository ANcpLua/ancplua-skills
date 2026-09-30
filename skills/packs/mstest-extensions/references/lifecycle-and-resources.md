# Lifecycle and resources

## Order and signatures

`AssemblyInitialize` → `ClassInitialize` → constructor → `TestInitialize` → test →
`TestCleanup` (derived, then base) → `DisposeAsync` → `Dispose` → `ClassCleanup` →
`AssemblyCleanup`. For data-driven tests the test-level part runs per case.

- Assembly and class fixtures are `public static`, return `void`, `Task` or
  `ValueTask`, and live in a `[TestClass]`. Initializers take one `TestContext`;
  cleanups take none or one (MSTest 3.8+). One of each per assembly or class
  (`MSTEST0010`–`MSTEST0013` validate them).
- `ClassInitialize(InheritanceBehavior.BeforeEachDerivedClass)` reruns for each
  derived class. In MSTest 4, `ClassCleanup` runs at the end of its class only; put
  end-of-assembly work in `AssemblyCleanup`.
- From MSTest 4.2, `ClassCleanup` and `AssemblyCleanup` failures appear as separate
  results; read them.
- `GlobalTestInitialize`/`GlobalTestCleanup` (3.10+) wrap every test in the assembly;
  their relative order is not guaranteed.
- `[assembly: AssemblyFixtureProvider(typeof(...))]` (4.3+) runs assembly fixtures
  declared once in a shared library. From 4.4 it is skipped without dynamic code,
  including Native AOT (`MSTEST0072`).
- Base libraries and test projects must use the same MSTest major version, or
  inherited tests and fixtures are silently ignored (`MSTEST0082`).

## Per-test setup and ownership

Prefer the constructor for synchronous setup of `readonly` fields; use
`TestInitialize` for async setup or timeouts. A constructor exception skips cleanup
and disposal; a `TestInitialize` failure still runs them. Choose one style
(`MSTEST0019`/`MSTEST0020`; `MSTEST0021` prefers `Dispose` over `TestCleanup`). Own
what the test constructs and dispose it; let the framework own what it creates.
Async tests run without a `SynchronizationContext`.

## TestContext

Inject it through the constructor (3.6+) or a public property; never store it in a
static (`MSTEST0024`). In MSTest 4, reading `TestName` in assembly or class
initialization, or `FullyQualifiedTestClassName` in assembly initialization, throws.
Flow `TestContext.CancellationToken` into every cancellable call (`MSTEST0049`); it is
signaled on timeout or when the run aborts.

## Timeouts and cancellation

`[Timeout(ms)]` applies to tests and fixtures; `testconfig.json` or runsettings set
global defaults. Set `CooperativeCancellation = true` (`MSTEST0045`, a warning in
MSTest 4): the token is canceled and MSTest awaits the method. Without it, a timed-out
test keeps running in the background and can race later tests or break cleanup. A
timeout limits waiting; code that ignores the token does not stop.

For suspension or cancellation tests, hold the operation at a releasable dependency,
prove successful resumption separately from cancellation, and observe the original
operation before disposing its dependencies, including when an assertion fails.

## Parallel isolation

Declare intent with `[assembly: Parallelize(Workers = n, Scope = ExecutionScope.ClassLevel)]`
or `[assembly: DoNotParallelize]` (`MSTEST0001`), or with `mstest.parallelism` in
`testconfig.json`. `[DoNotParallelize]` tests run after the parallel set of their
assembly, which lengthens its critical path.

Process-wide state needs isolation: culture (`MSTEST0076`), shared or hardcoded file
paths (`MSTEST0077`), environment variables, the current directory, and static caches.
Give each test its own workspace, or mark the class `[DoNotParallelize]`.

Reap child processes and threads the test started before deleting their workspace.
Under MTP, MSTest 4 disables AppDomain isolation by default, so a foreground thread
left running now hangs the run instead of being aborted.
