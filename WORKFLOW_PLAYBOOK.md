# Agentic Workflow Playbook for Agentbook

This playbook defines the active GH-AW issue-management lifecycle used in this repository.

## Canonical Issue Lifecycle

```
[opened] -> acknowledged -> triaged-fast-track -> assigned -> closed
                         \-> triaged-for-research -> researched-waiting-opinions
                             -> phase-1-complete -> phase-2-complete -> assigned -> closed
```

At any stage, any agent may reject by explaining the reason, adding `rejected`, and closing the issue.

## Active workflow matrix

| Stage | Trigger | Workflow file | Labels in | Labels out | Result |
|---|---|---|---|---|---|
| Intake ACK | `issues.opened` | `.github/workflows/issue-intake-ack.yml` | _(none)_ | `acknowledged` | Issue acknowledged and routed to agentic triage |
| Routing decision | `workflow_dispatch` (from intake ACK) | `.github/workflows/issue-routing-decision.lock.yml` | `acknowledged` | `triaged-fast-track` or `triaged-for-research` | Agentic routing decision posted |
| Fast-track delivery | `issues.labeled` | `.github/workflows/issue-fast-track-close.lock.yml` | `triaged-fast-track` | `assigned` _(or `rejected`)_ | PR opened and issue closed |
| Research pass | `issues.labeled` (`triaged-for-research` or `allow-internet-research`) | `.github/workflows/issue-research-pass.lock.yml` | `triaged-for-research` | `researched-waiting-opinions` | Research comment posted |
| Phase 1 dispatcher | `issues.labeled` | `.github/workflows/issue-phase1-dispatch.yml` | `researched-waiting-opinions` | _(dispatch only)_ | Selects engine in order Codex -> Claude -> Copilot |
| Phase 1 execution (selected engine) | `workflow_dispatch` | `.github/workflows/issue-phase1-*.lock.yml` | `researched-waiting-opinions` | `phase-1-complete` | Posts phase 1 long-task analysis |
| Phase 2 dispatcher | `issues.labeled` | `.github/workflows/issue-phase2-dispatch.yml` | `phase-1-complete` | _(dispatch only)_ | Selects engine in order Claude -> Codex -> Copilot |
| Phase 2 execution (selected engine) | `workflow_dispatch` | `.github/workflows/issue-phase2-*.lock.yml` | `phase-1-complete` | `phase-2-complete` | Posts phase 2 long-task delivery plan |
| Assignment + close | `issues.labeled` | `.github/workflows/issue-assignment-close.lock.yml` | `phase-2-complete` | `assigned` | Posts assignment summary and closes issue |

Label-triggered downstream workflows require a user token so safe-outputs label writes can emit workflow-triggering events. Configure `GH_AW_GITHUB_TOKEN` as a fine-grained PAT restricted to this repository with `Issues`, `Pull requests`, and `Contents` set to `Read and write`.

Internet research policy:
- External web tools in the research pass are enabled only when the issue has `allow-internet-research`.
- Without that label, research should stay GitHub-only.
- GitHub-only still allows GitHub search/toolset usage.
- GitHub-only does not imply zero fetch capability: known URLs on allowed domains may still be retrievable via default MCP/browser tooling.

Engine fallback policy for slow-track phases:
- Phase 1 uses `OPENAI_API_KEY` (Codex), then `ANTHROPIC_API_KEY` (Claude), then `COPILOT_GITHUB_TOKEN` (Copilot).
- Phase 2 uses `ANTHROPIC_API_KEY` (Claude), then `OPENAI_API_KEY` (Codex), then `COPILOT_GITHUB_TOKEN` (Copilot).
- Dispatchers validate token health and post a status comment on the issue before dispatching the selected phase workflow.
- Phase outputs should be detailed and include source URLs so downstream phases and fallback engines have high-context inputs.

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
