---
name: maf-dotnet-source-of-truth
description: >-
  Write Microsoft Agent Framework (.NET) code against the SHA-pinned source — never from memory or
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

**Provenance: the API signatures and rename table below were verified on 2026-09-30 against release `dotnet-1.22.0`, SHA `0c9944cc9f577d51277ac7c55dbc388b60a577af`, using the upstream source archive.** Searches covered all `dotnet/src/**/*.cs` files. Counts are matching lines with whole-word symbols, including comments: `AgentThread` has **0**, `AgentSession` has **432**. Treat remembered `AgentThread` / `AgentRunResponse` names as outdated.

This refresh covers the core agent, run, session, serialization, constructor, and run-options signatures indexed below. It does not claim a complete migration audit of hosting, file tools, skills providers, or other integrations; inspect their source and tests at the same pin before using them.

> 🚨 **Microsoft Learn and devblogs lag the source by weeks-to-months and silently keep pre-GA and GA-era (`1.0`, April 2026) signatures alive long after they were renamed. The cloned, SHA-pinned source is the only authority for any type name, method name, or signature.** Docs are allowed only for conceptual "why" and migration narrative.

Local source root (set this): `MAF_SRC=<your pinned agent-framework source>/dotnet`. Source lives under `$MAF_SRC/src/**`, and tests under `$MAF_SRC/tests/**`. Use the archive for the recorded release SHA, or an already verified checkout of that SHA. A working tree on `main` drifts ahead of releases; use `rg` on the pinned files for signature claims. The refresh ritual below downloads a fresh source archive without reading Git history.

## When to Use

Use this skill whenever you are about to write, review, or port MAF .NET code — and **before** you type any `Microsoft.Agents.AI.*` type or method:

- You are wiring an agent, a session, tools, or streaming over an `IChatClient`.
- You hit a compile error or "does not contain a definition for…" on a MAF type.
- You are porting a sample from Learn / a blog / an older repo (highest rename risk).
- You are unsure whether to wrap the client in an agent or talk to `IChatClient` directly.

## Operating rules

1. **Never emit a MAF type or method from memory.** Before writing any MAF call, `grep` it in `$MAF_SRC/src/**` and copy the real signature.
2. **Tests are executable spec.** When unsure of intended usage, read `$MAF_SRC/tests/**` (the `*.UnitTests` projects) — they pin real signatures, fixtures, and call shapes the prose simplifies away. Prefer a pattern you can see exercised in a test.
3. **Missing-symbol tripwire.** If a symbol you remember is absent from the pinned `src/`, inspect the current declarations and their tests before substituting anything. Upstream release notes can provide migration context; they do not replace signature checks.
4. **Namespaces:** `ChatMessage`, `ChatRole`, `ChatOptions`, `IChatClient`, `AITool` come from `Microsoft.Extensions.AI`. Agent types (`AIAgent`, `ChatClientAgent`, `AgentSession`, `AgentResponse`) come from `Microsoft.Agents.AI` / `Microsoft.Agents.AI.Abstractions`.
5. If docs and source disagree, **source wins and you say so explicitly** in the reply.

## Stale-doc rename traps (old → real, verified in this checkout)

| Stale name still in docs/blogs | Correct symbol | Evidence (in `src/`) |
|---|---|---|
| `AgentThread`, `agent.GetNewThread()` | `AgentSession`, `agent.CreateSessionAsync()` | `AgentThread`/`GetNewThread` = **0** refs at `dotnet-1.22.0`; `AgentSession` = 432, `CreateSessionAsync` = 41 |
| `AgentRunResponse` | `AgentResponse` | `AgentRunResponse` = **0**; `AgentResponse` = 252 |
| `AgentRunResponseUpdate` | `AgentResponseUpdate` | `AgentRunResponseUpdate` = **0**; `AgentResponseUpdate` = 230; streaming returns `IAsyncEnumerable<AgentResponseUpdate>` |
| `session.Serialize(...)` | `agent.SerializeSessionAsync(session, …)` | `SerializeSessionAsync` = 15 matching lines |
| `DeserializeSessionAsync(serializedSession:)` | param is **`serializedState`** | `DeserializeSessionAsync(JsonElement serializedState, JsonSerializerOptions?, ct)` — `AIAgent.cs:222` |
| `IChatClient.CompleteAsync` / `CompleteStreamingAsync` | `GetResponseAsync` / `GetStreamingResponseAsync` | call sites in `ChatClientAgent.cs` (`CompleteAsync` elsewhere in `src/` is not the `IChatClient` response API) |

## The IChatClient-vs-RunAsync rule

Two failure modes hide here. Both are banned.

**Failure mode A — hand-rolling the model loop.** Old examples talk to `IChatClient` directly and reimplement the tool-call loop / history by hand. At the verified 1.22.0 pin, wrap the client in an agent and let it own the loop, sessions, and middleware.

**Failure mode B — dead method/type names** (`CompleteAsync`, `AgentThread`, `AgentRunResponse`).

```csharp
// ❌ WRONG — pre-1.10.0 / doc-era. Will not compile, or is an anti-pattern.
using Microsoft.Extensions.AI;
ChatCompletion completion = await chatClient.CompleteAsync(messages);   // CompleteAsync is gone
AgentThread thread = agent.GetNewThread();                              // AgentThread renamed
AgentRunResponse resp = await agent.RunAsync("hi", thread);             // AgentRunResponse renamed
```

```csharp
// ✅ RIGHT — assembled from grep-verified signatures (2026-09-30, dotnet-1.22.0). It is a dated snapshot, not the authority:
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
- `tests/Microsoft.Agents.AI.UnitTests/ChatClient/ChatClientAgentTests.cs` — exercised `ChatClientAgent` constructor shapes.
- `samples/02-agents/Agents/Agent_Step06_DependencyInjection/Program.cs` — Foundry `AsAIAgent(...)` wiring, `CreateSessionAsync()`, and streaming over a session.

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
# Latest upstream dotnet release vs this file's pin (dotnet-1.22.0).
gh api repos/microsoft/agent-framework/releases \
  --jq '[.[] | select(.draft == false and .prerelease == false) | select(.tag_name|startswith("dotnet-"))][0].tag_name'
# If that prints a tag newer than dotnet-1.22.0 → this file is stale; run the refresh ritual below.
# (NuGet package versions track the tag: Microsoft.Agents.AI 1.22.0 = dotnet-1.22.0.)
```

> 💡 Hands-off path (wired): Renovate watches this repo and the `dotnet-*` releases of `microsoft/agent-framework` (see `renovate.json` → `customManagers`). When a newer one ships it opens a PR bumping the machine anchor below. **Treat that PR as a prompt to re-verify, never a blind merge** — re-grep the rename table at the new tag; Renovate only changed the anchor, not the verified prose.

<!-- renovate-pin: microsoft/agent-framework dotnet-1.22.0 -->
<!-- ^ Renovate bumps the version in the line above when a newer dotnet-* release ships; the prose/table stay until a human re-greps. -->


## Refresh ritual (when you bump the pinned version)

```bash
set -euo pipefail
MAF_REPO="<new-empty-source-directory>"
NEW_TAG=dotnet-X.Y.Z    # current pin: dotnet-1.22.0

# Resolve the release tag to its source SHA, including annotated tags.
read -r OBJECT_TYPE PIN < <(gh api "repos/microsoft/agent-framework/git/ref/tags/$NEW_TAG" \
  --jq '.object | [.type, .sha] | @tsv')
while [ "$OBJECT_TYPE" = tag ]; do
  read -r OBJECT_TYPE PIN < <(gh api "repos/microsoft/agent-framework/git/tags/$PIN" \
    --jq '.object | [.type, .sha] | @tsv')
done
[ "$OBJECT_TYPE" = commit ]
printf 'Source pin: %s %s\n' "$NEW_TAG" "$PIN"

# Start with a fresh directory so files from another release cannot remain.
mkdir "$MAF_REPO"
curl -fsSL "https://codeload.github.com/microsoft/agent-framework/tar.gz/$PIN" \
  | tar -xz --strip-components=1 -C "$MAF_REPO"
MAF_SRC="$MAF_REPO/dotnet"

# Check the rename traps and current signatures in the extracted source.
if rg -n -w 'AgentThread|AgentRunResponse|AgentRunResponseUpdate|GetNewThread' "$MAF_SRC/src" -g '*.cs'; then
  echo 'Rename assumptions changed; investigate before updating the skill.'
  exit 1
else
  status=$?
  [ "$status" -eq 1 ] || exit "$status"
fi
rg -n -w 'AgentSession|CreateSessionAsync|SerializeSessionAsync|DeserializeSessionAsync' \
  "$MAF_SRC/src/Microsoft.Agents.AI.Abstractions/AIAgent.cs"
```

Then inspect every signature and cited test/sample in the index above, recompute the whole-word matching-line counts across `src/**/*.cs`, and update the provenance, table, examples, and machine anchor together. The durable asset is the ritual: verify the pinned source again on every refresh.

## Related skills

- `microsoft-learn-grounding` — for the conceptual "why" and migration narrative (docs only, never signatures).
- `microsoft-first-research` — routes you to Microsoft-Learn-grounded research before answering from memory on any Microsoft-stack task.
