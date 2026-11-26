#!/usr/bin/env bash
# Install or update the team skills into Claude Code.
#
#   First time:   git clone https://github.com/Tech4socialsector/claude-skills.git ~/claude-skills
#                 bash ~/claude-skills/install.sh
#   Update:       bash ~/claude-skills/install.sh
#   One project:  TARGET=/path/to/project/.claude/skills bash ~/claude-skills/install.sh
#
# The repo is public, so no GitHub login is needed to clone, update or install.
#
# What it does:
#   1. Pulls the latest version of this repo (fast-forward only; if the clone has local
#      changes or local commits it is left alone and the local copy is installed).
#   2. Copies every skill in plugins/team-vue/skills/ into TARGET (default ~/.claude/skills).
#   3. Downloads the upstream skills listed in UPSTREAM_SKILLS (pinned to a commit) into TARGET.
#   4. Removes team skills that were deleted from the repo since the last install.
#   Your own personal skills in TARGET are never touched.
#
# Works on Linux, macOS, and Windows (Git Bash / WSL).
set -euo pipefail

BRANCH="${BRANCH:-main}"
TARGET="${TARGET:-$HOME/.claude/skills}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/plugins/team-vue/skills"
MANIFEST="$TARGET/.team-skills-installed"

# Upstream skills downloaded at install time instead of being copied into this repo
# (the upstream repo has no license, so we don't republish its files).
# Format: "name|raw URL of SKILL.md pinned to a commit". To update, change the commit in the URL.
UPSTREAM_SKILLS=(
  "frappe-app-dev|https://raw.githubusercontent.com/frappe/skills/d213dce39942c969293e9fe7feb96ab33cbba25c/skills/frappe-app-dev/SKILL.md"
)

if [ ! -d "$SRC" ]; then
  echo "Error: $SRC not found. Run this script from inside the claude-skills clone." >&2
  exit 1
fi

# 1. Update the clone (never destroys local work: fast-forward only)
if [ -d "$REPO_DIR/.git" ] && [ "${SKIP_PULL:-0}" != "1" ]; then
  if [ -n "$(git -C "$REPO_DIR" status --porcelain)" ]; then
    echo "Warning: $REPO_DIR has local changes, so it was NOT updated; installing the local copy." >&2
    echo "         To get the latest version, discard them:  git -C \"$REPO_DIR\" reset --hard origin/$BRANCH" >&2
  else
    echo "Updating $REPO_DIR from GitHub ..."
    if git -C "$REPO_DIR" fetch --quiet origin "$BRANCH"; then
      git -C "$REPO_DIR" checkout --quiet "$BRANCH" 2>/dev/null \
        || git -C "$REPO_DIR" checkout --quiet -b "$BRANCH" "origin/$BRANCH"
      if ! git -C "$REPO_DIR" merge --quiet --ff-only "origin/$BRANCH"; then
        echo "Warning: local commits differ from GitHub, so the clone was NOT updated; installing the local copy." >&2
      fi
    else
      echo "Warning: could not reach GitHub (check your network connection); installing the local copy." >&2
    fi
  fi
fi

# 2. Install the team skills from this repo
mkdir -p "$TARGET"
current=()
for skill in "$SRC"/*/; do
  [ -f "$skill/SKILL.md" ] || continue
  name="$(basename "$skill")"
  current+=("$name")
  rm -rf "${TARGET:?}/$name"
  cp -R "${skill%/}" "$TARGET/$name"
  echo "  installed  $name"
done

if [ "${#current[@]}" -eq 0 ]; then
  echo "Error: no skills (folders with SKILL.md) found in $SRC" >&2
  exit 1
fi

# 3. Download the upstream skills (a failed download keeps any copy installed earlier)
for entry in "${UPSTREAM_SKILLS[@]}"; do
  name="${entry%%|*}"
  url="${entry#*|}"
  current+=("$name")   # always listed, so step 4 never removes it after a failed download
  tmp="$(mktemp -d)"
  if command -v curl >/dev/null 2>&1 \
    && curl -fsSL --retry 2 "$url" -o "$tmp/SKILL.md" \
    && [ "$(head -n 1 "$tmp/SKILL.md")" = "---" ]; then
    rm -rf "${TARGET:?}/$name"
    mkdir -p "$TARGET/$name"
    cp "$tmp/SKILL.md" "$TARGET/$name/SKILL.md"
    echo "  installed  $name (downloaded from upstream)"
  elif [ -f "$TARGET/$name/SKILL.md" ]; then
    echo "Warning: could not download $name (needs curl and network); kept the copy installed earlier." >&2
  else
    echo "Warning: could not download $name (needs curl and network); skipped. Run the installer again later." >&2
  fi
  rm -rf "$tmp"
done

# 4. Remove team skills that no longer exist in the repo
if [ -f "$MANIFEST" ]; then
  while IFS= read -r old; do
    [ -n "$old" ] || continue
    keep=0
    for n in "${current[@]}"; do [ "$n" = "$old" ] && keep=1 && break; done
    if [ "$keep" = 0 ] && [ -d "$TARGET/$old" ]; then
      rm -rf "${TARGET:?}/$old"
      echo "  removed    $old (deleted from the repo)"
    fi
  done < "$MANIFEST"
fi
printf '%s\n' "${current[@]}" > "$MANIFEST"

version="$(grep -m1 '"version"' "$REPO_DIR/plugins/team-vue/.claude-plugin/plugin.json" | sed 's/[^0-9.]//g')"
echo "Done: team skills v${version:-?} installed in $TARGET"
echo "Next: reload VS Code (Ctrl+Shift+P > Developer: Reload Window) or start a new Claude Code session."
