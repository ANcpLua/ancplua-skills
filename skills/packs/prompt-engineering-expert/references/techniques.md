# Techniques

This is a catalog of techniques organized around **when each one actually helps** vs. when it adds noise. Read it when designing a new prompt and considering which techniques to apply, or when a user asks "should I use X here?"

The defaults in this document assume modern Claude. Older models behaved differently on several of these.

## Few-shot examples

**When it helps:**

- The task has a specific output format that's hard to describe in words but easy to show.
- The task has implicit conventions (tone, level of detail, what to skip) that an example demonstrates without you having to itemize.
- You want consistent format across many invocations and have observed drift.
- The task is classification or extraction with multiple categories, and the categories are easier to recognize than to define.

**When it doesn't help, or hurts:**

- The task is fully described by instructions and the model is already doing it well. Adding examples just costs tokens.
- Your examples cover only the easy case; the model then handles edge cases poorly because it pattern-matches to the easy case.
- The examples are subtly inconsistent with each other (different formats, different levels of detail). The model averages them and produces neither.
- The task is a one-off that won't repeat — the cost of writing good examples isn't recouped.

**How many examples:**

- **Zero** is the right answer often. Try the instructions-only version first; add examples only when you see a failure they'd fix.
- **One** disambiguates format. Use when the format is the thing that varies.
- **Three** is the sweet spot for showing range. Pick three that span the categories the task involves — not three near-duplicates of the easy case.
- **Five-plus** rarely helps more than three and starts to overfit. If you find yourself wanting many examples, ask whether the task should be decomposed.

**Choosing examples:**

The most common mistake is picking the easy case. The model already handles the easy case. Pick the cases that *force* the desired behavior on the dimensions you care about: the edge case, the case where the obvious response is wrong, the case where the format is non-obvious. Examples should teach the model what to do at the hard points, not reassure you the prompt works on the easy ones.

## Chain-of-thought / reasoning

**When it helps:**

- Multi-step arithmetic, logic, or analysis where the model jumping straight to an answer is likely to be wrong.
- Tasks where you want to be able to *audit* the model's reasoning afterward.
- Tasks where the user benefits from seeing the reasoning even if it's longer.

**When it doesn't help, or hurts:**

- Simple lookup or classification tasks. The "reasoning" the model produces is post-hoc rationalization and just makes the output longer.
- Tasks where you want a clean, short output that gets pasted somewhere. Reasoning leaks into the user-visible output and the user has to strip it.
- Tasks where you're already asking for structured output. Adding "think step by step" can fight against the structure.

**How to invoke it:**

- For models with native thinking blocks (Claude with extended thinking enabled): use the thinking capability directly rather than asking for reasoning in the visible output.
- Without thinking blocks: ask for reasoning in a tagged section, e.g., `<scratchpad>…</scratchpad>` before the final answer. You can then ignore or hide the scratchpad downstream.
- "Let's think step by step" works but is generic. Better: name the steps you want the model to actually take. "First identify the constraints, then enumerate solutions that satisfy them, then evaluate each on the criteria given."

## Prefilling

Prefilling — providing the start of the assistant's response — is one of the most under-used techniques and one of the most effective.

**When it helps:**

- Locking in output format. Prefilling with `{` for JSON, or `Here are the three issues:\n\n1.` for a numbered list, dramatically increases format compliance.
- Skipping preamble. Models often open with "Sure! I'd be happy to help…" — prefilling with the first character of the actual content cuts that off.
- Maintaining a persona or register. Prefilling the response with a phrase in the desired voice anchors it.
- Continuing a partial output. If a previous generation was cut off, prefilling the next response with the continuation point lets the model resume.

**When it doesn't help:**

- When you want the model to refuse or push back. Prefilling can bypass the model's normal refusal behavior, which is what you want for format control but not what you want for safety-relevant tasks.
- When the prefilled content commits to a choice the model should be making. "Yes, that's correct because…" prefilled will produce justification for the prefill even if the right answer was "no."

**Practical patterns:**

- JSON output: prefill `{` (or `{"`) and ensure the system prompt asks for JSON. Combine with a schema example for best results.
- Lists: prefill `1.` or `- `.
- Forcing structure: prefill the opening tag of the expected XML structure, e.g., `<analysis>`.

## XML structuring

Covered in `principles.md` under "XML tags as structure." The technique-level point:

The reliable pattern is **tags as containers for content of different roles**, not tags as semantic markup. Good tag names: `<context>`, `<task>`, `<examples>`, `<document>`, `<schema>`, `<previous_attempt>`, `<output>`. Bad tag names: anything that looks like it should drive logic the model can't actually execute (`<if>`, `<rule severity="high">`, `<critical>`).

## Decomposition / prompt chaining

When a task is large, two approaches:

**Monolithic:** one prompt, one call. The model handles the whole thing. Cheaper, simpler, less infrastructure.

**Chained:** decompose into stages, each in its own call. More expensive, more complex, but often produces better results on:

- Tasks where stage 1 produces structured intermediate output that stage 2 consumes deterministically (e.g., classify, then route to a category-specific handler).
- Tasks where the model's behavior on the full task degrades because it's juggling too many constraints at once.
- Tasks where you want to insert validation, retrieval, or tool calls between stages.

**When to keep it monolithic:**

- The stages are tightly coupled and stage 2 needs full context from stage 1 anyway.
- The task is short enough that the model isn't overloaded.
- Latency matters more than peak quality.

**When to chain:**

- You observe the monolithic version degrading on a specific sub-task.
- The intermediate output is small and structured, so the chain has narrow interfaces.
- The chain matches how a human would naturally split the work.

A common middle ground: one prompt with explicit sequential steps (`First, do X. Then, given X, do Y. Finally, combine.`) — gets some of the benefit of decomposition without separate calls.

## Extended thinking

When the model has extended thinking available (e.g., Claude with thinking blocks), the question is when to *enable* and *encourage* it.

**Enable when:**

- The task involves planning, multi-step reasoning, or evaluation against criteria.
- Output quality matters more than latency.
- The visible output should be clean — thinking is hidden from the end user.

**Don't enable when:**

- The task is a quick lookup or transformation.
- Latency is critical.
- You're already getting good results without it.

In skill instructions and system prompts, you can prompt for thinking explicitly: "Before responding, think through the constraints and check for contradictions." This nudges the model toward using thinking productively for the task type.

## Tool-use prompting

When the model has tools available, the prompt should make clear:

- **What each tool is for** — one-line purpose in the tool description.
- **When to call it** vs. when to answer directly. Models tend to over-call tools when description is vague ("search the web for any question") and under-call when description is too specific.
- **What inputs the tool wants** — examples in the tool description help more than abstract type signatures.
- **What to do with results** — especially when results are messy or partial.

A common failure: tools described purely by their parameters with no guidance on when to use them. The model then guesses, often wrong. Add a sentence to the tool description that says when to reach for it.

For complex tool sequences (do A, observe, then B or C), an example in the system prompt of a successful sequence outperforms abstract instructions about ordering.

## Output structuring

When you need machine-parseable output:

- **JSON:** ask for JSON, give a schema or example, prefill `{` if possible. For best reliability, also specify what the model should do when it can't fill a field ("use null", "omit the field", "fill with an empty string and add the field to an `unfilled` array").
- **Specific tags:** ask for output wrapped in known tags. Tags are more forgiving than JSON for downstream parsing — the model is less likely to break the format with stray escape characters.
- **Markdown tables:** lower reliability than tags or JSON; the model sometimes adds explanatory prose before or after. Use only when humans, not parsers, consume the output.

For high-stakes structured output, validate downstream and retry with the validation error included in a follow-up prompt. The model usually fixes its own mistakes when told what was wrong.

## Negative examples

Often more powerful than positive ones for shaping behavior on specific failure modes.

Pattern: *"Here is an example of what not to do, and why:"* followed by the bad output and a one-sentence explanation. The model learns the failure mode you're trying to prevent more crisply than from a positive example alone.

Use sparingly — every negative example also costs tokens and risks the model fixating on the specific pattern you showed. One or two well-chosen negatives anchored to real failures are usually enough.

## Self-critique and revision

Asking the model to produce an answer, then critique it, then revise — in one prompt or as a chain — sometimes improves quality. Sometimes it doesn't.

**When it helps:**

- The task has clear quality criteria the model can evaluate against.
- The model's first-pass answer is good-but-not-great and a second pass catches issues.

**When it doesn't help:**

- The model can't reliably evaluate its own work on this task (e.g., factuality of obscure claims).
- The "critique" surfaces nothing useful and the "revision" just rephrases.
- The user wants a clean answer, not three passes of reasoning.

It's worth trying on tasks where quality matters, but don't apply it by default. Test it on your actual task and see if revisions are meaningfully better than first passes.

## What not to bother with

A few techniques that get cited a lot but rarely justify their cost on modern models:

- **Emotional appeals** ("this is very important to my career") — older models responded measurably to these; current Claude is largely invariant. Skip.
- **Threats or rewards** ("I'll tip $200 for a good answer") — same story. Skip.
- **Repeating instructions for emphasis** — rarely helps; often makes the prompt feel cluttered and the model treat the repeated instruction as more important than other instructions of equal real weight. Use placement and explanation instead.
- **All-caps for emphasis** — sometimes helps as a marker for genuinely critical constraints, but loses signal fast if used on multiple things. If three instructions are in caps, none of them stand out.
