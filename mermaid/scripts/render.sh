#!/bin/bash
# render.sh - Render Mermaid diagram to image
#
# Renders Mermaid diagram files (.mmd) to various image formats
# using the mmdc (Mermaid CLI) tool.
#
# Usage: ./render.sh input.mmd output.png [theme]
#
# Arguments:
#   input.mmd    - Input Mermaid diagram file (required)
#   output.*     - Output file path with extension (required)
#                 Supported: .png, .svg, .pdf
#   theme        - Theme name (optional, default: 'default')
#                 Options: default, dark, neutral, forest, base
#
# Examples:
#   ./render.sh diagram.mmd diagram.png
#   ./render.sh diagram.mmd diagram.png dark
#   ./render.sh diagram.mmd diagram.svg forest
#   ./render.sh diagram.mmd diagram.pdf

set -e

# Set Chrome path for puppeteer/mmdc if not already set
if [[ -z "$PUPPETEER_EXECUTABLE_PATH" ]]; then
  chrome_path="$HOME/.cache/puppeteer/chrome-headless-shell/mac_arm-144.0.7559.96/chrome-headless-shell-mac-arm64/chrome-headless-shell"
  if [[ -f "$chrome_path" ]]; then
    export PUPPETEER_EXECUTABLE_PATH="$chrome_path"
  fi
fi

input="${1:-}"
output="${2:-}"
theme="${3:-default}"

# Validate arguments
if [[ -z "$input" || -z "$output" ]]; then
  cat >&2 << 'EOF'
Usage: ./render.sh input.mmd output.png [theme]

Arguments:
  input.mmd     Input Mermaid file (required)
  output.*      Output file with extension (required)
                Formats: .png, .svg, .pdf
  theme         Theme name (optional, default: default)
                Options: default, dark, neutral, forest, base

Examples:
  ./render.sh diagram.mmd diagram.png
  ./render.sh diagram.mmd diagram.png dark
  ./render.sh diagram.mmd diagram.svg

For more information, see the skill documentation.
EOF
  exit 1
fi

# Check input file exists
if [[ ! -f "$input" ]]; then
  echo "Error: Input file not found: $input" >&2
  exit 1
fi

# Detect output format from file extension
ext="${output##*.}"
case "$ext" in
  png|svg|pdf)
    format="$ext"
    ;;
  *)
    echo "Error: Unsupported output format: $ext" >&2
    echo "Supported formats: png, svg, pdf" >&2
    exit 1
    ;;
esac

# Validate theme
case "$theme" in
  default|dark|neutral|forest|base)
    ;;
  *)
    echo "Error: Unsupported theme: $theme" >&2
    echo "Supported themes: default, dark, neutral, forest, base" >&2
    exit 1
    ;;
esac

# Render with mmdc
if mmdc -i "$input" -o "$output" -t "$theme" -b transparent 2>&1; then
  echo "✓ Rendered: $output"
  echo "  Theme: $theme"
  echo "  Format: $format"
  exit 0
else
  echo "Error: Failed to render diagram" >&2
  echo "Check that your Mermaid syntax is valid" >&2
  exit 1
fi
