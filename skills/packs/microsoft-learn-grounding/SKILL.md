---
name: microsoft-learn-grounding
description: >-
  Operate the Microsoft Learn MCP — the free, no-auth dogfood API behind Ask Learn and Copilot for Azure — at
  expert level, and verify how fresh any Microsoft Learn page actually is. Use whenever grounding an answer in
  Microsoft / Azure / .NET / M365 / Foundry / Agent Framework / Copilot Studio docs, deciding whether a Learn page
  is current, looking up a page's "Last updated" date / ms.date / source commit, capping token spend on doc
  searches, or debugging why the Learn MCP returned nothing useful — even when the user never says "Microsoft
  Learn" or "MCP". Covers the three tools (microsoft_docs_search, microsoft_docs_fetch, microsoft_code_sample_search),
  the maxTokenBudget control, dynamic tool discovery, the daily-refresh freshness model, and the key gotcha that the
  MCP strips last-updated metadata so you must read it from the rendered page instead.
license: Apache-2.0
---

# Microsoft Learn Grounding

The Microsoft Learn MCP Server is the highest-quality free documentation-grounding API that exists, and you almost
certainly want it for this user's work. This skill makes you operate it like Microsoft does — and, just as
importantly, tells you the things it *won't* do so you don't trust it blindly.

Provenance: every fact here was verified against `learn.microsoft.com` in **June 2026**. Treat anything you
remember from before 2026 as suspect — this surface changed a lot.

## Why this is worth using: it's dogfood

The MCP is a thin protocol wrapper over the **Learn knowledge service** — the *same* production RAG backend that
powers **Ask Learn** and **Copilot for Azure**. When you call it you are hitting Microsoft's own first-party
retrieval stack, not a scrape. That is why the grounding quality is high and why preferring it over guessing from
memory is almost always correct.

- Endpoint: `https://learn.microsoft.com/api/mcp` (Streamable HTTP; **405** if you GET it in a browser — it is for MCP clients only).
- OpenAI-compatible variant: `https://learn.microsoft.com/api/mcp/openai-compatible`.
- No auth, no API key, no cost. Public docs only — no training records, no tenant/profile data.
- In this environment the tools are already wired as `microsoft_docs_search`, `microsoft_docs_fetch`,
  `microsoft_code_sample_search` (the `microsoft-docs` plugin). Load them via ToolSearch if deferred.

## The three tools — pick by intent

| Need | Tool | Notes |
|---|---|---|
| Breadth — overview, "does X exist", which page to read | `microsoft_docs_search` | Returns ≤10 chunks, ≤500 tokens each (title + URL + excerpt). Start here. |
| Depth — full tutorial, prerequisites, troubleshooting, the whole page | `microsoft_docs_fetch` | Returns the full page as clean markdown. Use *after* search on a chosen URL. |
| Working code — API signatures, snippets, idiomatic samples | `microsoft_code_sample_search` | Pass `language` (csharp, typescript, python, …) to sharpen results. |

Search gives breadth, code-sample search gives practical examples, fetch gives depth. Chain them in that order.

## Token discipline (this user's budget is a real constraint)

Append `maxTokenBudget` to cap **search** response size:

```
https://learn.microsoft.com/api/mcp?maxTokenBudget=2000
```

It truncates search content to fit your budget; it does **not** affect `fetch` (fetch always returns the full
page). Set it low when the agent does many calls per turn, higher for one rich response. If you control the MCP
config for a qyl/hackathon project, this is the lever to keep doc grounding from eating context.

## Dynamic discovery — never hardcode

Microsoft treats the tool list as *dynamic*, not a fixed API contract. On connect, the client calls `tools/list`
to get current tools + descriptions and lets the model route. If a call fails with **400 or 404**, assume your
cached tool/parameter shape is stale: refresh via `tools/list` and retry. Do not hardcode tool names, parameter
schemas, or response formats in any custom integration — Microsoft explicitly says the interface may change.

## Freshness model — how current is the answer?

The knowledge service **refreshes incrementally after content updates and does a full refresh once a day.** So the
MCP's search index is at most ~1 day behind the live docs. Good enough for almost everything; if you need
truly-today content, fall back to fetching the rendered page (below).

## Getting a page's "Last updated" date — the actual answer

There is **no dedicated REST/JSON "last-updated" endpoint**, and the **MCP cannot give you the date**:
`microsoft_docs_fetch` returns body-only markdown and **strips the metadata block** (verified: its output begins
at the page's first `#` heading with no dates). The date lives only in the **rendered page's metadata**, which a
plain page fetch (WebFetch, or `curl` + grep) exposes as front-matter / `<meta>` tags:

| Field | Meaning | Example (the `training/support/mcp` page, June 2026) |
|---|---|---|
| `updated_at` | **What renders as the visible "Last updated on …" badge**, localized to the viewer's timezone | `2026-05-22T23:04:00Z` → shows **05/23/2026** in CET (UTC+2) — that's why a 23:0x-UTC build reads as the next day |
| `ms.date` | Author-controlled *freshness* date — set by hand / Learn Authoring Pack, **not** derived from git | `2026-05-05T00:00:00Z` |
| `git_commit_id` | Exact source commit SHA | `b3cb6f8fc44f2ccd5428d4adabbce28a6e148247` |
| `original_content_git_url` | The source markdown file | `github.com/MicrosoftDocs/LearnShared/blob/live/LearnShared/support/mcp.md` |

How to read it, in order of preference:

1. **WebFetch the page URL** and ask for `updated_at`, `ms.date`, `git_commit_id`, `original_content_git_url`
   verbatim. (WebFetch surfaces the metadata block; the Learn MCP fetch does not.)
2. For the **true** last-modified — not the author's hand-set date — take `original_content_git_url`, then query
   GitHub: `GET /repos/MicrosoftDocs/<repo>/commits?path=<file>&per_page=1`. Most Learn content sources are public
   `MicrosoftDocs/*` repos (e.g. `LearnShared`, `azure-docs`, `dotnet-docs`).

The visible badge ≈ `updated_at`. `ms.date` is a *claim* of freshness, not proof — see safety below.

## Scope & safety self-check (run before leaning on this skill)

These are the guards for the cases the user "hasn't considered." Check them; they're cheap.

- **Non-Microsoft task → stand down.** If another stack is explicitly named (AWS, GCP, OpenAI, Vercel, a pure
  Node/Python/Rust library with no Microsoft surface), do **not** contort the task into Microsoft framing or force
  the Learn MCP. Use `context7` / `nuget-opensrc` / web instead. This skill helps; it never gates.
- **`ms.date` can lie.** It's hand-set, so content can change without it moving (and vice-versa). When the date
  actually matters, cite *which* field you used (`updated_at` vs `ms.date` vs git commit), and prefer the git
  commit for "was this really touched recently".
- **Local ground truth beats preview docs.** For bleeding-edge `Microsoft.Agents.AI.*` / Foundry / Copilot Studio
  / Fabric, the installed package and its NuGet `.xml` sidecar + the `~/RiderProjects/agent-framework` checkout are
  the deciding source. When Learn (often preview-era) and the local checkout disagree, **trust compile/run + the
  checkout**, and say so. Learn is for concepts and breadth; it is not API-exact for preview packages.
- **The MCP is not a REST API.** Don't script direct HTTP calls against `/api/mcp` expecting stable
  request/response shapes — go through the MCP client. The interface changes dynamically.
- **Index lag.** If something shipped in the last 24h, the MCP may not have it yet — fetch the live page.
- **No secrets, no surprise.** Public docs only; never paste credentials into a doc search; report what you
  actually verified, not what you assume.

## Worked example — "is the Learn MCP page current?"

1. `microsoft_docs_search "Learn MCP Server overview"` → get the canonical URL.
2. WebFetch that URL → read `updated_at` (the badge) and `git_commit_id`.
3. If recency is load-bearing: `original_content_git_url` → GitHub commits API for that path → real last-commit date.
4. Report: "Learn shows *Last updated 05/23/2026* (`updated_at`); author freshness `ms.date` is 05/05; latest
   source commit is `b3cb6f8`." Name the field — don't collapse three different dates into one vague claim.
