---
name: Issue Lifecycle (labels + workflow mapping)
description: >
  Defines the active issue-management lifecycle and maps each stage to
  executable GH-AW workflow files.
---

# Issue Lifecycle for Agentbook

This repository uses a label-driven lifecycle with six automation workflows.

## Canonical label progression

```
[opened] -> acknowledged -> triaged-fast-track
                         \-> triaged-for-research -> researched-waiting-opinions
                             -> opinion-copilot-strategy-posted + opinion-copilot-delivery-posted -> assigned -> closed
```

At any step, an agent may reject with rationale: add `rejected` and close.

## Stage mapping

1. **Acknowledged + routing**
   - Workflow: `.github/workflows/issue-intake-triage.lock.yml`
   - Trigger: issue opened
   - Output labels: `acknowledged` + one of (`triaged-fast-track`, `triaged-for-research`)

2. **Fast-track implementation + close**
   - Workflow: `.github/workflows/issue-fast-track-close.lock.yml`
   - Trigger: labeled with `triaged-fast-track`
   - Output: PR opened, issue closed

3. **Research pass**
   - Workflow: `.github/workflows/issue-research-pass.lock.yml`
   - Trigger: labeled with `triaged-for-research`
   - Output label: `researched-waiting-opinions`

4. **Opinion A (Copilot strategy model)**
   - Workflow: `.github/workflows/issue-opinion-copilot-strategy.lock.yml`
   - Trigger: labeled with `researched-waiting-opinions`
   - Output label: `opinion-copilot-strategy-posted`

5. **Opinion B (Copilot delivery model)**
   - Workflow: `.github/workflows/issue-opinion-copilot-delivery.lock.yml`
   - Trigger: labeled with `researched-waiting-opinions`
   - Output label: `opinion-copilot-delivery-posted`

6. **Assignment + close**
   - Workflow: `.github/workflows/issue-assignment-close.lock.yml`
   - Trigger: labeled with `opinion-copilot-strategy-posted` or `opinion-copilot-delivery-posted`
   - Condition: both opinion labels must be present
   - Output label: `assigned`, then issue closed

## Source/compile rule

Each workflow is maintained in `*.md` source form and compiled to `*.lock.yml`
using `gh aw` commands. Source and compiled artifacts must be updated together.
