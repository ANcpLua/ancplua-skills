# Architecture attributes

The vision: ArchUnit or NetArchTest in one attribute. The attribute's name is the
intended style, `[Monolith]`, `[Microservices]` or `[DistributedMonolith]`, and its
argument is a rule family from 1 to 7. The test then enforces that ArchCheck rule
family for the declared style. Check the installed ArchCheck first; where the
attributes do not exist yet, this page is the contract to implement, built on the
MSTest extension points in the [data](data-and-scenarios.md),
[lifecycle](lifecycle-and-resources.md) and [assertions](assertions-and-execution.md)
references.

The rule IDs come from `src/ArchCheck.Analyzers/RuleCatalog.cs` in ArchCheck
(`ANcpLua/archcheck`); re-read it before relying on this table.

## Rule families

The family is the first digit of the four-digit `ARCH` ID.

| Value | Family | Rule IDs | In the source of truth |
| --- | --- | --- | --- |
| 1 | Dependencies | ARCH1000 boundary violation, 1001 unpublished type, 1002 denied dependency, 1003 entry-point reference, 1100 dependency cycle, 1101 shared project, 1102 single-boundary shared type, 1103 unused published type, 1104 duplicated type | ARCH1000, 1001, 1002 |
| 2 | Data | ARCH2000 foreign data store, 2001 shared data store, 2002 published persistence, 2100 AppHost shared database, 2101 deployment shared database, 2200 runtime shared database, 2201 undeclared database use | ARCH2000, 2001, 2002 |
| 3 | Deployment | ARCH3000 AppHost reference, 3001 deployment reference, 3100 deployment drift, 3101 environment drift | none yet |
| 4 | Calls | ARCH4000 unallowed call, 4001 call transport | none yet |
| 5 | Messaging | ARCH5000 message flow, 5001 deployment channel, 5100 HTTP dependency | none yet |
| 6 | Releases | ARCH6000 change coupling, 6100 released together, 6101 not released | none yet |
| 7 | Queries | ARCH7000 query match | none yet |

ARCH9xxx (configuration, unread input, unknown services, incomplete traces) and
ARCH9900 (dependency facts) are not a family: they describe the measurement itself.

## Contract

- **Shape.** One abstract `ArchitectureAttribute` implements `ITestDataSource` and is
  applied with `AllowMultiple = true`. `MonolithAttribute`,
  `MicroservicesAttribute` and `DistributedMonolithAttribute` derive from it and take
  a `RuleFamily` enum whose values are the digits above.
- **Discovery.** Data sources run before any fixture, so `GetData` lists the
  family's rule IDs that are in the source of truth and never runs the analysis. A
  family with none yet yields a failing case that says so, never zero cases. Each ID is its own
  unfolded case named `<Style> <ID> <title>` through `GetDisplayName`, so `--filter`,
  TRX and reruns work per rule.
- **Execution.** Run ArchCheck once per class or assembly (`ClassInitialize` or
  `AssemblyInitialize`), flow `TestContext.CancellationToken`, and cache the report.
  Each case asserts that its rule has no finding left after `archcheck.allow`, and
  prints each finding's location.
- **No measurement, no pass.** When the report carries ARCH9xxx problems for the
  inputs a case needs, the case fails and shows them. Examples: no compose, Kubernetes
  or AppHost input for family 3; no captured spans for ARCH2200, 2201, 4000, 4001 or
  5000. An empty family is a failure, not a pass.
- **Style is intent.** Findings indicate coupling; they do not classify a whole
  system. The style names the architecture the test protects.
- **Real entrypoint.** Drive the analysis through ArchCheck's tool or analyzer, not a
  reimplementation of its rules inside the test.

```csharp
[TestClass]
public sealed class ShopArchitecture
{
    public TestContext TestContext { get; set; } = null!;

    [TestMethod]
    [Monolith(RuleFamily.Dependencies)]
    [Monolith(RuleFamily.Data)]
    public void Rule_has_no_unallowed_findings(string ruleId) =>
        Assert.IsEmpty(ShopReport.Current.Findings(ruleId));
}
```

This is the shape for a real project, where the invariant is "no finding left";
the source of truth below asserts exact sets instead. `ShopReport.Current` stands for the
report the class fixture cached. A
`TestMethodAttribute` subclass (`ExecuteAsync`) could run everything from the
attribute alone, but it returns folded results and loses per-rule filtering.

## Source of truth

Expected results follow from how the input is built, never from ArchCheck's own
output or documentation, so no case can be argued. That keeps the set small: a rule
enters only when one planted change makes its outcome follow from the rule's
definition alone.

- **Baseline.** One minimal solution per style, with its boundaries declared in
  `.editorconfig` (`archcheck.boundary`, `archcheck.shared`) and no violation.
  Invariant: `dotnet build` reports none of the rules in the truth.
- **One planted change per variation.** Baseline plus exactly one change. Invariant:
  `dotnet build` reports exactly that rule's ID, nothing more and nothing less.
- **Pure and idempotent.** Only the analyzer runs (`dotnet build`): no compose,
  Kubernetes, AppHost, spans, history or network. Two runs give the same set.

| ID | The one planted change (from the rule's `RuleCatalog` description) |
| --- | --- |
| ARCH1000 | A file in boundary A uses a type of boundary B; `archcheck.allow` has no `A -> B`. |
| ARCH1001 | `archcheck.allow = A -> B`, B sets `archcheck.public = true`; A uses a B type that is not effectively public. |
| ARCH1002 | `archcheck.deny` lists a namespace; a file in a boundary uses a type from it. |
| ARCH2000 | Boundary B declares a class deriving from a type named `DbContext`; a file in boundary A uses it. |
| ARCH2001 | Shared code declares a class named `*Repository`; files in two boundaries use it. |
| ARCH2002 | Boundary B sets `archcheck.public = true` and declares a public `DbContext` subclass; nothing else uses it. |

That gives 21 invariants: three styles, each with a baseline and six planted
variations, named `<Style> baseline` and `<Style> <ID>`. Before adopting a row,
confirm it against the rule's code in `ArchitectureAnalyzer.cs`. If the planted change
also triggers a second rule, the row is not pure yet: redesign it or leave the rule
out.

Everything else stays outside the truth until it has such a planted case: the tool
rules (ARCH1003, 1100–1104), 2100–2201, and families 3–7, which need external inputs.
Those are discussed as a grouped scope, never one by one. The repository samples
(`samples/Monolith`, `samples/DistributedMonolith`, `samples/Microservices`) combine
several violations and count occurrences, so they are secondary evidence, not truth.
The rule catalog itself is under research: when IDs are dropped or redefined, rebuild
this table from the catalog.
