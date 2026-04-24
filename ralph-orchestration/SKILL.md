---
name: ralph-orchestration
description: >
  Help set up, configure, run, and debug Ralph Orchestrator projects.
  Use this skill whenever the user mentions ralph, wants to scaffold a multi-agent
  loop, configure hats, create ralph.yml or PROMPT.md, fix ralph parse errors,
  manage running loops, or understand how Ralph's event system works.
  Also trigger for questions about completion promises, scratchpads, memories,
  parallel loops, or hat triggers/publishes.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
model: sonnet
---

# Ralph Orchestrator Skill

Ralph is a Bash-loop orchestrator that runs an AI agent iteratively against a `PROMPT.md`
until the agent outputs a configured completion string. It supports multi-agent workflows
via "hats" — specialized behavioral modes triggered by events.

---

## ralph.yml — Full Schema Reference

```yaml
cli:
  backend: "claude"           # AI backend (claude, q, gemini)
  prompt_mode: "arg"          # "arg" | "stdin"

event_loop:
  prompt_file: "PROMPT.md"
  completion_promise: "LOOP_COMPLETE"   # exact string agent must output to end loop
  starting_event: "task.start"          # first event emitted when ralph starts
  max_iterations: 40
  max_runtime_seconds: 14400            # optional, 4 hours
  idle_timeout_secs: 1800               # optional, 30 min

core:
  scratchpad: ".ralph/agent/scratchpad.md"
  specs_dir: ".ralph/specs/"

memories:
  enabled: true
  path: .ralph/agent/memories.md
  injection: "auto"           # "auto" | "manual" | "none"
  token_budget: 2000

tasks:
  enabled: true
  path: .ralph/agent/tasks.jsonl

features:
  parallel: false
  preflight_checks: true

hats:
  my-hat:                             # map key = hat ID (arbitrary)
    name: "Display Name"              # shown in logs
    description: "What this hat does" # Ralph uses this for delegation decisions
    triggers: ["event.name", "glob.*"] # flat inline string array — see Glob Patterns
    publishes: ["event.done"]          # events this hat may emit
    instructions: |                    # injected when hat is active
      You are ...
    default_publishes: "event.done"   # emitted if hat outputs nothing explicit (optional)
    max_activations: 3                # hard cap per run (optional)
    backend: "claude"                 # override per-hat (optional)
```

### Glob patterns in triggers
- `"task.start"` — exact match
- `"build.*"` — matches `build.start`, `build.done`, etc.
- `"*.error"` — matches any error event
- `"*"` — matches everything (catch-all hat)

---

## ⚠ Common Mistakes (Parse Errors)

These will all produce `Failed to parse merged core config from ralph.yml`:

| Mistake | Fix |
|---|---|
| `hats` defined as a YAML list (`- name: "X"`) | Use a map: `hats:\n  my-hat:\n    name: "X"` |
| `triggers` as objects (`- pattern: "x"`) | Use flat strings: `triggers: ["x"]` |
| `instructions` field named `system_prompt` | Rename to `instructions` |
| `guardrails` under `core:` | Remove it — `guardrails` is not a valid field |
| Agent never outputs `completion_promise` string | Add exact string to PROMPT.md; loop hits max iterations |

---

## Initializing a New Project

When a user wants to set up Ralph in a directory, scaffold these two files:

### ralph.yml template

```yaml
cli:
  backend: "claude"

event_loop:
  prompt_file: "PROMPT.md"
  completion_promise: "TASK_COMPLETE"
  max_iterations: 30

core:
  scratchpad: ".ralph/agent/scratchpad.md"
  specs_dir: ".ralph/specs/"

memories:
  enabled: true
  path: .ralph/agent/memories.md
  injection: "auto"

tasks:
  enabled: true
  path: .ralph/agent/tasks.jsonl

hats:
  # Add hats here if using multi-agent workflow
  # See "Configuring Hats" section below
```

### PROMPT.md template

```markdown
# [Project Name]

## Objective
[Single clear statement of what this loop should accomplish]

## Phase 1 — [Name]
[Steps]
**Done when:** [concrete file or output exists]

## Phase 2 — [Name]
[Steps]
**Done when:** [concrete condition]

## Success Criteria
- [ ] [measurable outcome 1]
- [ ] [measurable outcome 2]

## Completion

When all phases are complete and success criteria are met, output exactly:

TASK_COMPLETE
```

---

## Configuring Hats

Hats are specialized agent modes activated by events. Use them when you want
different behavior for different phases of a workflow.

### Pipeline pattern (Scout → Worker → Validator)

```yaml
event_loop:
  starting_event: "discovery.start"   # kicks off the first hat automatically
  completion_promise: "PIPELINE_DONE"
  max_iterations: 40

hats:
  scout:
    name: "Scout"
    description: "Analyzes the project structure and produces a content map"
    triggers: ["discovery.start"]
    publishes: ["discovery.complete"]
    instructions: |
      You are the Scout. Analyze the target directory...
      When done, emit: discovery.complete

  worker:
    name: "Worker"
    description: "Processes discovered content and generates outputs"
    triggers: ["discovery.complete"]
    publishes: ["work.complete"]
    instructions: |
      You are the Worker. Read the content map...
      When done, emit: work.complete

  validator:
    name: "Validator"
    description: "Validates outputs and signals completion"
    triggers: ["work.complete"]
    publishes: ["pipeline.done"]
    instructions: |
      You are the Validator. Check all outputs...
      When satisfied, output exactly: PIPELINE_DONE
```

**Key rules for hats in a pipeline:**
- Set `event_loop.starting_event` to trigger the first hat automatically
- Each hat's `instructions` must tell it what event to emit when done
- The final hat's instructions must output the `completion_promise` string
- `description` matters — Ralph uses it to decide which hat to delegate to

---

## PROMPT.md for Multi-Hat Workflows

When using hats, PROMPT.md is the fallback prompt (injected every iteration when
no hat is active). Keep it minimal — let the hat `instructions` do the per-phase work:

```markdown
# [Project Name]

Check the scratchpad at .ralph/agent/scratchpad.md to see current progress.
If no hat has been activated yet, emit the starting event to begin the pipeline.

The pipeline is: Scout → Worker → Validator

Output PIPELINE_DONE only after all phases are confirmed complete.
```

---

## Running & Monitoring

```bash
# Start a loop
ralph run

# Start with a custom config
ralph run -c my-config.yml

# List running loops
ralph loops

# Tail logs for a specific loop
ralph loops logs <loop-id> --follow

# Stop a loop
ralph loops stop <loop-id>

# Task management
ralph task list
ralph task add "description"
ralph task complete <id>
```

### Parallel loops (worktrees)
When `features.parallel: true`, running `ralph run` while one is active
spawns a new loop in `.worktrees/<loop-id>/`. Memories are shared via symlink.
Use `ralph run --exclusive` to queue instead of parallelize.

---

## Debugging

### Parse errors
Run `ralph run 2>&1` and check the "Caused by" message. Cross-reference the
**Common Mistakes** table above. Most parse errors are one of the 5 known issues.

### Loop hits max_iterations without completing
1. Check PROMPT.md — does it contain the exact `completion_promise` string?
2. Check `.ralph/agent/scratchpad.md` — is the agent making progress each iteration?
3. Check `.ralph/events-*.jsonl` — are hats being triggered as expected?
4. Check `.ralph/diagnostics/logs/` for detailed per-iteration logs
5. Lower `max_iterations` during development to fail fast

### Hats not activating
- Verify `event_loop.starting_event` is set (otherwise nothing triggers the first hat)
- Verify the previous hat's instructions say to emit the trigger event
- Check that trigger strings exactly match what the hat publishes (case-sensitive)

### Memories not persisting
Ensure `memories.enabled: true` and the path exists. On first run, `.ralph/agent/memories.md`
is created automatically.
