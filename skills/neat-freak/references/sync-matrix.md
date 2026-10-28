# Change-impact matrix

The matrix is for routing, not for forcing fixed file names. First identify the project's existing architecture, integration, operations, decision, and release docs, then bring each corresponding audience up to date.

## Which noise to remove first

| Anti-pattern | Default handling |
|---|---|
| "X went live on some date, see Y" stuffed at the top of the main rules | Merge current constraints in place; move pure history to git/changelog/incident docs |
| The main rules copy the full architecture, scoring formula, or data flow | Keep the boundaries and a pointer to the authoritative doc; detailed mechanisms go back to docs |
| Several versions all claim to be "current" | Settle it by code switches, runtime state, and the fallback chain; explicitly mark historical versions as fallback/retired |
| Completed to-dos still listed as open items | After verifying, delete them or turn them into current constraints; do not keep a "done" running log |
| A long write-up of a one-off incident permanently in memory | Distill the reusable lesson; the mechanism goes into docs, the process into incident docs/git |
| The same rule copied in several places | Keep one authoritative canonical copy; elsewhere use short pointers or delete |
| "Kept for history" but with no real reader or use | Delete; history needs a use, an authoritative location, and a way to find it |
| Agent session residue: one-off planning docs, debug scripts, `xxx_old`/`xxx_backup` copies | Merge valid content into the proper docs; list the files as deletion candidates, and remove them only after user confirmation |

## Code or runtime changes → knowledge surfaces

| Change | Audience surfaces to check |
|---|---|
| API / route / protocol | External integration contract, architecture routes, auth, examples, consumer docs, smoke tests |
| Environment variable / provider / model | Example env, runbook, authoritative defaults, downstream config, cost/fallback notes |
| Schema / storage fields | Data model, migration and rollback, derived data/caches, read/write boundaries, tests |
| User flow / permissions / navigation | README/product description, architecture permissions, operations manual, visual acceptance |
| Scoring / filtering / clustering / prompt | Current algorithm docs, thresholds/switches, backtest evidence, fallback chain, display impact |
| Service / deployment / CDN / edge | Runbook, service names, marker, cache, rollback, live acceptance |
| Background jobs / alerts | Job docs, scheduling, failure handling, alert routing, decision surface |
| Retirement / rename / takedown | Search for non-historical references to the old symbol in consumers, rules, skills, and memory; keep clearly labeled historical evidence |
| Release process / multi-agent lifecycle | SOP, merge/deploy scripts, knowledge receipt, cleanup gate, workspace audit |

## Audience responsibilities

When a capability is added or changed, decide at least whether each of four responsibilities exists; this does not require creating four fixed files:

1. **How to use it**: README, API/integration guide, examples.
2. **How it works**: architecture, schema, state machine, design boundaries.
3. **How to operate it**: runbook, environment variables, smoke tests, rollback, alerts.
4. **Current status/history**: product changelog, release notes, incident docs, or git; write a changelog only when the project rules or the user explicitly require it.

If one doc carries several responsibilities, update it in place; do not split files just for form's sake.

## Memory routing

| Memory type | Handling |
|---|---|
| User preferences / repeated corrections | Keep short, actionable entries where the platform allows it and the user authorizes it |
| System mechanisms | Graduate into authoritative docs; memory keeps only a lookup pointer |
| Decision events | Keep only the final conclusion and the still-valid why; the process belongs in git/changelog |
| Completed open items | Delete after verifying; do not let them keep posing as plans |
| Relative time | Change current status to absolute dates; do not mechanically replace natural language in historical narrative |
| Duplicates or conflicts | Settle by the current code/runtime state; if it cannot be settled, keep the conflict and mark it pending |
| Machine-generated indexes | Do not edit directly; write the specified input or candidates and hand them to the generation process |
| Long unreferenced | Judge by authority and reuse value; being unreferenced is not on its own a reason to delete |

## Rule violations → actions

| Finding | Action |
|---|---|
| The workspace rules require a single source, but the symlink/import is missing | Propose adding it; after approval, verify realpath/load |
| Two independent rule files with different content | Propose a merge if the workspace's declaration settles it unambiguously; otherwise it is a pending decision |
| Runnable code but no project rules | By default propose a minimal rule file (five elements, lean); if the workspace has a template, follow it |
| ignore lacks a security red line | Propose adding it, and check for tracked secrets |
| Naming violations, clutter in the root directory | Report the impact read-only; moving/renaming/deleting is usually a pending decision |
| Rules reference retired paths/commands | Propose clearing them when the current machine confirms it unambiguously and there is no cross-device doubt; otherwise report |
| The same violation keeps recurring | Propose fixing it at the root with a check/hook/test |

## Cross-project checks

If any of the following is true, search for the actual consumers instead of only changing the current project:

- A shared API, SDK, domain, auth, schema, or environment variable changed;
- The deployment/edge layer changed behavior visible downstream;
- A shared skill, script, or template is referenced by several projects;
- The current project's docs explicitly list dependents.

Discovering a consumer read-only does not mean you are allowed to edit it. First state the dependency evidence and the impact, then act according to the task and workspace rules.
