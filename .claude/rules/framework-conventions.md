---
description: Official Claude Code conventions for editing agent and skill files in this project. Loaded automatically when working on .claude/ files or CLAUDE.md.
paths:
  - ".claude/agents/*.md"
  - ".claude/skills/**/*.md"
  - ".claude/rules/*.md"
  - "CLAUDE.md"
---

<!-- FRAMEWORK FILE: improvements → PR to semantic-autoencoder -->


# Framework Conventions

When creating or editing agents, skills, rules, or CLAUDE.md in this project, follow
the official Claude Code conventions below. Reference: code.claude.com/docs/en/

---

## CLAUDE.md

- Target **under 200 lines**. Longer files load fully but reduce adherence.
- Put project conventions, architecture facts, and "always do X" rules here.
- Move step-by-step procedures into skills; move topic-specific rules into `.claude/rules/`.
- Do not put domain physics or run instructions here — those belong in domain skills.

---

## Agent files — `.claude/agents/<name>.md`

**Frontmatter schema** (all optional except `description`):

```yaml
---
name: display-name          # shown in listings; does not affect @-mention name
description: what this agent does and when to use it
tools: Read Write Edit Bash  # space-separated; restricts available tools
---
```

- The body becomes the **system prompt** for the subagent's isolated context window.
- `tools:` restricts which tools are available; omit to inherit all tools.
- Common tool names: `Read`, `Write`, `Edit`, `Bash`, `Agent`, `Grep`, `Glob`,
  `WebFetch`, `WebSearch`.
- `.claude/` is a **protected path** — writes to agent files require explicit approval
  even in `acceptEdits` mode.

---

## Skill files — `.claude/skills/<name>/SKILL.md`

**Frontmatter schema** (all optional; `description` strongly recommended):

```yaml
---
name: display-name              # display label only — command name = directory name
description: what it does and when Claude should auto-invoke it
when_to_use: additional trigger phrases or examples
disable-model-invocation: true  # user-only: Claude never triggers it automatically
user-invocable: false           # Claude-only: hidden from / menu
allowed-tools: Bash(git *)      # pre-approved tools while skill is active
context: fork                   # run in an isolated subagent context window
agent: Explore                  # which subagent to use when context: fork is set
argument-hint: <branch>         # shown during autocomplete
---
```

**When to set `disable-model-invocation: true`:** workflows with side effects or
timing requirements that must be user-triggered — e.g., `/orchestrate`, `/deploy`,
`/run-legacy`, `/run-decoded`. Claude must not start these autonomously.

**When to set `user-invocable: false`:** background reference knowledge that Claude
should apply automatically but users would not invoke directly.

**Body rules:**
- Keep the body **under 500 lines**. Move large reference material to supporting files
  in the skill directory (e.g., `reference.md`, `examples/`).
- Reference supporting files from SKILL.md so Claude knows they exist.
- Dynamic context injection — runs at skill load, before Claude sees anything:
  - Inline: `` !`command` `` (backtick-wrapped; `!` must start the line or follow whitespace)
  - Block: ` ```! ` fenced block for multi-line commands

---

## Invocation summary

| Frontmatter                      | User can invoke | Claude can invoke |
| :------------------------------- | :-------------- | :---------------- |
| (default)                        | Yes             | Yes               |
| `disable-model-invocation: true` | Yes             | No                |
| `user-invocable: false`          | No              | Yes               |

---

## Project-specific skills (must be created per project)

These skills do not exist in the framework skeleton — they must be created for each
new project using the semantic-autoencoder framework:

| Skill | Created by | Content |
|-------|-----------|---------|
| `explain-domain` | `/setup` step | Domain physics, key concepts, IR section guide |
| `run-legacy` | `/setup` step | How to install and run the legacy binary |
| `run-decoded` | `/orchestrate` (before first decoder dispatch) | How to install and run the decoded package |