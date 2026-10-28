#!/usr/bin/env bash
# Read-only inventory for neat-freak. Prints metadata and paths only; never reads file contents.
#
# usage: audit-inventory.sh [--stop-at <dir>] <project-root>
#   --stop-at <dir>  Workspace boundary (the project root or an ancestor of it). The rule-chain
#                    walk stops at <dir>, git discovery does not look above it, and home-level
#                    paths are checked only if they are inside it. Without it, the walk goes
#                    up to / and home-level agent dirs and rule files are checked.
# exit codes: 0 ok, 64 bad usage, 66 project root not a directory

set -euo pipefail

usage() {
  echo "usage: $0 [--stop-at <dir>] <project-root>" >&2
  exit 64
}

STOP_AT=""
if [[ "${1:-}" == "--stop-at" ]]; then
  [[ $# -ge 2 ]] || usage
  STOP_AT="$2"
  shift 2
fi
[[ $# -eq 1 ]] || usage
[[ -d "$1" ]] || { echo "[ERR] project root is not a directory: $1" >&2; exit 66; }

PROJECT_ROOT="$(cd "$1" && pwd -P)"
if [[ -n "$STOP_AT" ]]; then
  [[ -d "$STOP_AT" ]] || { echo "[ERR] --stop-at is not a directory: $STOP_AT" >&2; exit 64; }
  STOP_AT="$(cd "$STOP_AT" && pwd -P)"
  case "$PROJECT_ROOT/" in
    "$STOP_AT"/*|"$STOP_AT/") ;;
    *) echo "[ERR] --stop-at must be the project root or an ancestor of it: $STOP_AT" >&2; exit 64 ;;
  esac
  # Keep git from discovering a repository above the boundary.
  [[ "$STOP_AT" != "/" ]] && export GIT_CEILING_DIRECTORIES="$(dirname "$STOP_AT")"
fi

HOME_DIR="${HOME:-}"
CODEX_DIR="${CODEX_HOME:-${HOME_DIR:+$HOME_DIR/.codex}}"
SEEN_RULE_FILES=$'\n'

# True if the path may be inspected under the current boundary.
in_bounds() {
  [[ -n "$1" ]] || return 1
  [[ -z "$STOP_AT" ]] && return 0
  case "$1/" in "$STOP_AT"/*) return 0 ;; esac
  return 1
}

section() {
  printf '\n## %s\n' "$1"
}

file_size() {
  local file="$1"
  local lines bytes
  lines="$(wc -l < "$file" | tr -d ' ')"
  bytes="$(wc -c < "$file" | tr -d ' ')"
  printf '%s\tlines=%s\tbytes=%s\n' "$file" "$lines" "$bytes"
}

describe_file() {
  local file="$1"
  if [[ -L "$file" ]]; then
    local target state
    target="$(readlink "$file")"
    if [[ -e "$file" ]]; then state="valid"; else state="broken"; fi
    printf '%s\tsymlink=%s\tstate=%s\n' "$file" "$target" "$state"
  elif [[ -f "$file" ]]; then
    file_size "$file"
  fi
}

describe_rule_file() {
  local file="$1"
  case "$SEEN_RULE_FILES" in
    *$'\n'"$file"$'\n'*) return ;;
  esac
  SEEN_RULE_FILES+="$file"$'\n'
  describe_file "$file"
}

# Markdown files (regular or symlinked) under the project, skipping dependency/build dirs.
# Unreadable directories are reported on stderr instead of aborting the inventory.
project_markdown() {
  find "$PROJECT_ROOT" \
    \( -name .git -o -name node_modules -o -name .next -o -name dist -o -name build -o -name .venv -o -name venv -o -name __pycache__ -o -name target -o -name vendor -o -name .turbo -o -name .cache \) -prune \
    -o \( -type f -o -type l \) \( -name '*.md' -o -name '*.mdx' \) -print 2>/dev/null \
    | LC_ALL=C sort || echo "[WARN] some directories could not be read" >&2
}

printf '# neat-freak inventory v3\n'
printf 'project_root=%s\n' "$PROJECT_ROOT"
printf 'stop_at=%s\n' "${STOP_AT:-/}"
printf 'generated_at=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

section "platform-directories"
# Common agent home dirs; nonexistent or out-of-bounds ones are skipped silently.
if [[ -n "$HOME_DIR" ]]; then
  for dir in "$HOME_DIR/.claude" "$CODEX_DIR" "$HOME_DIR/.agents" "$HOME_DIR/.cursor" "$HOME_DIR/.gemini" \
    "$HOME_DIR/.qoder" "$HOME_DIR/.trae" "$HOME_DIR/.iflow" "$HOME_DIR/.codebuddy"; do
    in_bounds "$dir" && [[ -d "$dir" ]] && printf '%s\n' "$dir"
  done
fi
true

section "other-agent-rule-artifacts"
# Platform-specific rule forms at the project root (existence only).
for rel in .cursorrules .windsurfrules .cursor/rules .claude/rules .windsurf/rules .github/copilot-instructions.md GEMINI.md .qoder .trae .iflow; do
  [[ -e "$PROJECT_ROOT/$rel" ]] && printf '%s\n' "$PROJECT_ROOT/$rel"
done
true

section "git"
if git -C "$PROJECT_ROOT" rev-parse --show-toplevel >/dev/null 2>&1; then
  printf 'git_root=%s\n' "$(git -C "$PROJECT_ROOT" rev-parse --show-toplevel)"
  printf 'branch=%s\n' "$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || true)"
  printf 'head=%s\n' "$(git -C "$PROJECT_ROOT" rev-parse --verify -q HEAD || echo none)"
  printf 'status_entries=%s\n' "$(git -C "$PROJECT_ROOT" status --porcelain=v1 2>/dev/null | wc -l | tr -d ' ')"
  printf 'worktrees=%s\n' "$(git -C "$PROJECT_ROOT" worktree list --porcelain 2>/dev/null | awk '$1 == "worktree" {n++} END {print n+0}')"
else
  printf 'git_root=none\n'
fi

section "rule-chain-candidates"
cursor="$PROJECT_ROOT"
while :; do
  for rel in AGENTS.override.md AGENTS.md CLAUDE.md CLAUDE.local.md .claude/CLAUDE.md GEMINI.md; do
    describe_rule_file "$cursor/$rel"
  done
  [[ "$cursor" == "/" || "$cursor" == "$STOP_AT" ]] && break
  parent="$(dirname "$cursor")"
  [[ "$parent" == "$cursor" ]] && break
  cursor="$parent"
done
for file in \
  "${CODEX_DIR:+$CODEX_DIR/AGENTS.override.md}" \
  "${CODEX_DIR:+$CODEX_DIR/AGENTS.md}" \
  "${HOME_DIR:+$HOME_DIR/.claude/CLAUDE.md}"; do
  in_bounds "$file" && describe_rule_file "$file"
done
true

section "project-markdown"
project_markdown | while IFS= read -r file; do describe_file "$file"; done

section "project-markdown-count"
project_markdown | awk 'END {print NR+0}'

section "root-entries"
find "$PROJECT_ROOT" -mindepth 1 -maxdepth 1 -print | LC_ALL=C sort
