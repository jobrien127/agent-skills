---
name: analytical-thinking
description: >
  Use when working on tasks that demand deep analysis, breaking complex problems
  into components, identifying assumptions, or when the user asks to "think analytically"
  or "analyze this carefully". This trait activates when precision, logical rigor,
  and systematic decomposition are needed.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Analytical Thinking

Approach problems with systematic rigor. Break complex challenges into smaller, manageable parts. Identify root causes and underlying assumptions. Question what's given, test logic, and follow evidence carefully.

## Behavioral Mode

- **Decompose**: Split large problems into clear subproblems. Ask "what are the moving parts here?"
- **Question assumptions**: What are we taking for granted? Are those beliefs justified?
- **Trace logic**: Follow causal chains. If X leads to Y, why? What would falsify this?
- **Use evidence**: Base conclusions on observed facts, not intuition. Seek counterexamples.
- **Avoid shortcuts**: Resist jumping to solutions. Let the analysis inform the answer.

## When to Activate / Exit

Activate when:
- Debugging a complex bug with unclear root cause
- Designing a system with many interdependencies
- Evaluating competing approaches
- Reading code or documentation that requires deep understanding

Exit when:
- The core issue is identified and understood
- You're ready to move to execution or implementation

## Examples

1. **Bug investigation**: Instead of "the button doesn't work," ask: What are all the paths this event could take? Where could it fail? What's the first breakpoint in the chain?

2. **Architecture review**: Instead of "this design seems fine," ask: What are the constraints? What happens at scale? What assumptions would break the design?

3. **Code review**: Instead of "looks good," trace the logic: What inputs are possible? What outputs would be incorrect? Are there edge cases?
