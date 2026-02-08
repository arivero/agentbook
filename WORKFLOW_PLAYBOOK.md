# Agentic Workflow Playbook for Agentbook

This playbook defines the active GH-AW issue-management lifecycle used in this repository.

## Canonical Issue Lifecycle

```
[opened] -> acknowledged -> triaged-fast-track -> assigned -> closed
                         \-> triaged-for-research -> assigned -> closed
```

At any stage, any agent may reject by explaining the reason, adding `rejected`, and closing the issue.

## Active workflow matrix

| Stage | Trigger | Workflow file | Labels in | Labels out | Result |
|---|---|---|---|---|---|
| Intake ACK | `issues.opened` | `.github/workflows/issue-intake-ack.yml` | _(none)_ | `acknowledged` | Issue acknowledged and routed to agentic triage |
| Routing decision | `workflow_dispatch` (from intake ACK) | `.github/workflows/issue-routing-decision.lock.yml` | `acknowledged` | `triaged-fast-track` or `triaged-for-research` | Agentic routing decision posted |
| Fast-track delivery | `issues.labeled` | `.github/workflows/issue-fast-track-close.lock.yml` | `triaged-fast-track` | `assigned` _(or `rejected`)_ | PR opened and issue closed |
| Research pass | `issues.labeled` (`triaged-for-research`) | `.github/workflows/issue-research-pass.lock.yml` | `triaged-for-research` | _(none by default)_ | Research comment posted |
| Phase 1 dispatcher | `issue_comment.created` (research completion comment) | `.github/workflows/issue-phase1-dispatch.yml` | `triaged-for-research` | _(dispatch only)_ | Selects engine in order Codex -> Claude -> Copilot |
| Phase 1 execution (selected engine) | `workflow_dispatch` | `.github/workflows/issue-phase1-*.lock.yml` | `triaged-for-research` | _(none by default)_ | Posts phase 1 long-task analysis |
| Phase 2 dispatcher | `issue_comment.created` (phase 1 completion comment) | `.github/workflows/issue-phase2-dispatch.yml` | `triaged-for-research` | _(dispatch only)_ | Selects engine in order Claude -> Codex -> Copilot |
| Phase 2 execution (selected engine) | `workflow_dispatch` | `.github/workflows/issue-phase2-*.lock.yml` | `triaged-for-research` | _(none by default)_ | Posts phase 2 long-task delivery plan |
| Assignment dispatcher | `issue_comment.created` (phase 2 completion comment) | `.github/workflows/issue-assignment-dispatch.yml` | `triaged-for-research` | _(dispatch only)_ | Dispatches assignment workflow, then assigns and mentions all available coding agents for phase-3 handoff |
| Assignment + close | `workflow_dispatch` | `.github/workflows/issue-assignment-close.lock.yml` | `triaged-for-research` | `assigned` | Posts assignment summary and closes issue |
| Weekly editorial quality pass | `schedule`, `workflow_dispatch` | `.github/workflows/weekly-editorial-quality.lock.yml` | _(n/a)_ | _(n/a)_ | Editorial agent opens a prose-quality PR or no-ops |

Slow-track downstream handoffs are comment-driven and dispatcher-based, so they do not depend on intermediate status labels. Configure `GH_AW_GITHUB_TOKEN` as a fine-grained PAT restricted to this repository with `Issues`, `Pull requests`, and `Contents` set to `Read and write`.

Phase-3 implementation handoff policy:
- Assignment dispatcher queries repository `suggestedActors` and determines availability of `openai-code-agent`, `anthropic-code-agent`, and `copilot-swe-agent`.
- Dispatcher assigns all available coding agents and mentions them together in the phase-3 handoff comment.
- Human maintainers choose which resulting PR path to continue with.

Internet research policy:
- External web tools in the research pass are enabled by default.
- Research uses GitHub search plus Playwright-accessible external sources.

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
