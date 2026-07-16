---
name: maf-dotnet-source-of-truth
description: >-
  Write Microsoft Agent Framework (.NET) code against the cloned, SHA-pinned source — never from memory or
  from Microsoft Learn, which lag the source by weeks and keep pre-GA signatures alive long after they were
  renamed. USE FOR: writing or reviewing any code that touches Microsoft.Agents.AI / Microsoft.Agents.AI.Abstractions
  (AIAgent, ChatClientAgent, AgentSession, AgentResponse, RunAsync/RunStreamingAsync) or Microsoft.Extensions.AI
  (IChatClient, ChatMessage, ChatRole, ChatOptions, AITool); a compile error or "method not found" on a MAF type;
  porting a doc/blog sample that uses AgentThread / AgentRunResponse / CompleteAsync / GetNewThread; deciding
  whether to wrap an IChatClient in an agent vs hand-rolling the tool loop. ESPECIALLY use it the moment you are
  about to emit a MAF type or method name from memory — that is exactly when the stale-rename traps bite.
  DO NOT USE FOR: Microsoft.Extensions.AI internals unrelated to agents; non-.NET MAF (Python); conceptual "why"
  questions where Learn is fine (use microsoft-learn-grounding for docs).
license: Apache-2.0
---

# MAF .NET Source-of-Truth — grep the pinned tree, never the docs

**Provenance: every API claim below was grep-verified on 2026-07-16 against tag `dotnet-1.13.0` (`ee65f5329`) in the local clone at `~/RiderProjects/qyl-references/agent-framework-dotnet` (sparse, `dotnet/` only, blob-less).** Not from Microsoft Learn, not from memory. The renames are real: `AgentThread` has **0** references in `dotnet/src/*.cs` at the tag; `AgentSession` has **371**. Treat anything you remember about `AgentThread` / `AgentRunResponse` as outdated.

Breaking-change scan `dotnet-1.10.0..dotnet-1.13.0`: 7 .NET `[BREAKING]` commits, **all in hosting / skills / file-access surfaces** (OpenAI Hosting OptionsMapping #6855, FileAccess/FileMemory store API #6807 #6474, Azure.AI.AgentServer 2.0 + Foundry.Hosting #6800, AgentSkillsProvider approval defaults #6729 #6521, AgentMcpSkillsSource archive skills #6631). The core agent API (`AIAgent`, `ChatClientAgent`, `AgentSession`, `AgentResponse`, run/session/serialize methods) is unchanged since 1.10.0 — every signature below re-verified at 1.13.0. If you touch MAF hosting, file tools, or skills providers, read those PRs first.

> 🚨 **Microsoft Learn and devblogs lag the source by weeks-to-months and silently keep pre-GA and GA-era (`1.0`, April 2026) signatures alive long after they were renamed. The cloned, SHA-pinned source is the only authority for any type name, method name, or signature.** Docs are allowed only for conceptual "why" and migration narrative.

Local source root (set this): `MAF_SRC=~/RiderProjects/qyl-references/agent-framework-dotnet/dotnet`. (The previous `qyl-workspace/agent-framework-dotnet-rootsource` checkout was deleted.) This is a full `microsoft/agent-framework` clone, so source is `$MAF_SRC/src/**` and tests `$MAF_SRC/tests/**` under the `dotnet/` subtree. ⚠️ The clone's working tree is `main`, which drifts ahead of releases — for signature claims, grep **at the tag**: `git -C "$MAF_SRC/.." grep '<symbol>' dotnet-1.13.0 -- 'dotnet/src/*.cs'` (blob-less clone fetches blobs on demand).

## When to Use

Use this skill whenever you are about to write, review, or port MAF .NET code — and **before** you type any `Microsoft.Agents.AI.*` type or method:

- You are wiring an agent, a session, tools, or streaming over an `IChatClient`.
- You hit a compile error or "does not contain a definition for…" on a MAF type.
- You are porting a sample from Learn / a blog / an older repo (highest rename risk).
- You are unsure whether to wrap the client in an agent or talk to `IChatClient` directly.

## Operating rules

1. **Never emit a MAF type or method from memory.** Before writing any MAF call, `grep` it in `$MAF_SRC/src/**` and copy the real signature.
2. **Tests are executable spec.** When unsure of intended usage, read `$MAF_SRC/tests/**` (the `*.UnitTests` projects) — they pin real signatures, fixtures, and call shapes the prose simplifies away. Prefer a pattern you can see exercised in a test.
3. **`[BREAKING]` tripwire.** Each package has a `CHANGELOG.md`; renames are tagged `[BREAKING]` with a PR number. If a symbol you "remember" isn't in `src/`, search the changelogs for its rename before substituting anything.
4. **Namespaces:** `ChatMessage`, `ChatRole`, `ChatOptions`, `IChatClient`, `AITool` come from `Microsoft.Extensions.AI`. Agent types (`AIAgent`, `ChatClientAgent`, `AgentSession`, `AgentResponse`) come from `Microsoft.Agents.AI` / `Microsoft.Agents.AI.Abstractions`.
5. If docs and source disagree, **source wins and you say so explicitly** in the reply.

## Stale-doc rename traps (old → real, verified in this checkout)

| Stale name still in docs/blogs | Correct symbol | Evidence (in `src/`) |
|---|---|---|
| `AgentThread`, `agent.GetNewThread()` | `AgentSession`, `agent.CreateSessionAsync()` | `AgentThread`/`GetNewThread` = **0** refs at `dotnet-1.13.0`; `AgentSession` = 371, `CreateSessionAsync` = 41 |
| `AgentRunResponse` | `AgentResponse` | `AgentRunResponse` = **0**; `AgentResponse` = 265 |
| `AgentRunResponseUpdate` | `AgentResponseUpdate` | `AgentRunResponseUpdate` = **0**; `AgentResponseUpdate` = 210; streaming returns `IAsyncEnumerable<AgentResponseUpdate>` |
| `session.Serialize(...)` | `agent.SerializeSessionAsync(session, …)` | `SerializeSessionAsync` = 13 refs |
| `DeserializeSessionAsync(serializedSession:)` | param is **`serializedState`** | `DeserializeSessionAsync(JsonElement serializedState, JsonSerializerOptions?, ct)` — `AIAgent.cs:222` |
| `IChatClient.CompleteAsync` / `CompleteStreamingAsync` | `GetResponseAsync` / `GetStreamingResponseAsync` | call sites in `ChatClientAgent.cs` (the 13 `CompleteAsync` in `src/` are unrelated `Workflows` / `A2A` / `Declarative` methods) |

## The IChatClient-vs-RunAsync rule

Two failure modes hide here. Both are banned.

**Failure mode A — hand-rolling the model loop.** Old examples talk to `IChatClient` directly and reimplement the tool-call loop / history by hand. Since 1.10.0 (unchanged through 1.13.0) you wrap the client in an agent and let it own the loop, sessions, and middleware.

**Failure mode B — dead method/type names** (`CompleteAsync`, `AgentThread`, `AgentRunResponse`).

```csharp
// ❌ WRONG — pre-1.10.0 / doc-era. Will not compile, or is an anti-pattern.
using Microsoft.Extensions.AI;
ChatCompletion completion = await chatClient.CompleteAsync(messages);   // CompleteAsync is gone
AgentThread thread = agent.GetNewThread();                              // AgentThread renamed
AgentRunResponse resp = await agent.RunAsync("hi", thread);             // AgentRunResponse renamed
```

```csharp
// ✅ RIGHT — assembled from grep-verified signatures (2026-07-16, dotnet-1.13.0). It is a dated snapshot, not the authority:
//    the authority is the files cited below — open them. The real exercised example is the test/sample linked under the block.
using Microsoft.Agents.AI;        // AIAgent, ChatClientAgent, AgentSession, AgentResponse, AgentResponse<T>
using Microsoft.Extensions.AI;    // IChatClient, ChatMessage, ChatRole, ChatOptions, AITool

IChatClient chatClient = /* your provider's IChatClient */;

// Build the agent FROM the IChatClient (constructor; verified ctor shape below).
AIAgent agent = new ChatClientAgent(
    chatClient,
    instructions: "You are Neptun...",
    name: "Neptun",
    tools: myTools /* IList<AITool>? */);

// Run through the agent — it owns the tool loop + history.
AgentSession session = await agent.CreateSessionAsync();          // ValueTask<AgentSession>
AgentResponse response = await agent.RunAsync("Tell me about yourself.", session);

// Streaming:
await foreach (AgentResponseUpdate update in agent.RunStreamingAsync("…", session))
{
    // consume update
}

// Per-run model options:
var runOpts = new ChatClientAgentRunOptions(new ChatOptions { Temperature = 0.2f });
AgentResponse r2 = await agent.RunAsync("…", session, runOpts);
```

Verified signatures — **the file is the authority; open it, don't trust this index** (paths under `$MAF_SRC/`):
- `src/Microsoft.Agents.AI.Abstractions/AIAgent.cs` — `RunAsync` has 4 overloads, each `(<input>, AgentSession? session = null, AgentRunOptions? options = null, CancellationToken = default)` over `()` / `string message` / `ChatMessage message` / `IEnumerable<ChatMessage> messages`, returning `Task<AgentResponse>`; `RunStreamingAsync` mirrors them → `IAsyncEnumerable<AgentResponseUpdate>`; `CreateSessionAsync(ct)` → `ValueTask<AgentSession>`; `DeserializeSessionAsync(JsonElement serializedState, JsonSerializerOptions?, ct)`.
- `src/Microsoft.Agents.AI/ChatClient/ChatClientAgent.cs` — `ChatClientAgent(IChatClient, string? instructions=null, string? name=null, string? description=null, IList<AITool>? tools=null, ILoggerFactory?, IServiceProvider?)` + `(IChatClient, ChatClientAgentOptions?, …)`.
- `src/Microsoft.Agents.AI/ChatClient/ChatClientAgentRunOptions.cs` — `ChatClientAgentRunOptions(ChatOptions? chatOptions = null) : AgentRunOptions` (sealed).
- `src/Microsoft.Agents.AI.Abstractions/AgentResponse{T}.cs` — `AgentResponse<T> : AgentResponse` (typed/structured output; prefer it over parsing text).

**Don't trust the snippet — read a real exercised example** (executable spec; this skill is just a dated index into it):
- `tests/Microsoft.Agents.AI.Abstractions.UnitTests/DelegatingAIAgentTests.cs` — `CreateSessionAsync()` + `RunAsync(...)` in use.
- `samples/02-agents/Agents/Agent_Step06_DependencyInjection/Program.cs` — a canonical `new ChatClientAgent(...)` wiring.

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---|---|---|
| Emitting `AgentThread` / `AgentRunResponse` from memory | `CS0246` "type or namespace not found" | grep first — they're `AgentSession` / `AgentResponse` |
| Calling `IChatClient.CompleteAsync` | "no definition for CompleteAsync" | `GetResponseAsync` / `GetStreamingResponseAsync` |
| Hand-rolling the tool-call loop on `IChatClient` | Works but reimplements history/middleware the agent owns | wrap in `ChatClientAgent`, drive via `RunAsync` |
| Trusting a Learn/blog signature | Compiles in the article, not in your build | source wins — grep `$MAF_SRC/src/**`, say so in the reply |
| Guessing the deserialize param name | `serializedSession:` named-arg fails | it is `serializedState` |

## Pre-emit self-check (run before returning any MAF .NET code)

- [ ] Every MAF type/method was `grep`-confirmed in `$MAF_SRC/src` at the checked-out SHA.
- [ ] No `AgentThread`, `AgentRunResponse`, `AgentRunResponseUpdate`, `CompleteAsync`, `GetNewThread`.
- [ ] Model access goes through an `AIAgent` (`RunAsync`/`RunStreamingAsync`), not a hand-built `IChatClient` loop — unless the task is explicitly low-level.
- [ ] Sessions via `CreateSessionAsync` / `SerializeSessionAsync` / `DeserializeSessionAsync`.
- [ ] If I cited a doc, it was for concept/migration only — not for a signature.

## Is this pin stale? (zero-infra self-check — run when the skill fires)

No webhook is possible on a repo you don't own. Instead, check at point of use — one API call, no workflow, no cron:

```bash
# Latest upstream dotnet release vs this file's pin (dotnet-1.13.0).
gh api repos/microsoft/agent-framework/releases \
  --jq '[.[] | select(.tag_name|startswith("dotnet-"))][0].tag_name'
# If that prints a tag newer than dotnet-1.13.0 → this file is stale; run the refresh ritual below.
# (NuGet package versions track the tag: Microsoft.Agents.AI 1.13.0 = dotnet-1.13.0.)
```

> 💡 Hands-off path (wired): Renovate watches this repo and the `dotnet-*` releases of `microsoft/agent-framework` (see `renovate.json` → `customManagers`). When a newer one ships it opens a PR bumping the machine anchor below. **Treat that PR as a prompt to re-verify, never a blind merge** — re-grep the rename table at the new tag; Renovate only changed the anchor, not the verified prose.

<!-- renovate-pin: microsoft/agent-framework dotnet-1.13.0 -->
<!-- ^ Renovate bumps the version in the line above when a newer dotnet-* release ships; the prose/table stay until a human re-greps. -->


## Refresh ritual (when you bump the pinned version)

```bash
MAF_REPO=~/RiderProjects/qyl-references/agent-framework-dotnet   # full clone; dotnet code under dotnet/
NEW_TAG=dotnet-X.Y.Z    # ← the tag you are refreshing to (this file's current pin: dotnet-1.13.0)

# 0. Fetch tags (the clone drifts) and record the tag SHA you verify against.
git -C "$MAF_REPO" fetch --tags origin && git -C "$MAF_REPO" rev-parse --short "$NEW_TAG"

# 1. Tripwire: any .NET breaking deltas since this file's pin?
git -C "$MAF_REPO" log --oneline dotnet-1.13.0.."$NEW_TAG" -- dotnet/ | grep -i breaking

# 2. Re-grep the symbols this file asserts AT THE TAG (never on main — it drifts ahead):
git -C "$MAF_REPO" grep -c 'AgentThread\|AgentRunResponse\|GetNewThread' "$NEW_TAG" -- 'dotnet/src/*.cs'   # expect: no output (0 hits)
git -C "$MAF_REPO" grep -c 'AgentSession' "$NEW_TAG" -- 'dotnet/src/*.cs' | head                            # expect: many
```

This file has a half-life: the Thread→Session and serialize-move renames landed *after* GA. 1.10.0 → 1.13.0 left the core agent API untouched (all breaking changes were hosting / skills / file-access), but assume churn continues. **The durable asset is the ritual, not the table** — re-grep, don't re-remember.

## Related skills

- `microsoft-learn-grounding` — for the conceptual "why" and migration narrative (docs only, never signatures).
- `microsoft-first-research` — routes you to Microsoft-Learn-grounded research before answering from memory on any Microsoft-stack task.
