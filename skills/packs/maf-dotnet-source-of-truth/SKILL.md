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

**Provenance: every API claim below was grep-verified on 2026-06-13 against the local checkout at `~/RiderProjects/qyl-workspace/agent-framework-dotnet-rootsource`, `main` @ `8105d231` (2026-06-12), which is at or after tag `dotnet-1.10.0`.** Not from Microsoft Learn, not from memory. The renames here are real: `AgentThread` has **0** references in `src/`; `AgentSession` has **85**. Treat anything you remember about `AgentThread` / `AgentRunResponse` as outdated.

> 🚨 **Microsoft Learn and devblogs lag the source by weeks-to-months and silently keep pre-GA and GA-era (`1.0`, April 2026) signatures alive long after they were renamed. The cloned, SHA-pinned source is the only authority for any type name, method name, or signature.** Docs are allowed only for conceptual "why" and migration narrative.

Local source root (set this): `MAF_SRC=~/RiderProjects/qyl-workspace/agent-framework-dotnet-rootsource`. This checkout is the dotnet subtree, so source is `$MAF_SRC/src/**` and tests are `$MAF_SRC/tests/**`. (A full `microsoft/agent-framework` clone nests these under `dotnet/`.)

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
| `AgentThread`, `agent.GetNewThread()` | `AgentSession`, `agent.CreateSessionAsync()` | `AgentThread`/`GetNewThread` = **0** refs; `AgentSession` = 85, `CreateSessionAsync` = 25 |
| `AgentRunResponse` | `AgentResponse` | `AgentRunResponse` = **0**; `AgentResponse` = 73 |
| `AgentRunResponseUpdate` | `AgentResponseUpdate` | `AgentRunResponseUpdate` = **0**; `AgentResponseUpdate` = 55; streaming returns `IAsyncEnumerable<AgentResponseUpdate>` |
| `session.Serialize(...)` | `agent.SerializeSessionAsync(session, …)` | `SerializeSessionAsync` = 11 refs |
| `DeserializeSessionAsync(serializedSession:)` | param is **`serializedState`** | `DeserializeSessionAsync(JsonElement serializedState, JsonSerializerOptions?, ct)` |
| `IChatClient.CompleteAsync` / `CompleteStreamingAsync` | `GetResponseAsync` / `GetStreamingResponseAsync` | call sites in `ChatClientAgent.cs` (the 7 `CompleteAsync` in `src/` are unrelated `Workflows` methods) |

## The IChatClient-vs-RunAsync rule

Two failure modes hide here. Both are banned.

**Failure mode A — hand-rolling the model loop.** Old examples talk to `IChatClient` directly and reimplement the tool-call loop / history by hand. In 1.10.0 you wrap the client in an agent and let it own the loop, sessions, and middleware.

**Failure mode B — dead method/type names** (`CompleteAsync`, `AgentThread`, `AgentRunResponse`).

```csharp
// ❌ WRONG — pre-1.10.0 / doc-era. Will not compile, or is an anti-pattern.
using Microsoft.Extensions.AI;
ChatCompletion completion = await chatClient.CompleteAsync(messages);   // CompleteAsync is gone
AgentThread thread = agent.GetNewThread();                              // AgentThread renamed
AgentRunResponse resp = await agent.RunAsync("hi", thread);             // AgentRunResponse renamed
```

```csharp
// ✅ RIGHT — verified against the pinned source.
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

Verified signatures in `src/`:
- `ChatClientAgent(IChatClient chatClient, string? instructions = null, string? name = null, string? description = null, IList<AITool>? tools = null, ILoggerFactory? = null, IServiceProvider? = null)` (plus a `(IChatClient, ChatClientAgentOptions?, …)` overload).
- `AIAgent.RunAsync(...)` → `Task<AgentResponse>` (4 overloads: `(AgentSession?, AgentRunOptions?, ct)`, `(string, …)`, `(ChatMessage, …)`, `(IEnumerable<ChatMessage>, …)`).
- `AIAgent.RunStreamingAsync(...)` → `IAsyncEnumerable<AgentResponseUpdate>` (mirrors the 4 overloads).
- `AIAgent.CreateSessionAsync(ct)` → `ValueTask<AgentSession>`.
- `ChatClientAgentRunOptions : AgentRunOptions` (sealed).

**Prefer the typed overload:** `AgentResponse<T> : AgentResponse` exists (`AgentResponse{T}.cs`) for structured/typed output — reach for it instead of parsing text when you need a schema'd result.

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

## Refresh ritual (when you bump the pinned version)

```bash
MAF_SRC=~/RiderProjects/qyl-workspace/agent-framework-dotnet-rootsource

# 1. Record the SHA you build against (this checkout currently: main @ 8105d231).
git -C "$MAF_SRC" rev-parse HEAD

# 2. Tripwire: any breaking deltas since the old pin?
git -C "$MAF_SRC" log --oneline dotnet-1.10.0..HEAD | grep -i breaking

# 3. Re-grep the symbols this file asserts; if any moved, update the table.
grep -rl --include=*.cs 'AgentThread\|AgentRunResponse\|GetNewThread' "$MAF_SRC/src"   # expect: empty
grep -rl --include=*.cs 'AgentSession\|AgentResponse\|CreateSessionAsync' "$MAF_SRC/src" | head  # expect: many
```

This file has a half-life: the Thread→Session and serialize-move renames landed *after* GA, so assume more churn above 1.10.0. **The durable asset is the ritual, not the table** — re-grep, don't re-remember.

## Related skills

- `microsoft-learn-grounding` — for the conceptual "why" and migration narrative (docs only, never signatures).
- `microsoft-first-research` — routes you to Microsoft-Learn-grounded research before answering from memory on any Microsoft-stack task.
