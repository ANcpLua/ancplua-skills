#:property PublishAot=false
#:property Nullable=enable

// Claim coverage from the LeanTest markers in .trx files.
// Usage: dotnet run claim-coverage.cs -- <results.trx>... --claims <Namespace.Spec.Claim>...
// A test covers a claim when its StdOut carries `TestTag = ###---<claim>---###`, which LeanTest.MSTest's RegisterAttributes
// writes for [TestTag]; `TestScenarioId = ###---<id>---###` names the Lean counterexample or witness the test replays.
// Output (stdout): deterministic JSON. Exit: 0 every claim has a passed test, 2 usage, 5 no LeanTest markers in any result
//                  (not evidence: RegisterAttributes is missing), 6 a claim uncovered or not passed, or a stale tag.
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Xml.Linq;

int ci = Array.IndexOf(args, "--claims");
if (ci < 1 || ci == args.Length - 1) return Usage();
var trxPaths = args[..ci].Select(Path.GetFullPath).ToList();
var claims = args[(ci + 1)..].Distinct().ToList();

XNamespace t = "http://microsoft.com/schemas/VisualStudio/TeamTest/2010";
var marker = new Regex(@"^(TestScenarioId|TestTag) = ###---(.*?)---###\r?$", RegexOptions.Multiline);
var results = new List<Result>();
foreach (var path in trxPaths)
{
    if (!File.Exists(path)) { Console.Error.WriteLine($"No such file: {path}"); return 2; }
    foreach (var r in XDocument.Load(path).Descendants(t + "UnitTestResult"))
    {
        var stdout = r.Element(t + "Output")?.Element(t + "StdOut")?.Value ?? "";
        var found = marker.Matches(stdout).Select(m => (kind: m.Groups[1].Value, value: m.Groups[2].Value)).Distinct().ToList();
        results.Add(new Result(
            (string?)r.Attribute("testName") ?? "?",
            (string?)r.Attribute("outcome") ?? "?",
            Path.GetFileName(path),
            [.. found.Where(f => f.kind == "TestScenarioId").Select(f => f.value).Order(StringComparer.Ordinal)],
            [.. found.Where(f => f.kind == "TestTag").Select(f => f.value).Order(StringComparer.Ordinal)]));
    }
}

var tagged = results.Where(r => r.ScenarioIds.Count + r.Tags.Count > 0)
    .OrderBy(r => r.Test, StringComparer.Ordinal).ThenBy(r => r.Trx, StringComparer.Ordinal).ToList();
var coverage = claims.Select(c => new
{
    claim = c,
    tests = tagged.Where(r => r.Tags.Contains(c)).Select(r => new { test = r.Test, outcome = r.Outcome, trx = r.Trx, scenarioIds = r.ScenarioIds }).ToList(),
}).ToList();
var stale = tagged.SelectMany(r => r.Tags).Where(tag => !claims.Contains(tag)).Distinct().Order(StringComparer.Ordinal).ToList();

var json = new JsonSerializerOptions { WriteIndented = true };
Console.WriteLine(JsonSerializer.Serialize(new { trx = trxPaths.Select(Path.GetFileName), results = results.Count, untagged = results.Count - tagged.Count, claims = coverage, stale }, json));
if (tagged.Count == 0) { Console.Error.WriteLine("No LeanTest markers in any result: call RegisterAttributes(TestContext, Assembly) in [TestInitialize]."); return 5; }

var problems = new List<string>();
foreach (var c in coverage)
{
    if (c.tests.Count == 0) problems.Add($"UNCOVERED {c.claim}");
    else if (!c.tests.Any(x => x.outcome == "Passed")) problems.Add($"NOT-PASSED {c.claim}");
}
problems.AddRange(stale.Select(s => $"STALE {s}"));
problems.ForEach(Console.Error.WriteLine);
if (problems.Count > 0) return 6;
Console.Error.WriteLine($"OK: all {claims.Count} claims covered by a passed test.");
return 0;

static int Usage() { Console.Error.WriteLine("usage: dotnet run claim-coverage.cs -- <results.trx>... --claims <Namespace.Spec.Claim>..."); return 2; }

record Result(string Test, string Outcome, string Trx, List<string> ScenarioIds, List<string> Tags);
