# Evidence tiers and release end states

## Risk determines evidence depth

| Conclusion | Minimum evidence |
|---|---|
| "Doc links are valid" | The project's own doc-link/index check, or a per-link existence check |
| "Rules are single-sourced" | realpath/readlink/import + the platform's actual load order |
| "The code implements X" | Code, schema, config, and relevant tests on the current target branch |
| "The PR is done" | PR state=merged + merge commit; this does not imply deployed |
| "Deployed" | Deploy marker/release points at the target commit + the service is active |
| "Users see the new version" | The real response from the canonical user URL/API, comparing origin/cache as well when necessary |
| "Safe to clean up" | merged + production contains the change + knowledge receipt + lane clean + no unique unintegrated files |
| "Cleanup approved" | The full results have been reported to the user + the user explicitly confirmed the cleanup after that report + the confirmation receipt the workspace rules require |
| "The whole project is clean" | Every applicable fact surface in the project is verified; warnings, pending, and out-of-scope items are listed separately |

Code intuition, old memory, commit messages, and cache-buster URLs are only leads; none of them alone can prove the production end state.

## Truth matrix

For each finding, record at least:

```text
topic: <fact topic>
authority: <current authoritative source>
code: verified-current | stale | n/a
runtime: verified-current | stale | unverified | n/a
docs: verified-current | stale | changed
rules: verified-current | stale | changed | n/a
memory: verified-current | stale | generated-read-only | changed | n/a
action: <what was done, or why it was not>
verification: <command, page, or gate>
```

The user does not need to see the full matrix, but the final summary must keep the states that are not closed.

## Release state machine

```text
implemented
  -> locally verified
  -> pushed / PR opened
  -> CI + required backtest/visual review passed
  -> merged
  -> knowledge synced (runtime surface: pending)
  -> deployed
  -> live verified
  -> knowledge closed + receipt recorded (runtime surface: verified-current)
  -> full result reported while evidence is preserved
  -> user explicitly approved cleanup after the report
  -> workspace cleaned
  -> post-cleanup audit passed
  -> cleanup result appended
```

Knowledge sync needs only the merged code, so it does not wait for deployment: update docs/rules/memory right after merge and record the runtime surface as `pending`. Closing the knowledge receipt needs live verification, because the receipt states what users actually get.

Any skipped state must have a reason that the project rules allow. Wherever a failure stops, report at that state; do not cover it with "basically done".

## Caches and multi-surface products

When user-visible content passes through a CDN, edge cache, search index, async worker, or multiple clients, identify at least:

- Whether the origin has the new content;
- Whether the canonical URL is still serving an old cache;
- Whether the API/pages/notifications/RSS share the same data outlet;
- Whether the deploy marker is written only after all async processes have actually switched over;
- Whether a cache-buster is only a diagnostic rather than real user acceptance.

When only one of these surfaces is verified, state that limit on scope explicitly in the conclusion.

## Gate before cleanup

Cleanup destroys the evidence for the retrospective and for the user's review, so the order is fixed:

1. Verify the target work is integrated and live;
2. Sync docs/rules/authorized memory, as approved in the edit plan (if they were already synced right after merge, update the runtime surface to the live result);
3. Record the knowledge closeout receipt the project requires;
4. Preview the worktrees/branches/dbs/artifacts to be deleted;
5. Check dirty files and patch equivalence;
6. Give the user the full report of the results and keep the state above intact;
7. Wait for the user, after reading the report, to explicitly confirm the cleanup;
8. Record the user-confirmation receipt the project requires and perform the authorized cleanup;
9. Rerun the workspace audit, and add a report of the cleanup results.

Pre-authorization in the user's original task, such as "wrap up and clean up" or "delete it when done", does not replace step 7; the confirmation must happen after the full report, because the user has to see the results before judging whether the state needs to be kept for further review.

Directory names, branch age, and whether the agent session is closed cannot prove that something is safe to delete.

## When verification fails

- When the same failure occurs a second time, stop retrying blindly and re-check your assumptions, the environment, and command names.
- When a gate requires machine-readable metadata, add the correct record and trigger a new event; do not use manual confirmation to bypass a fixable format problem.
- If the failure happened before any production write, say clearly "production not yet affected"; if it happened after traffic was switched, first confirm the current active release and the rollback boundary.
- Keep every unverified item `pending`; do not downgrade it to a warning to make the summary look better.
