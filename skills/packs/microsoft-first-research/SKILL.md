---
name: microsoft-first-research
description: >-
  Weave Microsoft-Learn-grounded research into ANY substantive help for this user, whose work is overwhelmingly
  Microsoft-centric (qyl on .NET / Foundry / Microsoft Agent Framework; the microsoft-ai-hackathon tracks Otto,
  Agent Battle Arena, Inventory Reorder Copilot). Reach for this at the START of essentially any research, design,
  debugging, "how do I", "is this current / latest", API-shape, SDK-error, or build task — proactively consult the
  Microsoft Learn MCP and the microsoft-docs skills and the local ground-truth checkouts BEFORE answering from
  memory, even when the user never types "Microsoft", "Azure", ".NET", or "docs". This is a routing / insurance
  skill that exists specifically so Microsoft grounding stops getting skipped ~half the time. Stand down only when
  the task is explicitly about a non-Microsoft stack (AWS, GCP, OpenAI, etc.) or is a trivial mechanical edit with
  no knowledge question. Pairs with the microsoft-learn-grounding skill.
license: Apache-2.0
---

# Microsoft-First Research

This skill encodes a prior, not a fact: **almost everything this user asks is Microsoft-shaped**, even when the
words "Microsoft / Azure / .NET" never appear. qyl is a .NET / Foundry / Agent Framework system; the hackathon is
three Foundry-based tracks. So when a request *could* benefit from documentation grounding, the default is to
ground it in Microsoft Learn **first**, before reasoning from memory. Its whole job is to close the gap where the
stock Microsoft skills under-trigger because the user didn't name the technology.

The cost of consulting is low; the cost of confidently-wrong memory about a fast-moving preview SDK is high. That
asymmetry is the entire justification — lean toward grounding.

## When to fire (early, and generously)

Fire at the top of the turn — before drafting an answer — for any of:

- "How does X work / how do I do Y / what's the right way to …" on anything agent-, cloud-, .NET-, or doc-shaped.
- "Is this the latest / is this current / did this change / what's the newest version of …" → freshness question.
- Anything touching an SDK, API signature, package, namespace, attribute, config, or an error/stack trace.
- Design or architecture for an agent, RAG, MCP, tool-calling, knowledge-base, or Foundry/M365 integration.
- Any request where you're about to say something like "I believe the API is…" or "as of my knowledge…".

If you catch yourself about to answer a substantive Microsoft-adjacent question straight from memory, that hesitation
is the trigger. Ground it.

## Use this skill when — and how to ground

Use this skill whenever you are about to answer a Microsoft-adjacent question from memory. Concretely:

- **Always** ground before stating a preview-SDK signature, version, or API shape — Learn for breadth first, then the local checkout for the exact call.
- **Never** emit a `Microsoft.Agents.AI.*`, Foundry, or Copilot Studio type from memory; grep the cloned source and copy the real signature.
- **Use** `microsoft_docs_search` for concepts, then verify the precise symbol against the checkout and the compiler.

```bash
# ground-then-verify: docs for breadth (cheap), source for the exact signature (authoritative)
#   1) microsoft_docs_search "<topic>"      (MCP; cap size with ?maxTokenBudget=…)
#   2) confirm the real symbol in the local checkout before you write the call:
grep -rl --include=*.cs 'ChatClientAgent' \
  ~/RiderProjects/qyl-workspace/agent-framework-dotnet-rootsource/src
```

## Where to route

| Signal | Route to |
|---|---|
| Concept, tutorial, "how/why", limits, recommended guidance | `microsoft-docs` skill + `microsoft_docs_search` → `microsoft_docs_fetch` |
| Code, API signature, SDK error, idiomatic sample | `microsoft-code-reference` skill + `microsoft_code_sample_search`, **then** local checkout below |
| "Is this current / last updated / which version" | `microsoft-learn-grounding` skill (freshness + the date mechanism the MCP hides) |
| Need a new reusable MS-tech skill | `microsoft-skill-creator` skill |
| Bleeding-edge `Microsoft.Agents.AI.*` / Foundry / Copilot Studio / Fabric API shape | **Local ground truth first** — see below |
| Genuinely non-Microsoft dependency | `context7` / `nuget-opensrc` / web search — and let this skill stand down |

## Ground truth beats preview docs

For preview Microsoft .NET packages, Learn is often a release behind and not API-exact. The deciding sources are,
in order: **(1)** the installed package + its NuGet `.xml` doc sidecar and `tests/`, **(2)** the
`~/RiderProjects/agent-framework` checkout, **(3)** compile/run output, **(4)** Learn for concepts and breadth.
When Learn and the checkout disagree on a preview API, trust the checkout and the compiler, and say which one you
used. Use Learn to understand *what* a thing is; use the checkout to know *exactly* how to call it.

## Token discipline

This grounding is cheap but not free. When doing many doc calls in a loop, prefer `microsoft_docs_search` (small
chunks) over fetching whole pages, and cap search size with `?maxTokenBudget=…` on the MCP endpoint. Fetch the full
page only when depth is actually needed. (Details in `microsoft-learn-grounding`.)

## Stand-down list (the over-trigger safety)

This skill is deliberately broad because the user asked for it to be. The guards that keep "broad" from becoming
"noisy":

- **Explicit non-Microsoft stack** named (AWS, GCP, OpenAI/Anthropic SDKs, Vercel, a pure Node/Python/Rust lib with
  no Microsoft surface) → don't force Microsoft framing; route to the right non-MS tool and step aside.
- **Trivial mechanical work** — rename a variable, format a file, a one-line edit, pure `git` plumbing — no
  knowledge question, so no grounding needed.
- **User opted out** — "just from memory", "quick answer", "don't look it up", or an explicit instruction in
  CLAUDE.md / the request → honor it. User instructions outrank this skill, always.
- **Already grounded this turn** — don't re-search the same fact you just fetched.

When unsure whether a task is the <10% non-Microsoft case, a single `microsoft_docs_search` is a cheap probe: if it
returns nothing relevant, you've confirmed it's off-surface — stand down and move on. Don't announce the prior or
narrate the routing; just ground and answer.
