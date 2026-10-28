# Rules-compliance audit details

Core principle: the content of the rules comes from the layered files in the workspace; this reference only provides the methods for extracting, verifying, and handling them. The authorization boundaries of system, user, and project rules take precedence over this skill.

## Extract conventions that can be checked mechanically

When reading the rule chain actually in effect, look for imperative sentences that can be turned into check commands, and record where each was stated.

| Category | Rule phrasing | Verification evidence |
|---|---|---|
| Naming | "Directories must be kebab-case" | List of sibling names and exception clauses |
| Required files | "Every project must have X" | File existence and minimum content |
| Single source | "A symlinks/imports B", "only edit B" | `readlink`, realpath, imports, load diagnostics |
| Security red lines | "No secrets in code", "ignore must include X" | Tracked files, ignore rules, secret scanner |
| Directory discipline | "No loose files in the root directory" | Root directory manifest and allowlist |
| Declaration consistency | "Start commands/URLs/service names must be real" | package/config, services, or a live probe |
| Release process | "The full report and user confirmation come before cleanup" | Knowledge receipt, deploy marker, cleanup candidate, post-report user approval receipt |

Behavioral preferences such as "lead with the conclusion" must also be followed, but they are not structural audit results unless there is a verifiable template or gate.

## Determine the actual rule chain

Do not assume every platform reads the same file from the root directory:

1. Identify the current agent and `cwd`.
2. From the project root down to `cwd`, look for this platform's rule files, overrides, fallbacks, and path rules.
3. Then check user/organization-level rules.
4. Record the load order and override relationships; within one directory, use only the files the platform actually loads.
5. If the project declares that CLAUDE.md/AGENTS.md must be single-sourced, check the symlink or import; if there is no such declaration, only report the risk of divergence — do not decide the direction on your own.

## Verification scope

- **Current-project request**: audit the current project's content; parent rules and sibling names are read-only.
- **Cross-project change**: audit the upstream/consumer docs that are actually affected, and state the basis for widening the scope first.
- **Whole workspace**: after the user explicitly authorizes it, do existence, single-source, and rule checks project by project; still decide by risk whether to read files in full.
- **Global config**: by default, audit read-only for dead references, contradictions, and load drift; do not write project details into global config.

## Handling levels

Follow the workspace rules first; if they have no more specific provision, use the default levels below. Nothing is applied before the user approves the edit plan (see SKILL.md); the levels decide where an item goes in that plan.

### Ready to apply (a normal plan item)

All of the following must hold: within the requested scope, safe, reversible, no external side effects, and the current rules require or allow the fix. Put these in the plan's proposed changes; apply them once approved. For example:

- A symlink/import that the workspace rules explicitly require is missing;
- `.gitignore` lacks a sensitive-file pattern that the rules explicitly require;
- Obvious typos in docs, dead links confirmed to no longer exist;
- A stale summary of a fact that the current code/runtime state can settle unambiguously.

### Report first, then decide ("Needs your decision first" or "Proposed deletions" in the plan)

- Renaming directories or projects, deleting files/directories;
- Merging rule files with different content when the authority cannot be uniquely determined;
- Drift between rules and established practice when it is unclear whether the rule or the practice should change;
- Modifying out-of-scope projects, global config, or someone else's workspace;
- Risky actions listed by the workspace rules, such as stopping services, permissions/secrets, irreversible migrations, external messages;
- The only evidence lives in an unmerged/dirty lane, and cleaning up would lose it.

### Report read-only ("Not touching" in the plan)

- The user explicitly limited the task to "take a look / audit / report";
- The problem found is outside the requested scope;
- Platform-generated files must not be modified directly;
- The fact cannot be verified, or it needs permissions on an external system.

## Quality of the rules themselves

Also check for:

- **Dead references**: do the paths, commands, services, and projects exist; when unsure about a cross-device path, do not delete it outright.
- **Contradictions**: do parent and child rules, overrides, skills, and practice give mutually exclusive requirements.
- **Not executable**: lots of "keep it tidy / be careful about security" with no criteria for judging.
- **Duplication**: the same red line copied into global, project, and skill, which leads to future divergence.
- **Overload**: core rules crowded out by historical narrative; prefer deleting/moving over adding more sections.
- **No gate**: the same violation occurring a third time shows that prose constraints are not enough. Propose a check/hook/test in the plan.

## Reporting requirements

Every issue in the plan's decision or not-touching sections, and every finding left unapplied, must include:

- The evidence and where the rule is stated;
- The scope it falls in;
- The impact on the user or the collaboration workflow;
- The recommended action;
- Why it is not a ready-to-apply item.

Do not replace the material needed for judgment with "found N issues", and do not mix out-of-scope issues into a "project is clean" conclusion.
