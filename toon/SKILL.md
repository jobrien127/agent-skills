---
name: TOON
description: Work with TOON format for token-efficient LLM data encoding. Use when optimizing token costs for structured data, encoding/decoding JSON datasets, or passing tabular data to models. Supports streaming, validation, and multiple delimiters.
disable-model-invocation: false
user-invocable: true
allowed-tools: Bash(npx *)
---

# TOON: Token-Oriented Object Notation

TOON is a compact encoding format for structured data that reduces token costs by 30-60% compared to JSON while improving LLM reliability through explicit structure markers. Use TOON when you need to:

- **Reduce token costs** for large datasets (saves 30-60% vs JSON)
- **Send tabular data** to LLMs with clear structure
- **Validate LLM output** with strict mode checking
- **Stream large datasets** efficiently without memory overhead

This skill covers practical TOON usage patterns. Full format documentation is in [reference.md](reference.md).

## Core Concept

TOON declares structure once, then streams data as rows. For a dataset of users:

```toon
users[3]{id,name,role}:
  1,Alice,admin
  2,Bob,user
  3,Charlie,user
```

vs JSON (verbose repetition):

```json
{
  "users": [
    { "id": 1, "name": "Alice", "role": "admin" },
    { "id": 2, "name": "Bob", "role": "user" },
    { "id": 3, "name": "Charlie", "role": "user" }
  ]
}
```

The `[3]` declares array length (helps detect truncation), `{id,name,role}` declares fields once, then rows are compact comma-separated values.

## Using TOON in Prompts

### Sending Data to Models

Show, don't describe. Models learn TOON from examples:

```toon
users[3]{id,name,role,lastLogin}:
  1,Alice,admin,2025-01-15T10:30:00Z
  2,Bob,user,2025-01-14T15:22:00Z
  3,Charlie,user,2025-01-13T09:45:00Z
```

Then ask: "Summarize user roles and activity levels."

**Why this works:**
- Explicit array length `[3]` helps detect truncation
- Field names `{id,name,...}` appear once, reducing repetition
- Models parse the pattern naturally (similar to YAML/CSV)
- Compact representation saves tokens

### Requesting TOON Output

When you want models to generate TOON, be explicit about structure:

```toon
users[N]{id,name,role}:
  (fill in rows here)
```

Tell the model: "Return only users with role='user'. Use the same TOON format. Set [N] to match row count. Output only the code block."

The model adjusts `[N]` based on actual rows and follows the format precisely.

## Converting Data with CLI

Use the `@toon-format/cli` tool to convert between JSON and TOON:

### Encode JSON to TOON

```bash
npx @toon-format/cli input.json -o output.toon
```

### Decode TOON to JSON

```bash
npx @toon-format/cli data.toon -o output.json
```

### Pipe from stdin

```bash
echo '{"users":[{"id":1,"name":"Alice"}]}' | npx @toon-format/cli
```

### View token savings

```bash
npx @toon-format/cli data.json --stats
```

Shows: "Saved ~6,400 tokens (-42.3%)"

## Advanced Usage

### Delimiters for Token Efficiency

Comma (default) is readable, but tabs and pipes tokenize more efficiently:

```bash
# Tab-separated (most efficient)
npx @toon-format/cli data.json --delimiter "\t"

# Pipe-separated
npx @toon-format/cli data.json --delimiter "|"
```

Tab output:
```toon
users[2	]{id	name	role}: 1	Alice	admin
  2	Bob	user
```

**Use tabs** for large datasets – often 5-15% fewer tokens than commas.

### Key Folding for Nested Data

Collapse deeply nested structures:

```bash
npx @toon-format/cli data.json --keyFolding safe
```

Converts:
```yaml
data:
  metadata:
    items[2]: a,b
```

To:
```yaml
data.metadata.items[2]: a,b
```

### Streaming Large Files

For memory efficiency with huge datasets:

```bash
npx @toon-format/cli huge-dataset.json --stats > output.toon
```

No full string held in memory – streams line-by-line.

## When to Use TOON

**Use TOON when:**
- Uniform arrays of objects (same fields per row)
- Data going to LLMs (30-60% token savings)
- You need validation (detect truncation, malformed output)
- Streaming large datasets (memory efficient)

**Don't use TOON when:**
- Deeply nested, non-uniform structures (JSON better)
- Pure flat tables (CSV is smaller)
- Data isn't tabular (use JSON objects)

## Tips & Best Practices

| Practice | Why |
|----------|-----|
| **Show examples** | Models learn from patterns, not descriptions |
| **Keep examples small** | 2-5 rows enough for generalization |
| **Use small field counts** | Easier for models to track structure |
| **Validate output** | Check for count mismatches, malformed data |
| **Start with comma** | Switch to tabs only if token savings matter |
| **Label code blocks** | ` ```toon` helps readers recognize format |

## Workflow: Send & Validate

Complete workflow showing TOON in action:

**Step 1: Prepare TOON data**
```bash
npx @toon-format/cli users.json --stats
# Output: Saved ~6,400 tokens (-42.3%)
```

**Step 2: Send to model in prompt**
```toon
users[3]{id,name,role}:
  1,Alice,admin
  2,Bob,user
  3,Charlie,user
```

**Step 3: Request TOON output**
"Filter users with role='user'. Return as TOON using same format. Set [N] to actual count."

**Step 4: Validate response**
```bash
# Model returns TOON, decode it back
npx @toon-format/cli <<'EOF' --decode
users[2]{id,name,role}:
  2,Bob,user
  3,Charlie,user
EOF
```

Produces valid JSON if the format is correct, error if malformed.

## Reference

See [reference.md](reference.md) for:
- Complete TOON syntax (escaping, nested objects, etc.)
- Full CLI option documentation
- Language-specific implementations
