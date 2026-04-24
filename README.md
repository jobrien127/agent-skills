# agent-skills

A curated library of Claude Code skills — reusable slash commands and behavioral modifiers that extend Claude's capabilities across projects.

## Overview

Skills are organized into two categories:

- **Workflow skills** — invoke explicit processes (diagramming, encoding, scaffolding)
- **Cognitive traits** — inject behavioral context that shapes how Claude approaches any task

## Workflow Skills

| Skill | Command | Description |
|-------|---------|-------------|
| **meta** | `/meta` | Create a new Claude Code skill from scratch. Interviews you, drafts the frontmatter and body, and scaffolds the directory. |
| **mermaid** | `/mermaid` | Generate Mermaid diagrams (flowcharts, sequence, ERD, Gantt) for architecture and process documentation. |
| **toon** | `/toon` | Encode and decode structured data using TOON format for token-efficient LLM data passing. |
| **ralph-orchestration** | `/ralph-orchestration` | Set up, configure, and debug Ralph Orchestrator multi-agent projects. |
| **archving** | `/archving` | Organize, store, and retrieve archived materials and historical records. |
| **surveying** | `/surveying` | Conduct broad assessments of a domain or codebase before diving deep. |
| **experimentation** | `/experimentation` | Test hypotheses and explore approaches through structured doing. |
| **purge** | `/purge` | Eliminate unused code, remove clutter, and clean up dead weight. |

## Cognitive Trait Skills

These skills activate behavioral context — they change how Claude reasons, not just what it does.

| Skill | Activates when... |
|-------|-------------------|
| **analytical-thinking** | Deep analysis, breaking down complex problems, identifying assumptions |
| **conscientiousness** | Quality matters — testing, reviewing, catching edge cases |
| **craftsmanship** | Building something that will be used or maintained — code quality, UX, "doing it right" |
| **curiosity** | Exploring ideas, understanding unfamiliar concepts, investigating the unknown |
| **discipline** | Focus and structure — ignoring distractions, following constraints, staying on track |
| **foresight** | Planning ahead, anticipating consequences, thinking long-term |
| **inspection** | Examining details, auditing outputs, validating assumptions closely |
| **integrity** | Honesty and alignment — saying hard truths, doing the right thing |

## Skill Schema

The [`meta/reference.md`](meta/reference.md) file is the canonical schema for skill authoring. It documents all frontmatter fields, tool syntax, `$ARGUMENTS` usage, shell injection, context modes, and quality checklists.

## Installation

### Personal (all projects)

```bash
# Copy to dotfiles
cp -r <skill-name> ~/.dotfiles/claude/.claude/skills/

# Symlink to activate
ln -s ~/.dotfiles/claude/.claude/skills/<skill-name> ~/.claude/skills/<skill-name>
```

### Project-scoped

```bash
cp -r <skill-name> .claude/skills/
```

No symlink needed — Claude Code picks up `.claude/skills/` automatically.

## Creating New Skills

Use the `/meta` skill to scaffold a new skill interactively:

```
/meta
```

It will ask you for a name, purpose, trigger conditions, tools, and context mode, then generate a production-ready `SKILL.md` with correct frontmatter and a structured body.

## License

MIT
