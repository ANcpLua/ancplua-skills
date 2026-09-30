# Failure modes

A diagnostic catalog for common prompt failures. Use this when the user reports a behavior and the cause isn't immediately obvious. For each failure pattern: typical symptoms, likely causes in order of frequency, and the minimum-viable fix.

The discipline: name the failure, hypothesize a cause, propose the smallest fix that addresses that cause, verify on the actual failing case. Don't escalate to "rewrite the whole prompt" until simpler fixes have been tried.

## Inconsistent outputs across runs

**Symptoms:** Same input, different outputs each call. Format drifts, level of detail varies, tone fluctuates.

**Likely causes:**

1. The prompt under-specifies the dimension that's drifting. The model is making a free choice each time because the prompt didn't pin it down.
2. The prompt over-specifies in ways that conflict, so the model resolves the conflict differently on different runs.
3. The task is genuinely ambiguous and reasonable answers vary.
4. Temperature is too high for the task. (Less common — usually a temperature concern is "outputs are weird," not "outputs are inconsistent.")

**Fix:** Identify which axis is drifting (format? length? tone? content selection?). Add one concrete example showing the desired value on that axis. If multiple axes drift, pick the one that matters most and add an example targeting it, before fixing others.

## Model ignores a specific instruction

**Symptoms:** An instruction is clearly in the prompt, but the model behaves as if it isn't there.

**Likely causes:**

1. The instruction is contradicted by another instruction the model is prioritizing.
2. The instruction is buried in the middle of a long prompt where attention is weakest.
3. The instruction is phrased as a suggestion ("try to…", "ideally…") and the model treats it as optional.
4. An example elsewhere in the prompt shows behavior that *violates* the instruction, and the example wins.
5. The instruction is in scope for a different task than the one the user is actually running.

**Fix:** Check for contradictions first — search the prompt for instructions about the same topic and reconcile. If no contradiction, move the instruction to a high-attention location (top of the prompt or just before the task statement) and check that any examples in the prompt are consistent with it.

## Model invents facts (hallucinates)

**Symptoms:** Model produces plausible-sounding but false claims, often confidently.

**Likely causes:**

1. The task implicitly requires knowledge the model doesn't have, and the prompt doesn't authorize "I don't know."
2. The prompt asks the model to produce a specific output structure that's hard to leave blank, so the model fills it with invention.
3. Retrieval-augmented context exists but is missing the relevant fact, and the model doesn't distinguish between "found in context" and "drawing on training."
4. The prompt frames the model as an expert, which discourages hedging.

**Fix:** Add an explicit allow-uncertainty clause: *"If you're not certain, say so. Distinguish between facts found in the provided context and facts you're drawing on from elsewhere."* If structure is forcing invention, make the structure permit unknowns ("if a field can't be determined, use null and add the field name to an `unknowns` array"). Avoid telling the model not to hallucinate — that's asking it to predict its own behavior, which doesn't work.

## Output is too verbose

**Symptoms:** Model produces walls of text when a short answer is wanted. Excessive preamble, restating the question, exhaustive caveats.

**Likely causes:**

1. No constraint on length and the model defaults to thorough.
2. The prompt asks for "comprehensive" or "detailed" earlier and that's anchoring length high.
3. Chain-of-thought was requested and is appearing in the visible output.
4. The model is producing apologetic or hedging language that adds length without adding content.

**Fix:** Specify length concretely — not "be concise" but "answer in one sentence" or "no more than three bullet points." Prefill the response to skip preamble if possible. If chain-of-thought is leaking into output, move it to a `<scratchpad>` tag or to thinking blocks.

## Output is too terse

**Symptoms:** Model gives short, unhelpful answers. Strips out reasoning, skips important detail.

**Likely causes:**

1. The prompt over-emphasized brevity and the model overcorrected.
2. The model thinks the user has the context already because the prompt implied it.
3. The task example showed a short answer for a simple case and the model is generalizing.

**Fix:** Soften the brevity instruction and specify when detail is warranted ("be concise, but include reasoning when the answer isn't obvious"). Provide an example of the right level of detail for a non-trivial case.

## Format compliance failures

**Symptoms:** Asked for JSON, got JSON wrapped in markdown code blocks. Asked for a specific structure, got a structurally similar but different one.

**Likely causes:**

1. The prompt described the format but didn't show it.
2. The model is in "conversational" mode and adds chat-style framing around the structured part.
3. The format described is ambiguous (e.g., "a JSON object" could mean many shapes).

**Fix:** Show the format with a concrete example, not just a description. Prefill the opening character of the format (`{` for JSON, `<tag>` for XML). For high-reliability needs, parse downstream and retry with a corrective prompt on failure.

## Model follows the format of an example too literally

**Symptoms:** Example showed a 3-bullet list and now every response has exactly 3 bullets. Example used specific wording and the model echoes it.

**Likely causes:**

1. Single example is being treated as canonical on all axes.
2. Examples are too similar to each other and the model averages them.

**Fix:** Call out which parts of the example are canonical vs. illustrative ("the structure is canonical; the number of items and the wording will vary by task"). Or provide multiple examples that vary the dimensions that should vary, so the model learns what's stable and what isn't.

## Wrong tone

**Symptoms:** Model is too formal when casual was wanted, too cheerful when neutral was wanted, too hedging when direct was wanted.

**Likely causes:**

1. Tone was specified with adjectives ("professional", "friendly") that route through the model's prior of what those words mean.
2. The role / persona is producing a register that doesn't match the actual audience.
3. The task domain has a default register the model is reaching for (technical writing → formal; customer support → cheerful) that doesn't match the specific use case.

**Fix:** Anchor tone with one example sentence in the desired register. Specify the audience concretely ("write for a senior engineer who'll skim this in their inbox"). Drop the persona if it's producing the wrong register without adding value.

## Refusals on benign tasks

**Symptoms:** Model refuses, hedges, or adds excessive caveats on tasks that should be straightforward.

**Likely causes:**

1. The task is in a domain (medical, legal, financial) where the model defaults to cautious.
2. Prompt phrasing triggered a safety heuristic (e.g., "help me get around" reads as "circumvent" even when it's literal).
3. The model is asked to take on a role it interprets as requiring professional disclaimers.

**Fix:** Clarify the use case ("this is for a developer documentation page", "this is for internal use, written by and for licensed practitioners"). Rephrase task verbs that have ambiguous connotations. Remove role framing that triggers professional-advice caution if it's not adding value.

## Format drift over a long output

**Symptoms:** Output starts in the right format and degrades. The first section is well-structured; by section five the structure has slipped.

**Likely causes:**

1. The format instruction is at the top of the prompt and attention has moved away by mid-output.
2. The task is long enough that the model is improvising structure as it goes.
3. The model is trying to keep the output interesting and varying structure to do so.

**Fix:** Repeat the structural constraint right before the task statement. For very long outputs, consider chaining — produce one section at a time and stitch together — rather than expecting consistency over a long single response.

## Model contradicts itself within one response

**Symptoms:** Output asserts X in one place and not-X in another, sometimes within paragraphs of each other.

**Likely causes:**

1. The task is genuinely under-determined and the model is generating plausible content in both directions.
2. The model is parroting two sources from training data that disagree.
3. The prompt asks the model to consider multiple perspectives, and the model isn't tagging which is which.

**Fix:** Constrain the model to pick a position or commit to one path. If the goal is to explore perspectives, ask explicitly for them to be labeled and contrasted, not woven together.

## Model adds unwanted preamble or closing

**Symptoms:** "Sure! Here's what you asked for…" before the content. "Let me know if you need anything else!" after.

**Likely causes:**

1. Conversational defaults — the model treats the interaction as chat unless told otherwise.
2. No prompt instruction to skip these.

**Fix:** Prefill the response with the first character of the actual content. Or explicitly instruct: "Skip preamble. Begin your response with [the actual content]." Closing pleasantries respond to "End immediately after [the substantive part]."

## When the failure doesn't match any of these

Some failures are genuinely novel or task-specific. The general approach:

1. Get the literal prompt and the literal output. Don't work from the user's summary of either.
2. Read the prompt aloud (mentally) as if you have no context outside the prompt. What does it actually instruct?
3. Find the smallest plausible change that would have produced the desired output instead.
4. Apply that change, test, observe.

If the failure persists after two or three minimum-viable fixes, that's a signal the prompt has accumulated enough cruft that a leaner rewrite is the right move, not another patch.
