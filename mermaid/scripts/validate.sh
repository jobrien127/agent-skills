#!/bin/bash
# validate.sh - Validate Mermaid diagram syntax
#
# Checks Mermaid diagram syntax without rendering to an image.
# Useful for CI/CD pipelines and quick syntax validation.
#
# Usage: ./validate.sh input.mmd
#
# Arguments:
#   input.mmd    - Input Mermaid diagram file to validate
#
# Exit codes:
#   0            - Syntax is valid
#   1            - Syntax error or file not found
#
# Examples:
#   ./validate.sh diagram.mmd
#   ./validate.sh diagrams/*.mmd

set -e

# Set Chrome path for puppeteer/mmdc if not already set
if [[ -z "$PUPPETEER_EXECUTABLE_PATH" ]]; then
  chrome_path="$HOME/.cache/puppeteer/chrome-headless-shell/mac_arm-144.0.7559.96/chrome-headless-shell-mac-arm64/chrome-headless-shell"
  if [[ -f "$chrome_path" ]]; then
    export PUPPETEER_EXECUTABLE_PATH="$chrome_path"
  fi
fi

input="${1:-}"

# Validate arguments
if [[ -z "$input" ]]; then
  cat >&2 << 'EOF'
Usage: ./validate.sh input.mmd

Arguments:
  input.mmd    Input Mermaid file to validate

Exit codes:
  0            Syntax is valid
  1            Syntax error or file not found

Examples:
  ./validate.sh diagram.mmd
  ./validate.sh diagrams/*.mmd

For more information, see the skill documentation.
EOF
  exit 1
fi

# Check input file exists
if [[ ! -f "$input" ]]; then
  echo "✗ Error: Input file not found: $input" >&2
  exit 1
fi

# Create temp file for validation output
tmp_dir=$(mktemp -d)
tmp_output="$tmp_dir/mermaid-validation-$$.png"
trap "rm -rf $tmp_dir" EXIT

# Attempt to render diagram - validates syntax
# We suppress the output and just check the exit code
if mmdc -i "$input" -o "$tmp_output" 2>/dev/null; then
  echo "✓ Syntax valid: $input"
  exit 0
else
  echo "✗ Syntax error in: $input" >&2
  # Try again with verbose output to show the error
  echo "" >&2
  echo "Error details:" >&2
  mmdc -i "$input" -o "$tmp_output" 2>&1 || true
  exit 1
fi
