# agent_skills — rules

Public repo (github.com/zhaozhiwen/agent_skills) collecting agent skills authored or adapted by Zhiwen Zhao,
in the open [Agent Skills](https://agentskills.io/specification) format — usable by any compliant
agent (Claude Code, Codex, Gemini CLI, Copilot, Cursor, OpenCode, ...), not tied to one client.

This file is the canonical rules file; `CLAUDE.md` only imports it (`@AGENTS.md`) for Claude Code.

This repo is the **source of truth**. The default install is `bash install.sh`, which symlinks
each skill into both `~/.agents/skills/` (cross-client convention) and `~/.claude/skills/`
(Claude Code). Never keep real copies in those dirs — edit here; the links make it live.

## Layout

```
skills/<name>/SKILL.md        required; the `skills/*/SKILL.md` path is what installers discover
skills/<name>/scripts/        optional: executable code
skills/<name>/references/     optional: docs loaded on demand
skills/<name>/assets/         optional: templates, data, images
skills/<name>/evals/          optional: evals.json + fixtures (agentskills.io eval convention)
scripts/validate.py           checks every skill against the spec
install.sh                    default install: symlinks every skills/*/ into ~/.agents/skills + ~/.claude/skills
README.md                     one row per skill
LICENSE                       MIT
```

Nothing else at the top level without a reason recorded here.

## Skill rules (Agent Skills spec)

- `name`: 1–64 chars, `[a-z0-9-]`, no leading/trailing/double hyphen, **equal to the dir name**.
- `description`: ≤1024 chars; say what it does *and* when to use it, with trigger keywords.
- Frontmatter: only spec fields — `name`, `description`, `license`, `compatibility` (≤500),
  `metadata` (string→string), `allowed-tools` (experimental). Every skill sets
  `license: MIT` and `metadata.author`, because installers copy only the skill folder and
  the repo LICENSE does not travel with it.
- Third-party skills (adapted, translated, or vendored): `metadata.author` is the original
  author, `metadata.upstream` is a URL pinned to the source commit, our role goes in
  `metadata.translator`/`metadata.maintainer`, and `skills/<name>/LICENSE` keeps the
  upstream copyright notice verbatim. Record the origin in README.md's Credits section.
  Only MIT-compatible upstreams.
- Client-specific extras (e.g. Claude `disable-model-invocation`, Codex `agents/openai.yaml`)
  only if the skill still works on clients that ignore them.
- `SKILL.md` body < 500 lines / ~5000 tokens; push detail into `references/`, one level deep.
- Relative paths from the skill root only; no absolute paths, no assumption of a specific
  agent's tools (say "read the file", not a tool name).
- Scripts: non-interactive, `--help`, errors to stderr, declare dependencies
  (PEP 723 for Python) or state them in `compatibility`.

## Adding / changing a skill

1. Create or edit `skills/<name>/` (edit in place — the symlinks make it live immediately).
2. `python3 scripts/validate.py` must pass.
3. Add/update its row in `README.md`.
4. Run `bash install.sh` for new skills (creates both links; existing links are refreshed).

## Never commit

- Secrets, tokens, passwords, real emails, or absolute paths to private data.
- `~/.claude/skills/synced/*` — those are Anthropic-synced skills, not ours.
- Caches (`__pycache__`, `.DS_Store`) and eval run outputs (`<name>-workspace/`).

Anything committed here is public. Scan new files before committing:
`grep -rniE 'token|secret|password|api[_-]?key|/home/' skills/`

## Git

Commit and push only with explicit approval, each time. Tag releases (`vX.Y.Z`):
`gh skill install` uses the latest tag.
