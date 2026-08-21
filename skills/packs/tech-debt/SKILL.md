---
name: tech-debt
description: Evidence-grounded technical-debt audit. Hunts accretion — code that was added (shimmed, wrapped, re-validated, try/catch-padded) when it should have been deleted — plus NativeAOT/source-generator hazards. Trigger with "tech debt", "technical debt audit", "what should we refactor", "code health", or when the user asks about code quality, refactoring priorities, or maintenance backlog.
---

# Tech Debt — Accretion Audit

Debt here is code that was **added** when it should have been **deleted**. The remedy column is deletion, not a nicer abstraction. Every finding is grounded in the actual code, never in a heuristic. If you can only describe a finding in prose, you have not read it yet — go read it.

## Accretion signatures

Hunt these. Each row is: what it looks like, how to find it, and the fix (which is removal).

| Signature | Detection | Fix |
|-----------|-----------|-----|
| Wrapper/adapter/shim that only forwards | `class \w*(Adapter\|Wrapper\|Shim\|Compat\|Proxy\|Manager)` whose methods just delegate | Inline the callee, delete the layer |
| Parallel old/new both reachable | `\w+(V2\|Old\|New\|Legacy\|_v\d)` with both live | Pick one, migrate callers, delete the other |
| Back-compat left in place | `[Obsolete]`, `#pragma warning disable`, `TODO: remove`, `kept for compat` | If nothing depends on it, delete now. If something does, *that dependency* is the finding |
| Validation of validation | Second null/range check on a value already guarded upstream; `ThrowIfNull` then `if (x is null)` again downstream | One guard at the boundary, delete the rest |
| Try/catch bloat | `catch (Exception)`, catch→log→rethrow, `try` wrapping >1 operation | Early guard return; let it throw where you cannot handle it |
| Magic literal | Same numeric/string literal ≥2× | One named const. If it is config, one source |
| Premature abstraction | Interface/base with exactly one impl and one caller | Collapse to the concrete type |
| God unit | File/class > ~400 LOC or method > ~40 lines mixing concerns | Split by concern, not by line count |

Thresholds (400 / 40 / ≥2×) are defaults — tune to the repo.

## .NET / NativeAOT lens

Debt that a generic audit misses and that breaks your hard constraints:

- **Reflection creep** — `GetMethod` / `GetProperties` / `Activator.CreateInstance` / `Type.GetType("` / `dynamic` / `Expression.Compile`. Each is a trim/AOT hazard (IL2xxx / IL3050). Fix is a source generator or a compile-time constant map, not a suppression.
- **Runtime magic where a generator belongs** — reflection-based DI scanning, mapping, serialization. Move to source-gen. Flag the ones not yet migrated.
- **Generator TFM drift** — a `*.Generators` / `*.SourceGenerators` / analyzer project not targeting `netstandard2.0`, or reaching for net10-only APIs. Breaks analyzer load in the compiler host.
- **Suppressed AOT/trim warnings** — `[RequiresUnreferencedCode]`, `[RequiresDynamicCode]`, `[UnconditionalSuppressMessage(... "IL2\d{3}")]`, `<IlcTrim*>`. A suppression added to *silence* rather than to *prove safe* is debt.

## Evidence gate

Each finding is:
1. `path:line`
2. the offending snippet
3. the deletion that removes it

No prose-only findings. Level is **seziert**, not überflogen — if the snippet is not shown, the finding does not ship.

## Looks bad but is fine

Required section. Do not flag intentional structure — a false positive costs a whole session:

- Adapter at a real boundary (third-party OTel exporter, external SDK) — deliberate isolation, not debt.
- `catch` that maps to a domain error at an API edge — that is the handler, keep it.
- Constant projection matrix / FrozenDictionary marker pack generated from YAML — AOT-safe by design, not a magic-literal smell.
- A single well-named literal used once — not magic.

For each thing that looks like a signature hit but is intentional, name it and say why it stays.

## Prioritization

Score each finding:
- **Impact**: How much does it slow you down? (1-5)
- **Risk**: What happens if it stays? (1-5)
- **Effort**: How hard is the fix? (1-5, inverted — lower effort = higher priority)

Priority = (Impact + Risk) x (6 - Effort)

## Output

Produce a chat todo list. Not a document, not a memory. It is worked through in order and can be paused when something unexpected comes up. Each item carries its `path:line` and priority score.

Order the items so the encompassing fix comes before its parts. Never work a subset before the item that contains it.

If the scope is too large for one pass, split it into scoped, cohesive sessions. Prefer three sessions of ~20 items over one list of 50. Each session can then be delegated or run on its own.
