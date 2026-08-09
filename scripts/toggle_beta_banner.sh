#!/usr/bin/env bash
set -euo pipefail

README_PATH="$1"
VERSION="$2"

MARKER_START="<!-- SKYFLOW-BETA-DISCLAIMER:START -->"
MARKER_END="<!-- SKYFLOW-BETA-DISCLAIMER:END -->"

TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

if [[ "$VERSION" =~ beta|dev ]]; then
  # Insert banner if not already present
  if ! grep -qF "$MARKER_START" "$README_PATH"; then
    # Find the first heading and insert banner after it
    awk '
      NR == 1 && /^#/ {
        print $0
        print ""
        print "<!-- SKYFLOW-BETA-DISCLAIMER:START -->"
        print ""
        print "> **Warning:** This is a **beta/pre-release** build of the Skyflow JavaScript/TypeScript SDK."
        print "> It is **not recommended for production use** and is provided for testing and evaluation only."
        print "> Features, APIs, and behavior may change without notice."
        print "> Use at your own risk, and report issues to the Skyflow team."
        print ""
        print "<!-- SKYFLOW-BETA-DISCLAIMER:END -->"
        print ""
        next
      }
      { print }
    ' "$README_PATH" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$README_PATH"
  fi
else
  # Remove banner if present
  if grep -qF "$MARKER_START" "$README_PATH"; then
    awk '
      /<!-- SKYFLOW-BETA-DISCLAIMER:START -->/ { skip = 1; next }
      /<!-- SKYFLOW-BETA-DISCLAIMER:END -->/ { skip = 0; next }
      !skip { print }
    ' "$README_PATH" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$README_PATH"
  fi
fi
