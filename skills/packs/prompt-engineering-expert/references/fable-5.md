# Prompting Claude Fable 5 / Mythos 5

Read this when the user's prompt targets Claude Fable 5 or Claude Mythos 5 (same underlying model; Mythos is the unrestricted-access tier), or when they're migrating prompts, skills, or agent scaffolding from Claude Opus 4.8 or earlier. The failure modes and fixes below are model-specific; the general principles in `principles.md` still apply on top.

Contents:

1. The headline shift: prune before you add
2. Symptom → fix patterns (copy-paste snippets)
3. Scaffolding patterns (harness-level, not prompt text)
4. Effort quick reference
5. Migration checklist

---

## 1. The headline shift: prune before you add

Fable 5's instruction following is strong enough that a **brief instruction usually replaces an enumerated list of behaviors**. This inverts the usual migration instinct. When a user brings a prompt or skill written for an older model:

- Look for instruction lists that enumerate variants of one behavior ("don't do X, don't do Y, don't do Z" where X/Y/Z are all forms of verbosity, say). Collapse to one sentence stating the principle.
- Look for compensating instructions — workarounds for weaknesses the old model had. Fable 5 often performs *worse* with them: overly prescriptive skills degrade output quality. Test with the instruction removed before assuming it's still needed.
- **Warning — reasoning echo**: any instruction telling the model to echo, transcribe, or "show your thinking" in the response text can trigger the `reasoning_extraction` refusal classifier and cause fallbacks. Audit for these when migrating. If the application needs reasoning visibility, read the structured `thinking` blocks from adaptive thinking instead.

Also relevant when diagnosing: Fable 5 runs safety classifiers on offensive cybersecurity, biology/life-sciences content, and thinking extraction. Benign work in those areas can still trigger a `stop_reason: "refusal"` — if a user reports mysterious refusals in those domains, it's likely the classifier, not their prompt.

---

## 2. Symptom → fix patterns

Each snippet below is field-tested phrasing. Adapt wording, keep the mechanism.

### Turns run long; model overplans on ambiguous tasks

Requests at higher effort can legitimately run many minutes (this is often correct behavior — check the effort setting first, see §4). If the model is re-deriving settled facts or surveying options it won't take:

```text
When you have enough information to act, act. Do not re-derive facts already established in the conversation, re-litigate a decision the user has already made, or narrate options you will not pursue in user-facing messages. If you are weighing a choice, give a recommendation, not an exhaustive survey. This does not apply to thinking blocks.
```

### Unrequested refactoring, gold-plating, defensive code at high effort

```text
Don't add features, refactor, or introduce abstractions beyond what the task requires. A bug fix doesn't need surrounding cleanup and a one-shot operation usually doesn't need a helper. Don't design for hypothetical future requirements: do the simplest thing that works well. Avoid premature abstraction and half-finished implementations. Don't add error handling, fallbacks, or validation for scenarios that cannot happen. Trust internal code and framework guarantees. Only validate at system boundaries (user input, external APIs). Don't use feature flags or backwards-compatibility shims when you can just change the code.
```

### Verbose output: option surveys, narrating comments, heavy PR descriptions

One brevity instruction replaces enumerating each pattern:

```text
Lead with the outcome. Your first sentence after finishing should answer "what happened" or "what did you find": the thing the user would ask for if they said "just give me the TLDR." Supporting detail and reasoning come after. Being readable and being concise are different things, and readability matters more.

The way to keep output short is to be selective about what you include (drop details that don't change what the reader would do next), not to compress the writing into fragments, abbreviations, arrow chains like A → B → fails, or jargon.
```

### Stops to check in too often (or not at the right moments)

State the principle, not the case list:

```text
Pause for the user only when the work genuinely requires them: a destructive or irreversible action, a real scope change, or input that only they can provide. If you hit one of these, ask and end the turn, rather than ending on a promise.
```

### Fabricated or optimistic progress reports on long runs

Grounding claims in tool results nearly eliminated fabricated status reports in Anthropic's testing, even on tasks designed to elicit them:

```text
Before reporting progress, audit each claim against a tool result from this session. Only report work you can point to evidence for; if something is not yet verified, say so explicitly. Report outcomes faithfully: if tests fail, say so with the output; if a step was skipped, say that; when something is done and verified, state it plainly without hedging.
```

### Takes unrequested actions (drafts an email nobody asked for, makes backup branches)

```text
When the user is describing a problem, asking a question, or thinking out loud rather than requesting a change, the deliverable is your assessment. Report your findings and stop. Don't apply a fix until they ask for one. Before running a command that changes system state (restarts, deletes, config edits), check that the evidence actually supports that specific action. A signal that pattern-matches to a known failure may have a different cause.
```

### Ends a turn with a statement of intent instead of acting (rare, deep in long sessions)

A "continue" unblocks it in interactive use. For autonomous pipelines, add:

```text
You are operating autonomously. The user is not watching in real time and cannot answer questions mid-task, so asking "Want me to…?" or "Shall I…?" will block the work. For reversible actions that follow from the original request, proceed without asking. Offering follow-ups after the task is done is fine; asking permission after already discussing with the user before doing the work is not. Before ending your turn, check your last paragraph. If it is a plan, an analysis, a question, a list of next steps, or a promise about work you have not done ("I'll…", "let me know when…"), do that work now with tool calls. End your turn only when the task is complete or you are blocked on input only the user can provide.
```

### Worries about context budget: offers to summarize, suggests a new session

Usually triggered by the harness showing a remaining-token countdown. First fix: stop surfacing the count. If it must be shown:

```text
You have ample context remaining. Do not stop, summarize, or suggest a new session on account of context limits. Continue the work.
```

### Final summaries unreadable after long agentic runs (arrow chains, invented jargon, references to unseen thinking)

```text
Terse shorthand is fine between tool calls (that's you thinking out loud, and brevity there is good). Your final summary is different: it's for a reader who didn't see any of that.

If you've been working for a while without the user watching (overnight, across many tool calls, since they last spoke), your final message is their first look at any of it. Write it as a re-grounding, not a continuation of your working thread: the outcome first, then the one or two things you need from them, each explained as if new. The vocabulary you built up while working is yours, not theirs; leave it behind unless you re-introduce it.

When you write the summary at the end, drop the working shorthand. Write complete sentences. Spell out terms. Don't use arrow chains, hyphen-stacked compounds, or labels you made up earlier. When you mention files, commits, flags, or other identifiers, give each one its own plain-language clause. Open with the outcome: one sentence on what happened or what you found. Then the supporting detail. If you have to choose between short and clear, choose clear.
```

---

## 3. Scaffolding patterns

These are harness/system-design recommendations, not prompt snippets — relevant when the user is building an agent around Fable 5 rather than just writing a prompt.

**Adjust for longer turns.** Individual requests at high effort can run many minutes; autonomous runs, hours. Before migrating: raise client timeouts, add streaming and progress indicators, and consider checking on runs asynchronously (scheduled jobs) rather than blocking.

**Give the reason, not only the request.** Fable 5 connects tasks to relevant context better when it knows the intent. Template:

```text
I'm working on [the larger task] for [who it's for]. They need [what the output enables]. With that in mind: [request].
```

**Use parallel subagents liberally.** Fable 5 dispatches and manages parallel subagents dependably. Give explicit guidance on when to delegate; prefer asynchronous orchestrator↔subagent communication over blocking; prefer long-lived subagents that keep context across subtasks (cache savings, no bottleneck on the slowest one).

```text
Delegate independent subtasks to subagents and keep working while they run. Intervene if a subagent goes off track or is missing relevant context.
```

**Provide a memory file.** Fable 5 performs notably better when it can record lessons across runs — a plain Markdown file suffices:

```text
Store one lesson per file with a one-line summary at the top. Record corrections and confirmed approaches alike, including why they mattered. Don't save what the repo or chat history already records; update an existing note rather than creating a duplicate; delete notes that turn out to be wrong.
```

Bootstrap it by having the model reflect on past sessions and store the core lessons.

**Create a send-to-user tool for async agents.** Tool inputs are never summarized, so a client-side `send_to_user(message)` tool delivers verbatim content (partial deliverables, exact numbers, direct answers) mid-turn. Two gotchas: the model rarely calls it without an explicit elicitation instruction in the system prompt, and it should *not* be used for narration:

```text
Between tool calls, when you have content the user must read verbatim (a partial deliverable, a direct answer to their question), call the send_to_user tool with that content. Use send_to_user only for user-facing content, not for narration or reasoning.
```

**Make self-verification explicit on long runs.** Fresh-context verifier subagents outperform self-critique: `Establish a method for checking your own work at an interval of [X] as you build. Run this every [X interval], verifying your work with subagents against the specification.`

---

## 4. Effort quick reference

Effort is the primary intelligence/latency/cost dial and often the *real* fix for "it takes too long" or "it overthinks" complaints — check it before adding prompt text.

- `high` — default for most tasks.
- `xhigh` — most capability-sensitive work; best verification and rigor, but can over-deliberate on routine tasks.
- `medium` / `low` — routine work and interactive back-and-forth; still strong, often above prior models' `xhigh`.

Adaptive thinking only; no extended-thinking budgets; thinking output is summarized-only.

---

## 5. Migration checklist (from Opus 4.8 or earlier)

1. Remove enumerated behavior lists → single principle statements (§1).
2. Remove compensating instructions for old-model weaknesses; A/B against the bare prompt.
3. Grep for "show your reasoning / explain your thinking in the response" → replace with adaptive-thinking blocks or send-to-user (refusal risk).
4. Raise timeouts, add async progress handling for long turns.
5. Pick effort deliberately instead of defaulting.
6. If the workload is easy, that undersells the model — test at the top of the difficulty range too.
7. Configure fallback to Opus 4.8 for `stop_reason: "refusal"` if the workload can brush the cyber/bio classifiers.
