---
name: supercritical-code-quality-review
description: Run a maximally strict structural code review that hunts complexity-collapse opportunities, oversized files, creeping conditionals, and unearned abstractions, then defends every finding against refutation before reporting it. Use for a supercritical review, deep maintainability audit, especially harsh code-quality review, or when the user asks for a thermo-nuclear-style review.
license: MIT
disable-model-invocation: true
metadata:
  author: ancplua
  heritage: independent rewrite with an adversarial-verification and nested-execution model; the "be ambitious about structure" review bar was popularized by Cursor's team-kit thermo-nuclear review (no text retained)
---

# Supercritical Code Quality Review

A review at criticality: every finding must either start a chain reaction of simplification or be absorbed before it reaches the author. The goal is not "cleaner" — the goal is **less**. Fewer concepts, fewer branches, fewer layers, with behavior provably unchanged.

## Mission

Audit the current branch's changes for implementation quality, maintainability, and abstraction health. Do not settle for local polish. Hunt for the **collapse move**: a reframing of the change that makes whole conditionals, helpers, modes, or layers vanish while behavior stays identical. A good collapse move feels inevitable in hindsight; if nothing about your strongest suggestion feels inevitable, keep looking before you write it down.

Measure twice, cut once: depth of analysis first, volume of comments never.

## Standards

1. **Collapse beats cleanup.** A finding that rearranges complexity is worth less than one that deletes it. Before polishing the implementation the author chose, ask whether a different framing — different ownership boundary, different state model, different default — removes the need for the code entirely.
2. **File growth is a design event.** A PR that pushes a file from under 1,000 lines to over it is presumed wrong until the author argues otherwise. The remedy is decomposition before merge, not a promise to split later.
3. **No conditional creep.** New one-off branches, scattered special cases, or mode flags threaded through unrelated flows are design failures, not style issues. Repeated conditionals on the same shape signal a missing model; an edge case handled mid-function signals a missing boundary.
4. **Working is not done.** Behavior being correct earns nothing. If the structure can be meaningfully simpler at equal behavior, the simpler structure is the requirement, and "it passes the tests" is not a defense.
5. **Boring beats magic.** Generic mechanisms hiding simple data shapes, identity wrappers, pass-through helpers, and clever indirection all owe rent. An abstraction that does not make at least one call site obviously simpler gets deleted, not admired.
6. **Boundaries stay typed and explicit.** Casts, `any`/`unknown`, optional parameters papering over unclear invariants, and silent fallbacks are contract debt. Prefer making the invariant explicit over making the failure quiet.
7. **Logic lives in its canonical home.** Feature logic leaking into shared paths, near-duplicates of existing helpers, and code parked in the wrong layer normalize architectural drift. Reuse the canonical utility or move the logic to the module that already owns the concept.
8. **Orchestration is parallel where independent, atomic where related.** Independent work serialized without reason and related updates that can strand half-applied state are both structural smells when the cleaner shape is visible — flag them without descending into micro-optimization.

## Evidence and refutation

Ambition generates false positives; refutation is the counterweight.

- Every finding carries `file:line`, the current shape, and a sketch of the collapsed shape — a sketch, not an essay.
- Before reporting a blocker, attack it yourself: name the exact behavior the restructure must preserve and check the sketch against it, including error paths and edge inputs. A finding you cannot defend, you do not report.
- Severity ladder:
  - **blocker** — structural regression, or a missed collapse move with a visible path.
  - **restructure** — clearly worth doing, not worth blocking on.
  - **nit** — report only when nothing bigger exists.

## Execution modes

**Solo pass (default, any runtime).** One reviewer, the full diff, all eight standards. Keep the cross-file view — collapse moves usually live between files, not inside one.

**Supercritical cascade (Claude Code 2.1.172+, nested sub-agents).** For large or high-stakes diffs (roughly: >15 files or >1,500 changed lines), go critical: spawn one reviewer per standard in parallel, let each reviewer spawn a refuter per finding, and send surviving collapse proposals to an independent judge panel. Only verified findings reach the merged report. The Claude adapter `adapters/claude/agents/supercritical-review-orchestrator.md` implements this tree; runtimes without nested agents run the solo pass per standard instead.

## Output contract

Report in this order, nothing interleaved:

1. Structural regressions
2. Missed collapse moves
3. Branching-complexity growth
4. Boundary, type, and abstraction-contract problems
5. File-size and decomposition concerns
6. Everything else that survived refutation

Few, high-conviction findings. A review drowning in nits has failed this skill. Be direct about severity — do not soften a structural problem into a suggestion — and never rude about the author.

## Approval bar

Approve only when all of these hold:

- no structural regression
- no visible collapse move left on the table
- no file pushed past the size boundary without a defended reason
- no new ad-hoc branching tangled into existing flows
- no unearned abstraction, wrapper, cast, or optionality churn obscuring the design
- no logic landed outside its canonical home when a clear home exists

Treat a violation of any line above as a presumptive blocker: the author owns the justification, not the reviewer.
