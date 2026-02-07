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
| Intake ACK | `issues.opened` | `.github/workflows/issue-intake-ack.yml` | _(none)_ | `acknowledged` | Issue acknowledged and routed to agentic triage |
| Routing decision | `workflow_dispatch` (from intake ACK) | `.github/workflows/issue-routing-decision.lock.yml` | `acknowledged` | `triaged-fast-track` or `triaged-for-research` | Agentic routing decision posted |
| Fast-track delivery | `issues.labeled` | `.github/workflows/issue-fast-track-close.lock.yml` | `triaged-fast-track` | `assigned` _(or `rejected`)_ | PR opened and issue closed |
| Research pass | `issues.labeled` (`triaged-for-research` or `allow-internet-research`) | `.github/workflows/issue-research-pass.lock.yml` | `triaged-for-research` | `researched-waiting-opinions` | Research comment posted |
| Opinion A (Copilot strategy model) | `issues.labeled` | `.github/workflows/issue-opinion-copilot-strategy.lock.yml` | `researched-waiting-opinions` | `opinion-copilot-strategy-posted` | Copilot strategy perspective comment posted |
| Opinion B (Copilot delivery model) | `issues.labeled` | `.github/workflows/issue-opinion-copilot-delivery.lock.yml` | `researched-waiting-opinions` | `opinion-copilot-delivery-posted` | Copilot delivery perspective comment posted |
| Assignment + close | `issues.labeled` | `.github/workflows/issue-assignment-close.lock.yml` | `opinion-copilot-strategy-posted` or `opinion-copilot-delivery-posted` | `assigned` | Closes only when both opinion labels exist |

Label-triggered downstream workflows require a user token so safe-outputs label writes can emit workflow-triggering events. Configure `GH_AW_GITHUB_TOKEN` as a fine-grained PAT restricted to this repository with `Issues`, `Pull requests`, and `Contents` set to `Read and write`.

Internet research policy:
- External web tools in the research pass are enabled only when the issue has `allow-internet-research`.
- Without that label, research should stay GitHub-only.

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
