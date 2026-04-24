#!/bin/bash
# preview.sh - Generate quick preview of Mermaid diagram
#
# Renders a Mermaid diagram to a PNG preview file with default settings.
# Optionally attempts to open the preview in the default image viewer.
#
# Usage: ./preview.sh input.mmd
#
# Arguments:
#   input.mmd    - Input Mermaid diagram file (required)
#
# Output:
#   Generates: input-preview.png in the same directory as input
#
# Environment:
#   - Uses 'open' command on macOS to display preview
#   - Falls back gracefully if open is not available
#
# Examples:
#   ./preview.sh diagram.mmd
#   ./preview.sh architecture.mmd

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
Usage: ./preview.sh input.mmd

Arguments:
  input.mmd    Input Mermaid diagram file (required)

Output:
  Generates a preview PNG file with default theme

Examples:
  ./preview.sh diagram.mmd
  ./preview.sh architecture.mmd

For more information, see the skill documentation.
EOF
  exit 1
fi

# Check input file exists
if [[ ! -f "$input" ]]; then
  echo "✗ Error: Input file not found: $input" >&2
  exit 1
fi

# Extract directory and base name
dir=$(dirname "$input")
base=$(basename "$input" .mmd)

# Generate output filename
output="$dir/$base-preview.png"

# Render with default theme and transparent background
if mmdc -i "$input" -o "$output" -t default -b transparent 2>&1; then
  echo "✓ Preview generated: $output"

  # Try to open the preview (macOS)
  if command -v open &> /dev/null; then
    open "$output" 2>/dev/null || echo "  (open manually to view)"
  else
    echo "  Open manually to view the preview"
  fi

  exit 0
else
  echo "✗ Error: Failed to generate preview" >&2
  echo "Check that your Mermaid syntax is valid" >&2
  exit 1
fi
