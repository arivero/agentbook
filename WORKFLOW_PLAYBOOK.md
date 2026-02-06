# Agentic Workflow Playbook for Agentbook

This playbook defines the active GH-AW issue-management lifecycle used in this repository.

## Canonical Issue Lifecycle

```
[opened] -> acknowledged -> triaged-fast-track -> assigned -> closed
                         \-> triaged-for-research -> researched-waiting-opinions
                             -> opinion-copilot-strategy-posted + opinion-copilot-delivery-posted -> assigned -> closed
```

At any stage, any agent may reject by explaining the reason, adding `rejected`, and closing the issue.

## Active workflow matrix

| Stage | Trigger | Workflow file | Labels in | Labels out | Result |
|---|---|---|---|---|---|
| Intake + triage | `issues.opened` | `.github/workflows/issue-intake-triage.lock.yml` | _(none)_ | `acknowledged` + route label | Issue acknowledged and routed |
| Fast-track delivery | `issues.labeled` | `.github/workflows/issue-fast-track-close.lock.yml` | `triaged-fast-track` | `assigned` _(or `rejected`)_ | PR opened and issue closed |
| Research pass | `issues.labeled` | `.github/workflows/issue-research-pass.lock.yml` | `triaged-for-research` | `researched-waiting-opinions` | Research comment posted |
| Opinion A (Copilot strategy model) | `issues.labeled` | `.github/workflows/issue-opinion-copilot-strategy.lock.yml` | `researched-waiting-opinions` | `opinion-copilot-strategy-posted` | Copilot strategy perspective comment posted |
| Opinion B (Copilot delivery model) | `issues.labeled` | `.github/workflows/issue-opinion-copilot-delivery.lock.yml` | `researched-waiting-opinions` | `opinion-copilot-delivery-posted` | Copilot delivery perspective comment posted |
| Assignment + close | `issues.labeled` | `.github/workflows/issue-assignment-close.lock.yml` | `opinion-copilot-strategy-posted` or `opinion-copilot-delivery-posted` | `assigned` | Closes only when both opinion labels exist |

## Routing rules

- Use `triaged-fast-track` for small, low-risk, clearly scoped changes.
- Use `triaged-for-research` for broad, unclear, or high-impact requests.
- External broken-link issues are generally expected to route to `triaged-fast-track`.

## Source of truth and compilation rule

Workflow source files are maintained in `.github/workflows/*.md` and must be compiled to `.lock.yml` with `gh aw` commands.

When a workflow source file changes:
1. Re-compile to the matching `.lock.yml`.
2. Commit source and lock file together.
3. Keep this matrix updated in the same PR.
