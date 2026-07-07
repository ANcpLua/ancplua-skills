# Principles

Read this when you need a fuller treatment of the principles in `SKILL.md` — when the inline summary isn't enough to explain a recommendation, or when the user is wrestling with a specific principle and wants depth.

## Show, don't tell — the longer version

The reason examples beat descriptions: descriptions of "good output" route through the model's prior of what those descriptive words mean, which can be miscalibrated for the specific task. An example collapses that ambiguity.

Concrete:

> Instructions only: *"Write a clear, professional commit message that explains both what changed and why."*
>
> Model behavior: produces commit messages that match "professional" but vary widely in style — some include scope prefixes, some don't, some explain the why in body text, some smuggle it into the subject line.

Add one example:

> *"Like this: `fix(auth): reject tokens issued before key rotation — previous policy only checked expiry, allowing a window where rotated-out tokens were still accepted.`"*

Now the model has a target. It will replicate the convention (scope prefix, subject under 72 chars, body explains the why) without you having to specify each rule.

When you can only afford one example, pick one that disambiguates the *most* axes at once. When you can afford multiple, cover the range — e.g., one for a feature, one for a fix, one for a refactor — so the model doesn't overfit to the format of a single category.

**Failure mode:** the model copies surface details from the example instead of the structure. Mitigation: explicitly call out what is illustrative vs. what is canonical — *"the format of the subject line is canonical; the wording and scope are illustrative."*

## Explain the why — and what counts as "why"

There's a spectrum from rule-only to reasoning-only:

- *"Don't use emojis."* — rule only. Model follows it in the obvious case, breaks on adjacent cases (sometimes uses ASCII art or unicode symbols).
- *"Don't use emojis — the output is read by screen readers and emojis create noise for low-vision users."* — rule plus reasoning. Model now knows to avoid decorative symbols generally, not just emoji.
- *"Output will be read by screen readers; avoid decorative formatting that doesn't carry meaning."* — reasoning that subsumes the rule. Model handles the original case plus extensions you didn't think of.

The third form is usually best but requires that the reasoning actually generalizes. If the constraint is arbitrary ("our brand guidelines say no emojis"), say so — *"our brand guidelines forbid emojis"* — and accept that the model won't generalize beyond the literal rule. That's fine. Arbitrary constraints are real; just don't dress them as principled reasoning.

## Theory of mind: re-read as the model

After writing a prompt, re-read it as if you're seeing it for the first time with no context outside the prompt itself. Things that look obvious to you because you wrote it often aren't.

Common failures this catches:

- A term used as if it has a specific meaning in your domain but never defined.
- An instruction that depends on context the model doesn't have (e.g., "follow the style of our other docs" — which docs?).
- A success criterion that's tautological from inside the prompt ("be helpful") but the prompt doesn't say what "helpful" looks like for *this* task.
- Two sections that locally make sense but contradict each other when you read them in sequence.

This is the cheapest review you can do and catches a remarkable fraction of real prompt failures.

## Lean prompts

Each instruction added to a prompt has a cost: it competes for the model's attention with everything else, it can collide with other instructions, and the model will sometimes follow it too literally in cases where it shouldn't apply.

Heuristics for pruning:

- **Strike anything that re-states a model default.** Modern Claude is polite, hedges on uncertainty, asks clarifying questions when input is genuinely ambiguous, refuses obviously unsafe requests. Instructions for these are mostly wasted budget.
- **Strike anything you added "just in case."** If you don't have an actual failure case the instruction prevents, you don't know whether it helps or hurts. Add it back the first time you see the failure it was supposed to prevent.
- **Consolidate instructions that mean the same thing.** If you have five sentences about "be concise," they're not five times as effective as one — they probably make the model overcorrect into terse output that drops important detail.
- **If two instructions might conflict, decide which wins and say so.** Don't leave the model to arbitrate between competing rules of equal apparent weight.

## XML tags as structure

Claude is trained to recognize XML tags as structural separators. They work well when:

- You have multiple parts the model should treat differently: `<context>`, `<task>`, `<examples>`, `<document>`, `<previous_attempt>`.
- You want the model's output structured: ask for it inside specific tags so it's parseable.
- You have a long document and want to mark which part is the document vs. the instructions about it.

They work poorly when:

- You're using them as a fake declarative language (`<if>`, `<when>`, `<rule severity="high">`). The model does not actually parse these — it treats them as text. The structure suggests semantics the model can't honor.
- You're wrapping single sentences in tags for emphasis. Use prose; the tag doesn't add anything.
- You stack so many tags that the structure overwhelms the content. Three to five top-level tags is usually plenty.

A reliable pattern: wrap each major input in a tag (`<document>`, `<schema>`, `<examples>`), put the task as plain prose, and optionally ask for output inside an explicit tag (`<answer>`, `<analysis>`).

## Long-context placement

When a prompt is long (say, more than a couple thousand tokens of context), placement of instructions matters:

- **Critical instructions belong near the top and near the end.** The model attends most reliably to both ends of the context. Putting key constraints only in the middle of a long prompt is asking for them to be ignored.
- **Examples can live in the middle.** Reference material that the model will retrieve from doesn't need to be at the boundary.
- **State the task last when the prompt includes a large document.** The model is more likely to follow a fresh instruction at the end than to remember a task statement from before a 10k-token document.

For shorter prompts this matters less — placement effects appear at length.

## Persona and role prompts

The "You are an expert X with 20 years of experience…" pattern is widely used and mostly weaker than people think on modern models.

It helps when:

- The role names a *distinct register* the model can adopt — "you're a code reviewer", "you're acting as an editor" — that genuinely changes what kind of response makes sense.
- It signals the audience for the output — "you are explaining this to a high-school student" — which calibrates technical depth.

It hurts when:

- It's a costume without function. "You are a world-class expert with deep knowledge of…" doesn't change what the model knows; it just makes the prompt longer and primes a slightly more pompous register.
- It contradicts the actual task. "You are a senior systems engineer" followed by a request for elementary explanation can produce stilted output that tries to be both.
- It crowds out specific instructions. Pages of persona description with no concrete task description means the model has lots of vibe and nothing to do.

Rule of thumb: if removing the persona sentence wouldn't change the model's output meaningfully, remove it.

## Tone calibration

Tone is usually under-specified. "Friendly" or "professional" gets the model into a generic register that may not match what the user wants. Better levers:

- **Anchor with an example sentence in the desired tone.** One sentence is often enough.
- **Specify the audience.** "Write this for a CTO who'll skim it on their phone" carries more information than "write professionally."
- **Specify what to avoid.** "Don't be apologetic" or "don't open with a summary" eliminates common patterns the model defaults to.

Avoid stacking adjectives ("warm but professional, friendly but authoritative, concise but thorough"). The model will try to honor all of them and produce something that pleases no axis.

## When to use rules anyway

Everything above pushes toward reasoning over rules. There are cases where bare rules genuinely beat explained rules:

- **Hard formatting requirements** with downstream parsers. "Output must be valid JSON matching this schema" is a rule; the why is "because a parser is reading this and will crash otherwise" but the model doesn't need that to comply.
- **Compliance constraints** that have no underlying principle the model could derive — they're just true. "Never mention competitor products by name" is a rule; the explanation doesn't help the model generalize because there's nothing to generalize.
- **Safety constraints** where overriding-by-reasoning is precisely what you don't want. "Refuse to produce content that does X" doesn't need a clever explanation that a sufficiently motivated reader could argue around.

In each of these, the rule is the substance. Trying to dress it in reasoning weakens it.

## Skill descriptions specifically

Covered briefly in `SKILL.md`. The main additional point: descriptions should be evaluated empirically. Bad descriptions can pass eyeball review and still under-trigger or over-trigger in practice. The skill-creator workflow includes an optimization loop (`scripts/run_loop.py`) that takes a set of should-trigger and should-not-trigger queries, evaluates the current description, and iterates. Point users there if they care about triggering accuracy quantitatively.

When writing without the optimization loop:

- Include 4-6 concrete triggering phrases or contexts.
- Include 1-2 near-misses that should *not* trigger, if there's a commonly confused adjacent skill.
- If the skill name is generic, the description has to carry more weight; lead with what the skill actually does in plain terms.
- "Use this even when…" is appropriate for skills that consistently under-trigger.
