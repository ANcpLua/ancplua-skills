# MRTR — NOT shipped in 1.4.x

**Multi Round-Trip Requests (SEP-2322) do not exist in any shipped 1.4.x package.** This was verified against the actual v1.4.1 release tree (commit `2b7fd35`, `VersionPrefix 1.4.1`) and the shipped `ModelContextProtocol.Core` 1.4.1 assembly: zero occurrences of `InputRequiredException`, `InputRequest`, `InputRequiredResult`, `InputResponses`, `RequestState`, `IsMrtrSupported`, or the `DRAFT-2026-v1` protocol string.

An earlier revision of this skill documented MRTR as a 1.4.0 feature. That was wrong — the claims were grounded against a main-branch checkout that had been cached under the release commit's SHA (see the provenance note in `SKILL.md`). MRTR is main-branch work targeting **2.0.0-preview**, together with:

- the `2026-07-28` protocol revision (SEP-2575 + SEP-2567: removes the `initialize` handshake and `Mcp-Session-Id`; Streamable HTTP becomes sessionless)
- required `Mcp-Method` / `Mcp-Name` standard request headers and `[McpHeader]`
- obsoletion of stateful Streamable HTTP resumability (`EventStreamStore` et al., diagnostic `MCP9006`)
- the MCP Apps extension (`io.modelcontextprotocol/ui`, diagnostic `MCPEXP003`)

None of the above may be recommended for 1.4.x code.

## What to answer when someone asks for MRTR-style behavior on 1.4.1

A tool that needs client input mid-execution (elicitation, sampling, roots) on 1.4.1 has exactly these options:

| Need | 1.4.1 mechanism | Constraint |
| --- | --- | --- |
| Structured user input | `ElicitAsync` (Form mode) | Stateful HTTP or stdio only |
| Out-of-band browser/OAuth flow | `UrlElicitationRequiredException` | Works in stateless too |
| Client-side LLM call | `SampleAsync` / `AsSamplingChatClient()` | Stateful HTTP or stdio only |
| Filesystem roots | `RequestRootsAsync` | Stateful HTTP or stdio only |
| Long-running work with polling | Tasks (`IMcpTaskStore`, `ToolTaskSupport`) | Works in stateless |

There is **no stateless-compatible path for form elicitation, sampling, or roots in 1.4.x.** If a design requires those in stateless HTTP, the honest answers are: use stateful sessions, restructure the tool (e.g. accept the input as a tool parameter up front), use `UrlElicitationRequiredException` for browser-resolvable flows, or wait for the MRTR-bearing release.

## Version-drift tripwire

Before answering any MRTR question, check the user's actual package version. If they are on a `2.0.0-preview.*` package, this reference file does not apply — re-ground against that version's source (and verify the checkout's `src/Directory.Build.props` `VersionPrefix` matches the package version before trusting it).
