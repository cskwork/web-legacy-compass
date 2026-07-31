#!/usr/bin/env bash
# web-legacy-compass install — copies the skill into a target project.
# Usage: ./install.sh /path/to/your/project
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <target-project-path>"
  echo "  Copies SKILL.md, references/, and templates/ into"
  echo "  <target>/.agents/skills/web-legacy-compass/"
  exit 1
fi

TARGET="$1"
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$TARGET/.agents/skills/web-legacy-compass"

if [ ! -d "$TARGET" ]; then
  echo "Error: target path '$TARGET' does not exist."
  exit 1
fi

mkdir -p "$DEST/references" "$DEST/templates"

cp "$SRC/SKILL.md" "$DEST/SKILL.md"
cp "$SRC"/references/*.md "$DEST/references/" 2>/dev/null || true
cp "$SRC"/templates/*.md "$DEST/templates/" 2>/dev/null || true

# Ensure docs/web-flows/ exists for flow records.
mkdir -p "$TARGET/docs/web-flows"

echo ""
echo "✓ web-legacy-compass installed to:"
echo "  $DEST"
echo ""
echo "Flow records go to:"
echo "  $TARGET/docs/web-flows/"
echo ""
echo "The skill is now available to your agent. Invoke it with:"
echo "  /web-legacy-compass"
