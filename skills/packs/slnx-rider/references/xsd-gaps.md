# Known gaps in Slnx.xsd

Measured 2026-09-17 against `microsoft/vs-solutionpersistence` at commit `ea32bc0`
(the tip of `main`). `assets/Slnx.xsd` in this skill is a byte-identical copy of that
commit's schema.

## The short version

`Slnx.xsd` rejects documents the serializer reads happily. It is not a specification.
It was added in response to issue [#121](https://github.com/microsoft/vs-solutionpersistence/issues/121)
("Feature Request: XSD Schema for SLNX Files", closed 2025-05-07), whose entire
rationale was *"Having an XSD available would enable intellisense in vscode and other
tools."* Issue [#64](https://github.com/microsoft/vs-solutionpersistence/issues/64)
("Specification of slnx?") is still **open** — there is no normative spec. The
serializer is the ground truth; the schema is a convenience that lags it.

How the drift started is visible in the git history: PR
[#120](https://github.com/microsoft/vs-solutionpersistence/pull/120) added
`DefaultStartup` support on 2025-05-06, touching `Keywords.cs` and `XmlProject.cs` and
**not** the schema. The schema landed one day later, already missing that attribute.
Nothing has fixed it since — no merged PR touches `Slnx.xsd`.

## The four gaps

| # | Construct | Schema says | Serializer says |
|---|---|---|---|
| 1 | `Project/@Id` | attribute not declared | `XmlProject.cs:26-30` — `GetXmlAttributeGuid` / `UpdateXmlAttributeGuid` |
| 2 | `Project/@DefaultStartup` | attribute not declared | `XmlProject.cs:46-47` — `GetXmlAttributeBool` |
| 3 | `Properties/@Scope="PreLoad"` | `Slnx.xsd:84` — `fixed="PostLoad"` | `XmlProperties.cs:101-107` — `PostLoad` or `PreLoad` |
| 4 | `<Property>text</Property>` | `Property` has empty content type | round-tripped; see `SlnAssets/SlnxWhitespace/JustProperties.slnx.xml:12-13` |

`Keywords.cs` lists every name the serializer recognizes. Cross-checking that enum
against the schema is how gaps 1-3 were found; the enum entries `MaxProp` and `Unknown`
are sentinels and not real gaps, and `Dimension` is used by the classic `.sln` path only.

### Gap 3 is narrower than it looks

`PreLoad` is the default scope, and the writer omits the attribute when the scope is
`PreLoad` (`XmlProperties.cs:27`, `isDefault: value == PropertiesScope.PreLoad`). So an
explicit `Scope="PreLoad"` is read correctly but never produced. It only bites on
hand-written files. Gaps 1 and 2 are the ones the serializer writes itself, so those are
the ones encountered in the wild.

## The measurement that settles arguments

Microsoft's own test assets fail Microsoft's own schema:

```
48 official .slnx test assets
16 fail Slnx.xsd
   of which 2 fail on purpose:
     Comments.slnx.xml   - round-trip test for deliberately unknown XML
     WrongRoot.slnx.xml  - negative test, wrong root element
   14 are the schema lagging the serializer
```

Breakdown of the 14:

| Failure | Files |
|---|---|
| `Id` (10) | `KitchenSink.slnx.xml` + its 5 `-Add*` variants, `DuplicateFolderId`, `DuplicateProjectId`, `LegacyValues`, `LegacyValues-NoObsolete` |
| `DefaultStartup` (1) | `DefaultStartup.slnx.xml` |
| `Property` text content (3) | `JustProperties.slnx.xml`, `JustProperties-add0add7`, `JustProperties-no2no4` |

## Re-measuring against current upstream

Worth redoing before relying on the table above — the gaps may have been fixed.

```bash
git clone --depth 1 https://github.com/microsoft/vs-solutionpersistence.git vsp
cd vsp
X=src/Microsoft.VisualStudio.SolutionPersistence/Serializer/Xml/Slnx.xsd
find test -name '*.slnx.xml' | sort | while IFS= read -r f; do
  xmllint --schema "$X" "$f" --noout 2>&1 | grep -q validates || echo "FAIL $f"
done
```

Quote paths (`"$f"`) — some asset directories contain spaces, and an unquoted loop
reports "failed to load external entity" as though it were a validation failure.

To check whether a specific keyword is still missing from the schema:

```bash
sed -n '/enum Keyword/,/^}/p' \
  src/Microsoft.VisualStudio.SolutionPersistence/Serializer/Xml/Keywords.cs \
  | grep -oE '^\s+[A-Za-z]+,' | tr -d ' ,' \
  | while read k; do grep -q "\"$k\"" "$X" || echo "missing from xsd: $k"; done
```

## Minimal reproduction

```xml
<Solution>
  <Folder Name="/f/">
    <Project Path="p/p.csproj" Id="11111111-2222-3333-4444-555555555555" DefaultStartup="true" />
  </Folder>
  <Properties Name="Test" Scope="PreLoad">
    <Property Name="k" Value="v" />
  </Properties>
</Solution>
```

`xmllint --schema Slnx.xsd` reports three errors and `fails to validate`.
`dotnet sln <file> list` loads it and prints the project.
