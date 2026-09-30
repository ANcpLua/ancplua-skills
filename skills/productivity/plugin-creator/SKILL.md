---
name: plugin-creator
description: Claude Code plugins, from scaffold to marketplace. Use when creating a plugin or adding skills, agents, hooks, MCP or LSP servers to one, when listing a plugin in a marketplace, when edits to an installed plugin don't show up, or when submitting a plugin to Anthropic's plugin directory.
---

# Plugin creator

The `claude plugin` CLI does the work: `init` scaffolds, `validate` checks, `marketplace add`, `install` and `update` distribute. `claude plugin <command> --help` lists every option. This skill holds the choices and rules the help leaves out.

## 1. Place the plugin
- **Personal, the default:** `claude plugin init <name> --description "<text>" --with <components>` creates `~/.claude/skills/<name>/`, which loads in every session as `<name>@skills-dir`, with no marketplace and no install. `--with` takes `skills`, `agents`, `hooks`, `mcp`, `lsp`, `output-style` and `channel`.
- **Shared, on request:** a plugin folder in a repository, listed in a marketplace (step 3). A plugin for Anthropic's directory sits at the root of its own GitHub repository. `init` always writes under `~/.claude/skills/`, so write a shared plugin's manifest yourself.

Done when the plugin folder holds `.claude-plugin/plugin.json` and its `name` equals the folder name.

## 2. Fill it
- `name`: kebab-case with lowercase letters, digits and hyphens, at most 64 characters, starting and ending with a letter or digit. Anchor it on a distinctive project name: the directory refuses `claude`, `anthropic`, `official`, `plugin`, `mcp` or `test` as the whole name and holds names made only of generic words for review.
- Set `description`, `version`, `author` and `license`. `init` copies `git config user.email` into `author.email`; take it out before the plugin goes public unless the user wants it published.
- Components in their default places load without manifest entries: `skills/<name>/SKILL.md`, `agents/*.md`, `commands/`, `hooks/hooks.json`, `.mcp.json`, `.lsp.json`, `output-styles/`, `bin/`. A manifest path is `./`-relative and stays inside the plugin; for `commands`, `agents` and `outputStyles` it replaces the default folder instead of adding to it.
- Bundle everything the plugin runs inside its folder: installed plugins are copies, so a path above the plugin root is missing at run time. Hooks and servers reach bundled files through `${CLAUDE_PLUGIN_ROOT}` and keep state in `${CLAUDE_PLUGIN_DATA}`. Skill and agent Markdown gets these variables substituted inline; commands Claude runs through Bash don't see them.
- Commit regular files: symbolic links, submodules, Git LFS pointers and `.DS_Store` break loading or the directory checks. A `CLAUDE.md` in the plugin root never loads; put instructions in a skill.

Done when `claude plugin validate <plugin-folder> --strict` passes.

## 3. List it in a marketplace (on request)
A marketplace is a folder, its root, holding `.claude-plugin/marketplace.json`. Create the file when it's missing; otherwise append the entry and keep the other entries and their order:

```json
{
  "name": "<marketplace>",
  "owner": { "name": "<owner>" },
  "description": "<what the marketplace offers>",
  "plugins": [
    { "name": "<plugin>", "source": "./plugins/<plugin>", "description": "<one line>", "category": "<category>" }
  ]
}
```

- `source` starts with `./` and resolves from the marketplace root, never through `..`; `"."` is the root itself, for a repository that is both the plugin and its marketplace.
- The marketplace `name` is what users type after `@`. It has no spaces, `/`, `\` or `..`, and avoids reserved names: Anthropic's own marketplace names and look-alikes of them, `inline`, `builtin`, `skills-dir`, `synced`, `claude-plugin-test`, `npm`, `pip`, `uv`, `cargo`, `github`, `gh`, and names starting with `claudeai-`. `claude plugin marketplace list` shows the names already registered.
- Register the marketplace once with `claude plugin marketplace add <root-folder or owner/repo>`, then `claude plugin install <plugin>@<marketplace>`.

Done when `claude plugin validate <marketplace-root>` passes and `claude plugin list` shows the plugin.

## 4. Pick up edits
- **Loaded in place:** plugins under `~/.claude/skills/`, `claude --plugin-dir <folder>`, and relative-path plugins of a marketplace added from a local folder. Edits apply at the next session or `/reload-plugins`, whatever the version says.
- **Copied into the cache:** plugins from GitHub, git, npm or archive sources. Claude Code updates only when the computed version changes: `plugin.json` `version` first, then the entry's `version`, then the commit. Raise a pinned `version` with every release, or leave it out to follow commits. Then run `claude plugin marketplace update <marketplace>` and `claude plugin update <plugin>@<marketplace>`, and `/reload-plugins` or restart.
- `claude --plugin-dir <folder>` loads a working copy for one session and wins over an installed plugin with the same name.

## 5. Submit to the directory (on request)
Anthropic's plugin directory, which the Claude Marketplace website shows, lists plugins from GitHub repositories through the developer portal at https://claude.ai/directory/manage. Its checklist is https://claude.com/docs/plugins/pre-submission-checklist. A submission is blocked without a README of at least 40 words outside code blocks, without a `LICENSE` file or `license` field, or with `.DS_Store` files, and held for review for files that aren't text, images or fonts, or non-image files over 256 KiB. The README describes everything the plugin runs, fetches or sends, since the security scan checks behavior against it. Pushing the repository and accepting the portal's terms are the user's decisions.

## Handoff
End with the plugin folder, its id (`<name>@skills-dir` or `<plugin>@<marketplace>`), the validate result, and how it loads: `/reload-plugins` or a new session, then `/plugin` to see it and `claude plugin details <name>` for its components and token cost.
