# TOON Examples

## Real-World Scenarios

### Example 1: Analyzing User Data

**Input JSON (156 tokens):**
```json
{
  "users": [
    { "id": 1, "email": "alice@example.com", "role": "admin", "signupDate": "2025-01-01" },
    { "id": 2, "email": "bob@example.com", "role": "user", "signupDate": "2025-01-15" },
    { "id": 3, "email": "charlie@example.com", "role": "user", "signupDate": "2025-01-20" }
  ]
}
```

**Same data in TOON (68 tokens) – 57% savings:**
```toon
users[3]{id,email,role,signupDate}:
  1,alice@example.com,admin,2025-01-01
  2,bob@example.com,user,2025-01-15
  3,charlie@example.com,user,2025-01-20
```

### Example 2: Processing Database Results

**Large result set with 50 columns – TOON saves space:**

Query returns: `orders[100]{id,customerId,amount,status,date,region,...}`

Instead of JSON repeating "id", "customerId", etc. 100 times, TOON declares once and streams 100 rows.

**Estimated savings: 300+ tokens on 100 rows × 6 fields**

### Example 3: Event Log Analysis

Send system logs to Claude for analysis:

```toon
events[5]{timestamp,level,service,message}:
  2025-01-15T10:00:00Z,error,auth-service,Connection timeout
  2025-01-15T10:01:00Z,warn,api-gateway,Rate limit approaching
  2025-01-15T10:02:00Z,info,database,Backup completed
  2025-01-15T10:03:00Z,error,payment-service,Invalid card
  2025-01-15T10:04:00Z,info,monitoring,Health check passed
```

Ask Claude: "Identify error patterns and affected services."

## Token Efficiency Comparison

| Format | Users Table (3 records) | Savings |
|--------|---------|---------|
| JSON (formatted) | 156 tokens | baseline |
| JSON (compact) | 112 tokens | -28% |
| **TOON (comma)** | **68 tokens** | **-57%** |
| TOON (tab) | 63 tokens | -60% |

## Common Patterns

### Pattern 1: Uniform Records

Best TOON use case – same fields per row:

```toon
employees[50]{id,name,department,salary,hireDate}:
  1,Alice Smith,Engineering,120000,2023-01-15
  2,Bob Johnson,Sales,80000,2023-03-20
  ...
```

### Pattern 2: With Nested Context

Combine YAML indentation for context with TOON tables:

```toon
context:
  query: "Find top performers by department"
  department: Engineering
  year: 2024
employees[3]{id,name,salary,bonus}:
  1,Alice,120000,25000
  5,David,115000,24000
  8,Emma,110000,22000
```

### Pattern 3: Tab-Separated for Maximum Compression

```toon
logs[4	]{ts	level	service	msg}:
  2025-01-15T10:00:00Z	ERROR	api	Timeout
  2025-01-15T10:01:00Z	WARN	db	Slow query
  2025-01-15T10:02:00Z	INFO	web	Deploy done
  2025-01-15T10:03:00Z	ERROR	cache	OOM
```

**Why tabs win:**
- Single character delimiter (commas are longer to tokenize)
- Rarely appear in text (less escaping needed)
- ~5-15% additional savings vs commas

## Workflow Examples

### Workflow: Batch Analysis

```bash
# 1. Convert large CSV to TOON
npx @toon-format/cli large-export.json --stats

# Shows: Saved ~15,000 tokens (-45.2%)

# 2. Send to Claude in prompt with analysis request
# "Analyze this dataset of 500 customers..."

# 3. Claude returns insights, optionally as TOON
```

### Workflow: Validate Model Output

```bash
# Model generated this TOON response:
MODEL_OUTPUT='
results[2]{id,value,status}:
  10,42.5,approved
  11,37.2,pending
'

# Decode and validate
echo "$MODEL_OUTPUT" | npx @toon-format/cli --decode

# If format is invalid, decode fails and shows error
# If valid, you get clean JSON
```

### Workflow: Pipe from jq

```bash
# Extract subset with jq, convert to TOON
jq '.users[] | select(.role == "admin")' data.json | npx @toon-format/cli

# Process through Claude, convert back:
# (Claude output) | npx @toon-format/cli --decode
```

## When You Might Not Need TOON

- **Single nested objects** (use JSON)
- **Heterogeneous arrays** (varying fields per item)
- **Deeply nested structures** (JSON more efficient)
- **Tiny datasets** (savings < 20 tokens – not worth it)
- **Already using CSV** (TOON adds ~5-10% overhead)
