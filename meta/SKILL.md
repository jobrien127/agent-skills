---
name: meta
description: Create a new Claude Code skill from scratch. Use this skill when the user wants to build a reusable slash command, turn a workflow into an invocable skill, codify a repeatable process, or create a new custom command.
user-invocable: true
disable-model-invocation: true
context: fork
agent: general-purpose
allowed-tools: Bash(mkdir -p *), Bash(ln -s *), Bash(ls *), Read, Write, Glob
---

# Meta Skill — Create a New Claude Code Skill

This skill creates high-quality, production-ready Claude Code skills. It applies patterns from the best community skills: explicit phases, strong descriptions, progressive disclosure, and verification checklists.

## Why Skill Quality Matters

A skill is only as good as its description and instructions. A vague description won't trigger. Flat instructions produce inconsistent output. The best skills explain *why* before *how*, state anti-patterns explicitly, and verify success at each phase. This skill builds that in automatically.

For the complete skill schema, see [reference.md](reference.md).

---

## Phase 1: Research

Before the interview, read [reference.md](reference.md) to load the skill schema into context. This ensures the generated skill uses correct field names, syntax, and best practices.

Optionally read one existing skill for structural reference:

```
~/.claude/skills/mermaid/SKILL.md
~/.claude/skills/toon/SKILL.md
```

---

## Phase 2: Interview

Ask the user the following. All questions can be answered in a single message.

1. **Name** — slug for the skill (used as `/name`)
2. **Purpose** — what does it do? One sentence.
3. **Trigger** — when should Claude auto-invoke this? (or: manual-only with `disable-model-invocation: true`)
4. **Scope** — personal (`~/.dotfiles/claude/.claude/skills/`) or project (`.claude/skills/` in cwd)?
5. **Tools** — what tools does it need? (Read, Write, Bash, WebSearch, Agent, etc.)
6. **Supporting files** — does it need `examples.md`, `reference.md`, or scripts?
7. **Arguments** — does it accept `$ARGUMENTS`? If so, what?
8. **Context** — isolated subagent (`context: fork`) or inline?

**Red flags to catch during interview:**

- Name has spaces or uppercase → correct to lowercase hyphen slug
- Trigger is vague ("when relevant") → push for concrete phrases or disable auto-invoke
- Tools list includes everything → ask what it actually needs; over-permission is a smell
- No supporting files for a complex skill → suggest `reference.md` to keep SKILL.md lean

---

## Phase 3: Draft the Skill

Write `SKILL.md` applying these rules:

### Frontmatter Rules

- `description`: Specific and pushy. Include concrete trigger phrases. See [reference.md](reference.md) for examples.
- `allowed-tools`: List only what's needed. Use `Bash(cmd *)` for scoped bash access.
- `context: fork` + `agent: general-purpose` for multi-step workflows with side effects.
- `disable-model-invocation: true` for anything destructive or that shouldn't auto-trigger.
- `argument-hint`: Include if the skill takes `$ARGUMENTS`.

### Body Rules

Structure the body in this order:

1. **One-paragraph intro** — what the skill does and why it exists (theory-first)
2. **Phases** (if multi-step) — each phase has a name, purpose, and success criterion
3. **Anti-patterns / Red Flags** (if applicable) — what to watch for and stop on
4. **Verification Checklist** — explicit pass/fail criteria at the end

Keep the body under 300 lines. Move reference content to `reference.md`.

---

## Phase 4: Scaffold

Create the directory and write files:

```bash
# Personal skill
mkdir -p ~/.dotfiles/claude/.claude/skills/<name>
# Write SKILL.md and any supporting files

# Project skill
mkdir -p .claude/skills/<name>
# Write SKILL.md and any supporting files
```

For personal skills, create the symlink:

```bash
ln -s ~/.dotfiles/claude/.claude/skills/<name> ~/.claude/skills/<name>
```

If `examples.md` or `reference.md` were requested, scaffold them with a stub header and placeholder sections — don't leave them empty.

---

## Phase 5: Confirm

Report back:

- Full paths of all files created
- Invocation: `/<name>` or `/<name> <args>`  
- Whether auto-invoke is on and what triggers it
- One suggested test prompt to verify the skill works
