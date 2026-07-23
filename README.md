# ancplua-skills

Public, AI-agnostic skill pack.

The portable unit is a directory containing `SKILL.md`. Claude, Codex, and other agents can all consume that shape because it is plain Markdown with small YAML frontmatter. Runtime-specific files, such as Claude subagents or local permission config, belong under `adapters/` and are not part of the core contract.

## What Is Portable

Portable:

- `skills/packs/<skill>/SKILL.md`
- optional `references/`, `scripts/`, and `assets/` under the skill folder
- frontmatter keys such as `name`, `description`, `license`, `metadata`
- Markdown routing tables and relative links

Runtime-specific:

- Claude subagents
- slash commands
- permission settings
- MCP connector configuration
- model names such as `opus`, `sonnet`, or OpenAI model slugs

Those runtime-specific pieces live in `adapters/`.

## Skills

The generated index is [SKILLS.md](SKILLS.md).

Current core skills:

- `c4-diagram`
- `forgejo-direct-api`
- `maf-dotnet-source-of-truth`
- `mcp-csharp-sdk-1.4.0`
- `microsoft-first-research`
- `microsoft-learn-grounding`
- `qyl-tfm-map`
- `react-bits-pro`
- `supercritical-code-quality-review`

### Selected Skill Guide

| Skill | What it does | Use it when |
| --- | --- | --- |
| [`animation-vocabulary`](skills/packs/animation-vocabulary/SKILL.md) | Translates vague descriptions like "the bouncy popup effect" into precise motion terms such as **Pop in**, **Spring**, or **Rubber-banding**. It only names effects; it does not design or implement them. | You know what an animation looks like but not what it is called. |
| [`apple-design`](skills/packs/apple-design/SKILL.md) | Applies Apple-style interface principles to the web: immediate feedback, direct manipulation, interruptible springs, momentum, drag resistance, translucent materials, typography, depth, and reduced motion. | Building gesture-heavy, physical, iOS-like interfaces. |
| [`emil-design-eng`](skills/packs/emil-design-eng/SKILL.md) | A broad UI-polish guide based on Emil Kowalski's design-engineering philosophy. Covers whether something should animate, easing, durations, springs, transforms, gestures, component details, perceived performance, and interaction polish. | Building or reviewing polished frontend interactions, not just animation in isolation. |
| [`extension-store-publishing`](skills/packs/extension-store-publishing/SKILL.md) | Operates automated browser-extension releases for Edge Add-ons, Chrome Web Store, and Firefox AMO. Includes credential setup, upload and publish APIs, CI secrets, status polling, and common review errors. | Creating or debugging `publish:edge`, `publish:chrome`, or `publish:firefox` workflows. |
| [`maf-dotnet-source-of-truth`](skills/packs/maf-dotnet-source-of-truth/SKILL.md) | Forces Microsoft Agent Framework .NET code to be written against a pinned local source checkout instead of stale documentation or memory. It checks real signatures and catches renamed APIs such as `AgentThread` becoming `AgentSession`. | Writing, reviewing, or fixing `Microsoft.Agents.AI` and `Microsoft.Extensions.AI` agent code. |
| [`improve-animations`](skills/packs/improve-animations/SKILL.md) | Performs a read-only, whole-codebase motion audit. It finds high-value problems, prioritizes them, and writes self-contained implementation plans under `plans/`. It does not directly change source code. | You want an animation improvement roadmap for an application or repository. |
| [`qyl-tfm-map`](skills/packs/qyl-tfm-map/SKILL.md) | Knows which qyl C# projects target `net10.0`, `netstandard2.0`, or both. It prevents using modern runtime APIs inside Roslyn generators while clarifying that modern C# syntax remains allowed through polyfills. | Editing qyl C#, especially source generators, analyzers, multi-targeted libraries, or AOT-sensitive code. |
| [`review-animations`](skills/packs/review-animations/SKILL.md) | Reviews an existing animation diff against strict standards: purpose, frequency, easing, duration, origin, interruptibility, GPU performance, accessibility, and cohesion. Produces findings followed by an explicit **Block** or **Approve** verdict. | Reviewing a specific implementation or pull request after motion code has been written. |

The motion skills differ mainly by phase:

- `animation-vocabulary`: identify the name.
- `apple-design`: apply Apple's physical interaction model.
- `emil-design-eng`: broadly design and polish the interface.
- `improve-animations`: audit a whole codebase and create plans.
- `review-animations`: judge a specific implementation or diff.

## Install

Claude:

```bash
mkdir -p ~/.claude/skills
cp -R skills/packs/<skill-name> ~/.claude/skills/
```

Codex:

```bash
mkdir -p ~/.codex/skills
cp -R skills/packs/<skill-name> ~/.codex/skills/
```

Any other model/runtime:

1. Read `SKILL.md`.
2. Resolve relative paths from that skill directory.
3. Ignore unsupported frontmatter keys.
4. Map tool names and connector names to equivalent local capabilities.

## Credentials

No real secrets are stored in this repo. Some skills mention environment variables such as `FORGEJO_TOKEN` or `REACTBITS_LICENSE_KEY`; those are placeholders and must be supplied by the user in their own environment.

`react-bits-pro` is instructions-only and requires the user's own React Bits Pro access.

## Generate The Index

```bash
./build.sh GenerateSkills
```

Validation:

```bash
./build.sh ValidateSkills
dotnet build ancplua-skills.slnx --nologo
```

## License

Repository wrapper content is MIT unless a skill declares a narrower upstream license or access requirement in its own `SKILL.md` or registry entry.
