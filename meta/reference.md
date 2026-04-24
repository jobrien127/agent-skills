# Skill Schema Reference

Complete reference for Claude Code skill authoring. Used by the `/meta` skill during generation.

---

## Frontmatter Fields

```yaml
---
name: skill-name                        # Required. Slash command slug: /skill-name
description: "..."                      # Required. Trigger text — see Description Rules below
user-invocable: true                    # true = appears in / menu (default: true)
disable-model-invocation: true          # true = Claude won't auto-invoke (default: false)
argument-hint: <file> [format]          # Shown in autocomplete when typing /skill-name
allowed-tools: Read, Write, Bash(cmd *) # Pre-approved tools (no confirmation prompt)
context: fork                           # "fork" = run as isolated subagent (default: inline)
agent: general-purpose                  # Subagent type when context: fork
paths: src/**/*.ts,lib/**/*.ts          # Activate only for files matching these globs
---
```

### Field Notes

| Field | When to use |
|---|---|
| `context: fork` | Multi-step workflows with side effects; complex tasks that need clean context |
| `disable-model-invocation: true` | Destructive ops, deploy workflows, anything you control explicitly |
| `argument-hint` | Whenever `$ARGUMENTS` is used in the body |
| `allowed-tools` | Always specify — reduces friction and permission prompts |
| `paths` | Domain-specific skills that only apply to certain file types |

---

## Tool Syntax

```yaml
allowed-tools: Read, Write, Glob, Grep  # Built-in tools
allowed-tools: Bash(git *)               # Bash with glob restriction (git only)
allowed-tools: Bash(npm *), Bash(npx *)  # Multiple Bash scopes
allowed-tools: Agent                     # Allow spawning subagents
allowed-tools: WebSearch, WebFetch       # Web access
```

Multiple tools: comma-separated on one line.

---

## $ARGUMENTS

Reference the user's input anywhere in the body:

```markdown
Fix GitHub issue $ARGUMENTS following our coding standards.
```

Invoked as `/fix-issue 123` → Claude sees "Fix GitHub issue 123..."

Always pair with `argument-hint` in frontmatter:
```yaml
argument-hint: <issue-number>
```

---

## Shell Injection (Dynamic Context)

Run shell commands before Claude sees the prompt using `` !`command` ``:

```markdown
## Current State
- Branch: !`git branch --show-current`
- Diff: !`git diff --stat HEAD`
- Open PRs: !`gh pr list`

Summarize what needs to happen next.
```

The output is inlined before Claude processes the skill body. Requires `Bash(git *)` etc. in `allowed-tools`.

---

## Context Modes

### Inline (default)
- Skill instructions injected into current conversation
- Claude retains full conversation history
- Good for: reference skills, style guides, short tasks

### Forked (`context: fork`)
- Skill runs as isolated subagent with fresh context
- No access to parent conversation history
- Good for: complex multi-step workflows, scaffolding, anything with side effects
- Requires `agent:` field (usually `general-purpose`)

---

## Subagent Types

| Type | Use for |
|---|---|
| `general-purpose` | Most tasks — tools, code, file ops |
| `Explore` | Read-only research, codebase analysis |
| `Plan` | Architecture and implementation planning |
| `claude-code-guide` | Claude Code feature questions |

---

## Directory Layout

```
~/.dotfiles/claude/.claude/skills/<name>/
├── SKILL.md              # Required — instructions + frontmatter
├── reference.md          # Optional — schema, syntax, docs (loaded on demand)
├── examples.md           # Optional — worked examples
└── scripts/
    └── helper.sh         # Optional — executables the skill calls
```

Symlink to activate:
```bash
ln -s ~/.dotfiles/claude/.claude/skills/<name> ~/.claude/skills/<name>
```

Project-scoped skills (no symlink needed):
```
.claude/skills/<name>/SKILL.md
```

---

## Description Rules

The description is what determines whether Claude auto-triggers the skill. Write it to be:

**Specific** — name exact user intents, not categories:
```yaml
# Good
description: Create a new Claude Code skill. Use when the user says "create a skill", 
"make a slash command", "build a new command", or wants to codify a workflow.

# Weak
description: Helps with skill creation.
```

**Pushy** — explicitly invite triggering:
```yaml
description: "...Make sure to use this skill whenever the user wants to build or modify a skill, even if they don't use those exact words."
```

**Verb-first trigger phrases** — list concrete invocation signals:
```yaml
description: Use when the user asks to "add a diagram", "visualize this", 
"create a flowchart", "draw an ERD", or "document this architecture".
```

---

## Body Structure (Best Practices)

### For multi-step workflows:
```markdown
# Skill Name

One-paragraph intro — what it does and why (theory-first, not step-first).

## Phase 1: <Name>
What this phase accomplishes and why it comes first.

Steps...

**Checkpoint**: [explicit pass/fail criterion before proceeding]

## Phase 2: <Name>
...

## Anti-Patterns / Red Flags
- Signal X means you should STOP and [action]
- Never do Y because [reason]

## Verification Checklist
- [ ] Criterion 1
- [ ] Criterion 2
```

### Progressive Disclosure
Keep SKILL.md under 300 lines. Move detailed reference to `reference.md`:

```markdown
For complete syntax, see [reference.md](reference.md).
```

Claude will read it on demand using `Read`.

---

## Quality Checklist

Before saving a generated skill, verify:

- [ ] `name` is lowercase hyphen slug
- [ ] `description` includes concrete trigger phrases
- [ ] `allowed-tools` lists only what's needed (not everything)
- [ ] `disable-model-invocation: true` for any destructive or explicit-only skill
- [ ] Body is theory-first: explains *why* before *how*
- [ ] Multi-step skills have named phases with checkpoints
- [ ] Reference content lives in `reference.md`, not inline
- [ ] Body is under 300 lines
- [ ] Symlink created (personal skills)
