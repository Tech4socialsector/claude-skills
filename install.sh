#!/usr/bin/env bash
# Install or update the team skills into Claude Code.
#
#   Install / update (one line, no clone needed):
#     curl -fsSL https://raw.githubusercontent.com/Tech4socialsector/claude-skills/main/install.sh | bash
#
#   Or from a clone:
#     git clone https://github.com/Tech4socialsector/claude-skills.git ~/claude-skills
#     bash ~/claude-skills/install.sh
#
#   One project only:
#     TARGET=/path/to/project/.claude/skills bash ~/claude-skills/install.sh
#
# What it does:
#   1. Gets the latest repo into ~/claude-skills (clones it the first time; later a
#      fast-forward pull that never overwrites local changes or local commits).
#   2. Copies every folder in skills/ that has a SKILL.md into TARGET (default ~/.claude/skills).
#   3. Downloads the skills listed in upstream-skills.txt into TARGET.
#   4. Removes team skills that were deleted from the repo since the last install.
#   Your own personal skills in TARGET are never touched.
#
# Options (environment variables): TARGET, REPO_DIR (default ~/claude-skills), BRANCH (main),
# SKIP_PULL=1 (install the local copy without updating it, for testing changes).
# Works on Linux, macOS, and Windows (Git Bash / WSL).
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/Tech4socialsector/claude-skills.git}"
BRANCH="${BRANCH:-main}"
TARGET="${TARGET:-$HOME/.claude/skills}"
MANIFEST="$TARGET/.team-skills-installed"

# 0. Find the repo. Run from a clone → use it. Run via curl → use/clone ~/claude-skills.
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/skills" ]; then
  REPO_DIR="$SCRIPT_DIR"
else
  REPO_DIR="${REPO_DIR:-$HOME/claude-skills}"
  if [ ! -d "$REPO_DIR/.git" ]; then
    command -v git >/dev/null 2>&1 || { echo "Error: git is required." >&2; exit 1; }
    echo "Cloning $REPO_URL into $REPO_DIR ..."
    git clone --quiet --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"
    export SKIP_PULL=1
  fi
  exec bash "$REPO_DIR/install.sh" "$@"
fi
SRC="$REPO_DIR/skills"

# 1. Update the clone (never destroys local work: fast-forward only)
if [ -d "$REPO_DIR/.git" ] && [ "${SKIP_PULL:-0}" != "1" ]; then
  if [ -n "$(git -C "$REPO_DIR" status --porcelain)" ]; then
    echo "Warning: $REPO_DIR has local changes, so it was NOT updated; installing the local copy." >&2
    echo "         To get the latest version, discard them:  git -C \"$REPO_DIR\" reset --hard origin/$BRANCH" >&2
  else
    echo "Updating $REPO_DIR from GitHub ..."
    if git -C "$REPO_DIR" fetch --quiet origin "$BRANCH"; then
      before="$(git -C "$REPO_DIR" rev-parse HEAD)"
      git -C "$REPO_DIR" checkout --quiet "$BRANCH" 2>/dev/null \
        || git -C "$REPO_DIR" checkout --quiet -b "$BRANCH" "origin/$BRANCH"
      if ! git -C "$REPO_DIR" merge --quiet --ff-only "origin/$BRANCH"; then
        echo "Warning: local commits differ from GitHub, so the clone was NOT updated; installing the local copy." >&2
      elif [ "$(git -C "$REPO_DIR" rev-parse HEAD)" != "$before" ]; then
        # The pull may have changed this script; restart with the updated one (no second pull).
        exec env SKIP_PULL=1 bash "$REPO_DIR/install.sh" "$@"
      fi
    else
      echo "Warning: could not reach GitHub (check your network connection); installing the local copy." >&2
    fi
  fi
fi

if [ ! -d "$SRC" ]; then
  echo "Error: $SRC not found." >&2
  exit 1
fi

# 2. Install the team skills from skills/
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

# 3. Install the upstream skills listed in upstream-skills.txt.
#    Line format:  <skill-name> | <owner>/<repo> | <full commit SHA> | <folder path in that repo>
#    The WHOLE folder is installed (SKILL.md + references/, scripts/, …), pinned to the commit.
#    One GitHub archive is downloaded per repo+commit. A failed download keeps any copy
#    installed earlier. A name that clashes with a team skill in skills/ is refused.
UPSTREAM_LIST="$REPO_DIR/upstream-skills.txt"
if [ -f "$UPSTREAM_LIST" ]; then
  work="$(mktemp -d)"
  trap 'rm -rf "$work"' EXIT
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"                                   # strip comments
    line="$(printf '%s' "$line" | tr -d '[:space:]')"   # fields contain no spaces
    [ -n "$line" ] || continue
    IFS='|' read -r name repo sha path extra <<< "$line"
    if [ -z "$name" ] || [ -z "$repo" ] || [ -z "$path" ] || [ -n "${extra:-}" ] \
      || ! [[ "$sha" =~ ^[0-9a-f]{40}$ ]] || ! [[ "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] \
      || ! [[ "$name" =~ ^[a-z0-9][a-z0-9-]*$ ]] || [[ "$path" == *..* ]]; then
      echo "Warning: skipped malformed line in upstream-skills.txt: $line" >&2
      continue
    fi
    if [ -d "$SRC/$name" ]; then
      echo "Warning: upstream skill '$name' clashes with a team skill in skills/; skipped." >&2
      continue
    fi
    current+=("$name")   # always listed, so step 4 never removes it after a failed download

    # Download + unpack each repo@commit once
    archive="$work/${repo//\//_}_$sha"
    if [ ! -d "$archive" ] && [ ! -f "$archive.failed" ]; then
      mkdir -p "$archive"
      if ! { command -v curl >/dev/null 2>&1 && command -v tar >/dev/null 2>&1 \
        && curl -fsSL --connect-timeout 10 --max-time 120 --retry 2 \
             "https://codeload.github.com/$repo/tar.gz/$sha" \
           | tar -xzf - --strip-components=1 -C "$archive"; }; then
        rm -rf "$archive"; touch "$archive.failed"
      fi
    fi

    src="$archive/${path%/}"
    if [ -d "$src" ] && [ "$(head -n 1 "$src/SKILL.md" 2>/dev/null)" = "---" ]; then
      rm -rf "${TARGET:?}/$name"
      cp -R "$src" "$TARGET/$name"
      echo "  installed  $name (upstream $repo@${sha:0:7})"
    elif [ -f "$TARGET/$name/SKILL.md" ]; then
      echo "Warning: could not download $name from $repo (needs curl, tar and network); kept the copy installed earlier." >&2
    else
      echo "Warning: could not download $name from $repo (needs curl, tar and network); skipped. Run the installer again later." >&2
    fi
  done < "$UPSTREAM_LIST"
fi

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

version="$(grep -m1 '"version"' "$REPO_DIR/.claude-plugin/plugin.json" 2>/dev/null | sed 's/[^0-9.]//g')"
echo "Done: team skills v${version:-?} installed in $TARGET"
echo "Next: reload VS Code (Ctrl+Shift+P > Developer: Reload Window) or start a new Claude Code session."
