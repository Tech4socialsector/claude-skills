#!/usr/bin/env bash
# Install / update the team skills into Claude Code (~/.claude/skills).
#
# First time:   bash <(curl -fsSL https://raw.githubusercontent.com/<org>/claude-skills/main/install.sh)
#    or:        git clone <repo-url> ~/claude-skills && bash ~/claude-skills/install.sh
# Update later: bash ~/claude-skills/install.sh
#
# Options (environment variables):
#   REPO_URL=...      git URL of this repo (needed only when run via curl)
#   REPO_DIR=...      where the repo is kept            (default: ~/claude-skills)
#   TARGET=...        where skills are installed         (default: ~/.claude/skills)
#                     use TARGET=<project>/.claude/skills for one project only
set -euo pipefail

REPO_URL="${REPO_URL:-}"
REPO_DIR="${REPO_DIR:-$HOME/claude-skills}"
TARGET="${TARGET:-$HOME/.claude/skills}"

# If this script runs from inside a clone, use that clone.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/plugins/team-vue/skills" ]; then
  REPO_DIR="$SCRIPT_DIR"
fi

if [ -d "$REPO_DIR/.git" ]; then
  echo "Updating $REPO_DIR ..."
  git -C "$REPO_DIR" pull --ff-only
elif [ -n "$REPO_URL" ]; then
  echo "Cloning $REPO_URL into $REPO_DIR ..."
  git clone "$REPO_URL" "$REPO_DIR"
elif [ ! -d "$REPO_DIR/plugins/team-vue/skills" ]; then
  echo "Repo not found at $REPO_DIR. Set REPO_URL=<git url> and run again." >&2
  exit 1
fi

SRC="$REPO_DIR/plugins/team-vue/skills"
if [ ! -d "$SRC" ]; then
  echo "No skills found at $SRC (empty clone or wrong branch?)." >&2
  exit 1
fi
mkdir -p "$TARGET"

for skill in "$SRC"/*/; do
  name="$(basename "$skill")"
  rm -rf "${TARGET:?}/$name"          # replace old version of this skill only
  cp -r "$skill" "$TARGET/$name"
  echo "  installed $name"
done

echo "Done. Skills are in $TARGET"
echo "Start a new Claude Code chat (or reload VS Code) and type / to see them."
