# The four null-checks

Run all four. Do not stop at the first hit — each one leaves a verdict you never have
to revisit, and a later step frequently explains a symptom an earlier step only half
explains. Record what each one said.

Fixing the wrong one of the two systems (the `.slnx` for what the solution contains,
`indexLayout.xml` for what Rider indexes) is the most common way to waste an hour here.

## a) Validate against the schema

```bash
xmllint --schema assets/Slnx.xsd <file>.slnx --noout
```

A PASS is permanent — that branch is closed. A **FAIL is not proof of a bug**, because
`Slnx.xsd` is incomplete: it was contributed as an IntelliSense convenience, not as a
specification, and the serializer has moved past it. Four failure signatures are known
false alarms:

| Signature in the xmllint output | Verdict |
|---|---|
| `attribute 'Id' is not allowed` | false alarm, valid |
| `attribute 'DefaultStartup' is not allowed` | false alarm, valid |
| `value 'PreLoad' does not match the fixed value constraint 'PostLoad'` | false alarm, valid |
| `Element 'Property': Character content is not allowed` | false alarm, valid |

Anything else: confirm it once with `dotnet sln <file>.slnx list`. If dotnet loads the
solution, you found a further schema gap — record it and move on. If dotnet also fails,
it is a real error, and dotnet's message is the one to act on.

[xsd-gaps.md](xsd-gaps.md) has the source-level evidence for each gap and a one-liner that
re-measures them against current upstream. Read it if a FAIL doesn't match the table
above, or if someone disputes that the schema is wrong.

## b) Is there both a `.sln` and a `.slnx`?

Rider opens the `.sln`. Every edit to the `.slnx` then goes nowhere visible. Delete the
`.sln` — but confirm first with `dotnet build <file>.slnx` that the `.slnx` is complete,
because the two files drift and the `.slnx` is often the newer, less-maintained one.

## c) Does every path resolve?

Test each `<File Path>` and `<Project Path>` against the filesystem individually. The
serializer does not warn about a `<File>` pointing at nothing; it silently lists an entry
the IDE then cannot open.

## d) Is the IDE older than the file?

```bash
ps -o lstart= -p $(pgrep -f Rider.Backend | head -1)   # when Rider loaded
stat -f "%Sm" <file>.slnx                              # when the file changed
```

If Rider started first, it is holding a model built from the old file — possibly from a
`.sln` that no longer exists. Nothing observed in the UI is evidence until it has been
reopened. This step is last because it is the one people skip, and it invalidates every
UI-based observation made before it.
