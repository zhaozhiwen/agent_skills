#!/usr/bin/env bash
# Default install: symlink every skills/<name>/ into both agent skill dirs below,
# so one repo copy serves every agent. Idempotent; never deletes.
# Usage: bash install.sh            # ~/.agents/skills (Codex, Gemini CLI, Copilot, Cursor, OpenCode, ...)
#                                   # + ~/.claude/skills (Claude Code)
#        bash install.sh DIR ...    # link into these dirs instead
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
if [[ $# -gt 0 ]]; then
  dests=("$@")
else
  dests=("$HOME/.agents/skills" "$HOME/.claude/skills")
fi

for dest in "${dests[@]}"; do
  mkdir -p "$dest"
  for src in "$repo"/skills/*/; do
    src="${src%/}"
    name="$(basename "$src")"
    target="$dest/$name"
    if [[ -L "$target" ]]; then
      ln -sfn "$src" "$target"
      echo "linked   $target"
    elif [[ -e "$target" ]]; then
      echo "SKIPPED  $target is a real directory/file; move it away, then rerun" >&2
    else
      ln -s "$src" "$target"
      echo "linked   $target"
    fi
  done
done
