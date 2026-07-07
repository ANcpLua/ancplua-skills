# Before / after examples

Concrete rewrites with commentary on what changed and why. Useful as anchors when explaining a recommendation to a user — point at an example that matches their situation rather than reciting principles abstractly.

Each example shows a real failure pattern, the rewrite, and the rationale. They're meant to be read as case studies, not templates to copy.

---

## Example 1 — Vague task → specific task

**Before:**

> Analyze this customer feedback and tell me what's important.

**After:**

> You'll be given a paragraph of customer feedback. Produce a structured summary with:
>
> - **Sentiment** (positive / negative / mixed), in one word.
> - **Concrete issues raised**: bullet points, one per issue, quoting the relevant phrase from the feedback so we can trace each issue back.
> - **Implicit signals**: things the customer didn't say outright but the feedback suggests — tone shifts, comparisons to other products, what they expected that wasn't met. Skip this section if you don't find anything; don't invent.
>
> The audience is the product team. They'll skim this; prioritize things they can act on.

**What changed:**

The original is vague on every dimension: what counts as "important," what format the output should take, who's reading it. The rewrite pins down structure (three named sections), specifies traceability (quoting source phrases), authorizes skipping the third section instead of inventing content for it, and names the audience so the model calibrates depth and tone.

The "skip … don't invent" clause is the kind of escape hatch that prevents hallucination on the dimension most likely to invite it.

---

## Example 2 — Kitchen-sink prompt → lean prompt

**Before:**

> You are an expert prompt engineer with over 20 years of experience designing prompts for large language models. You have deep knowledge of all major LLM providers including OpenAI, Anthropic, Google, and Meta. You always provide thorough, well-structured responses. You are friendly and professional. You explain your reasoning step by step. You never hallucinate. You always check your work. You are thorough but concise. You consider multiple perspectives. You ask clarifying questions when needed. You provide examples to illustrate concepts.
>
> Help me improve my prompts.

**After:**

> Help me improve my prompts. Workflow:
>
> 1. Ask me what the prompt is supposed to do and what failure case I've seen, if any.
> 2. If I haven't seen a failure yet, draft a v1 and tell me to test it before iterating.
> 3. When I bring you a failure case, diagnose before prescribing — locate where in the prompt the failure could have been prevented.
> 4. Propose the smallest change you think will fix it. If you have alternatives, say so but don't pile them on by default.
>
> Push back if I ask you to add a rule for a problem I haven't actually seen.

**What changed:**

The original is mostly persona theater — 100+ words of vibe with one ten-word task at the end. The persona contradicts itself ("thorough but concise"), restates defaults the model already does ("friendly", "checks work"), and instructs the impossible ("never hallucinate").

The rewrite drops the persona entirely and replaces it with a workflow the model can actually execute. The "push back" line gives the model permission to resist the user's instinct toward speculative additions — which is exactly the failure mode the original prompt would otherwise create in the user's own prompts.

---

## Example 3 — MUSTs and NEVERs → explained reasoning

**Before:**

> CRITICAL RULES — YOU MUST FOLLOW THESE:
>
> - NEVER use emojis.
> - NEVER use bullet points.
> - ALWAYS use professional language.
> - ALWAYS use complete sentences.
> - NEVER end responses with questions.
> - ALWAYS keep responses under 200 words.

**After:**

> This output will be pasted into a business email. Constraints:
>
> - No emojis, bullets, or markdown formatting — they don't render in the destination and will look broken.
> - Register: business-formal. Imagine you're writing to a senior colleague you've never met.
> - Keep it under 200 words. If the answer genuinely needs more space, ask me to split it across messages rather than going long.
> - End with a definitive statement, not a question. The recipient won't reply.

**What changed:**

The original stacks six rules with no context, which has two failure modes: (a) the model can't decide which rule wins when they conflict, and (b) the model follows them too literally in edge cases — e.g., refusing to use a numbered list when one would actually help.

The rewrite explains *why* the constraints exist ("destination doesn't render markdown", "recipient won't reply"). Now the model can generalize: it knows to skip not just bullets but also other markdown features, and the "no questions" rule is grounded in something the model can reason about rather than treat as arbitrary.

The "ask me to split" clause is a small but valuable concession — it gives the model a way out when the length constraint genuinely conflicts with the task.

---

## Example 4 — Hallucination-prone → calibrated uncertainty

**Before:**

> You are a knowledgeable assistant. Answer questions accurately. Do not make things up.

**After:**

> Answer questions to the best of your knowledge. Three rules for handling uncertainty:
>
> 1. If you don't know something, say so directly. "I'm not sure" is a valid answer.
> 2. If you have partial information, share what you know and mark the gap. "I know X, but I don't know whether Y holds in this case."
> 3. If a question depends on facts that may have changed (current events, version numbers, prices, recent releases), note that your knowledge may be stale and suggest a way to verify.
>
> If you're confident, just answer. Don't hedge on things you know well.

**What changed:**

"Do not make things up" is asking the model to predict its own behavior, which doesn't work. The rewrite replaces this with concrete productions the model can actually execute: three named ways of expressing uncertainty, with guidance on when each applies.

The final clause matters: without it, the prompt would push the model to over-hedge everything, which is its own failure mode. "If you're confident, just answer" calibrates the model to use the uncertainty toolkit only where it applies.

---

## Example 5 — Skill description: meta-narrative → triggering description

**Before:**

> ```yaml
> name: data-cleanup-helper
> description: This skill equips Claude with deep expertise in data cleaning, transformation, and preparation. It provides comprehensive guidance on processing messy datasets, fixing formatting issues, and preparing data for analysis or reporting.
> ```

**After:**

> ```yaml
> name: data-cleanup-helper
> description: Use when the user wants to clean, fix, or restructure messy data — CSV files with malformed rows, spreadsheets with inconsistent formatting, datasets with mixed types in columns, or any tabular data that needs preprocessing before analysis. Triggers on phrases like "fix this csv", "clean up this data", "this spreadsheet is a mess", "the columns don't line up", or any request involving deduplication, type coercion, header normalization, or fixing files that are "almost" the right shape. Also use when the user describes a problem with their data without naming cleaning explicitly — e.g., "my pivot table is broken" usually means the underlying data needs cleanup. Does not cover authoring new datasets from scratch or running statistical analysis; for those, defer to other skills.
> ```

**What changed:**

The "before" description is meta-narrative about the skill ("equips Claude with deep expertise…"). The triggering decision happens against specific user queries, not against a sales pitch — so the description needs to match the *queries* that should invoke it.

The rewrite includes (a) concrete description of what the skill does, (b) specific phrasings users actually type, (c) a non-obvious triggering case ("my pivot table is broken"), and (d) explicit non-coverage to prevent over-triggering on adjacent tasks. The result is a description that gives Claude the information it needs to decide *for a specific query* whether to consult the skill.

Note the deliberate phrase "also use when the user describes a problem with their data without naming cleaning explicitly" — this addresses the common under-triggering case where the skill applies but the user's phrasing doesn't include the obvious keyword.

---

## Example 6 — System prompt for a code review agent

**Before:**

> You are an expert code reviewer. Review the code provided and give feedback.

**After:**

> You're reviewing code that's about to be committed. Your job is to catch problems the author would want to know about before merging, not to enumerate every possible improvement.
>
> What to flag:
>
> - **Correctness:** bugs, edge cases not handled, race conditions, off-by-one errors, incorrect API usage.
> - **Security and data integrity:** anything that could leak data, accept unvalidated input, or corrupt state.
> - **Significant readability issues** that will cost future readers real time — not stylistic preferences.
>
> What to skip:
>
> - Style nits the linter would catch.
> - Refactoring suggestions that would change scope.
> - Restating things the code is doing well — assume the author knows what works.
>
> For each issue, state the problem in one sentence, point to the specific line(s), and suggest the fix concretely. If you find nothing meaningful, say "looks good" — don't manufacture concerns to seem thorough.

**What changed:**

The original gives the model no useful guidance — "expert code reviewer" is persona theater. The rewrite scopes the reviewer's job (catch problems worth surfacing pre-merge), defines what's in and out of scope, specifies the output format per issue, and explicitly authorizes the model to say "looks good" — which prevents the very common failure where review agents invent issues to justify their existence.

The "assume the author knows what works" line is doing a lot of work: it eliminates a category of output the model would otherwise default to producing.

---

## Example 7 — Few-shot done wrong → few-shot done right

**Before:**

> Classify the sentiment of these reviews as positive, negative, or neutral.
>
> Example 1: "This product is amazing!" → positive
> Example 2: "I love it!" → positive
> Example 3: "Best purchase ever!" → positive
>
> Now classify: "It arrived on time but the color was different from the photo."

**After:**

> Classify the sentiment of these reviews as positive, negative, or neutral.
>
> Examples:
>
> - "This product is amazing!" → positive
> - "Doesn't fit and the material is cheap." → negative
> - "It works." → neutral
> - "Arrived fast but I'm not sure the color matches the photo." → neutral *(mixed signals — fulfillment positive, product reservation; default to neutral when the review has both)*
> - "Honestly disappointed given the price." → negative *(price disappointment counts as negative even when the product itself isn't directly criticized)*
>
> Now classify: "It arrived on time but the color was different from the photo."

**What changed:**

The original example set has three positive examples, all easy, and no examples of the hard case. The model will be uncalibrated on negative or mixed reviews because it hasn't seen any.

The rewrite covers the range — clear positive, clear negative, terse neutral, mixed-signal neutral, and a tricky case (price-disappointment as negative). Two of the examples include a parenthetical explanation of *why* the label is what it is, which teaches the model the decision rule for the tricky cases without requiring a separate rules section.

The original prompt would likely classify the target review as positive (it pattern-matches "arrived on time"). The revised prompt has a near-identical mixed-signal example labeled neutral, which is the correct outcome.

---

## A meta-note

Notice that none of these "after" prompts are dramatically longer than their "before" versions. Two of them are *shorter*. The improvement comes from replacing platitudes and persona with specifics, not from adding more rules. Lean prompts that explain reasoning consistently outperform long prompts that pile on constraints.
