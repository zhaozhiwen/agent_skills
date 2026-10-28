# agent_skills

Agent skills authored or adapted by Zhiwen Zhao, in the open [Agent Skills](https://agentskills.io) format (`SKILL.md` + optional `scripts/`, `references/`, `assets/`). They work with any compliant agent — Claude Code, Codex, Gemini CLI, GitHub Copilot, Cursor, OpenCode, and [others](https://agentskills.io/clients).

## Skills

| Skill | What it does | Origin |
|---|---|---|
| [neat-freak](skills/neat-freak/SKILL.md) | Project closeout: reconcile docs, CLAUDE.md/AGENTS.md rules, agent memory, and workspace residue with what the code actually does. Proposes an edit plan and changes only what you approve. Triggers on "neat-freak", "/neat". | English translation of Khazix's neat-freak v3.0.0 ([credits](#credits)) |

## Install

### Default: clone + symlink

```bash
git clone https://github.com/zhaozhiwen/agent_skills.git
bash agent_skills/install.sh
```

This links every skill into both

- `~/.agents/skills/<name>` — the cross-client convention (Codex, Gemini CLI, Copilot, Cursor, OpenCode, ...)
- `~/.claude/skills/<name>` — Claude Code

Both links point at the same folder in the clone, so one `git pull` updates every agent, and edits to `skills/<name>/` are live immediately. Rerun `install.sh` after new skills are added. It never deletes: if a real directory is already at a target, it skips it with a warning — move it away and rerun. To link into other dirs instead: `bash agent_skills/install.sh /path/to/skills ...`.

### Alternatives (no clone; update with `gh skill update` / `npx skills update`)

**GitHub CLI** (`gh skill`, preview) — choose your agent with `--agent`:

```bash
gh skill install zhaozhiwen/agent_skills neat-freak --agent codex --scope user
gh skill install zhaozhiwen/agent_skills --all --agent claude-code --scope user
```

**skills CLI** (Node):

```bash
npx skills add zhaozhiwen/agent_skills -g
```

**Manual:** copy `skills/<name>/` into your agent's skills directory — `~/.agents/skills/` is the cross-client convention; Claude Code uses `~/.claude/skills/`.

## Contributing a skill

See [AGENTS.md](AGENTS.md) for the layout and rules; `python3 scripts/validate.py` checks every skill against the [spec](https://agentskills.io/specification).

## Credits

**neat-freak** is an English translation of the neat-freak skill (v3.0.0) by Khazix (数字生命卡兹克),
from [KKKKhazix/khazix-skills](https://github.com/KKKKhazix/khazix-skills/tree/2b4a645cfdc894156ae347d897723562f719ce95/neat-freak)
at commit `2b4a645` (2026-07-20), MIT-licensed. The original copyright notice is kept in
[skills/neat-freak/LICENSE](skills/neat-freak/LICENSE). Differences from upstream:

- **Translation**: `SKILL.md` and `references/` are fully translated. The Chinese trigger words were dropped, so it
  triggers on English requests only. In a side-by-side eval (2026-10-25: 11 scenarios, plus 21 trigger prompts) the
  English and the original Chinese version scored the same: 63/74 behavior checks, 20/21 trigger cases.
- **Evals removed**: upstream's `evals/` (test scenarios, fixtures, structural validator) is not included.
- **Fix — release closeout order**: upstream `SKILL.md` said to finish the knowledge closeout before deployment, while
  `references/verification.md` put it after live verification. Both now say: sync knowledge right after merge with the
  runtime surface `pending`; close the knowledge receipt only after live verification; clean up only after that.
- **Fix — `scripts/audit-inventory.sh`**: added `--stop-at <dir>` so it can stay inside a workspace boundary (it
  always walked up to `/` and read `$HOME`); fixed a crash on unreadable directories, a crash when `HOME` is unset,
  `head=HEAD` on repos with no commits (now `head=none`), symlinked Markdown files being hidden, and `$CODEX_HOME`
  being ignored. `SKILL.md` now calls it by the skill's path rather than the project's.
- **Fix — Codex skill paths**: `references/agent-paths.md` said Codex reads skills from `$CODEX_HOME/skills` and
  `.codex/skills`; current Codex docs list `~/.agents/skills`, repo `.agents/skills`, and `/etc/codex/skills`.
- **Plan-first**: upstream applied safe fixes directly and asked only before deletions. This version audits
  read-only, presents a numbered edit plan, stops, and applies only the items the user approves (unless the request
  explicitly says to apply without review; deletions and renames always need approval). `references/governance.md`
  and `references/sync-matrix.md` now sort findings into plan sections instead of "fix directly".

## License

MIT — see [LICENSE](LICENSE). Each skill also declares `license: MIT` in its frontmatter; adapted skills carry their upstream LICENSE in their own folder.
