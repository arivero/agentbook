---
name: Multi-Agent Issue Processing
description: >
  Orchestrates multiple agents to process issue suggestions through
  acknowledgment, research, multi-model discussion, writing, and completion.
on:
  issues:
    types: [opened, labeled]
permissions:
  contents: write
  issues: write
  pull-requests: write
tools:
  github:
    toolsets: [issues, pull_requests]
  edit:
  web-search:
  web-fetch:
imports:
  - .github/agents/issue-ack.md
  - .github/agents/issue-research.md
  - .github/agents/issue-discuss-claude.md
  - .github/agents/issue-discuss-copilot.md
  - .github/agents/issue-writer.md
  - .github/agents/issue-complete.md
---

# Multi-Agent Issue Processing Workflow

This workflow orchestrates multiple AI agents to process issue suggestions
for the Agentic Workflows Book. Each stage builds on the previous one,
creating a collaborative, transparent review process.

## Workflow Stages

### Stage 1: Acknowledgment
When a new issue is opened, the **Acknowledgment Agent** responds first.
It thanks the contributor, validates the request format, and sets expectations.

**Trigger:** Issue opened
**Agent:** issue-ack.md
**Labels added:** `acknowledged`, `in-progress`

### Stage 2: Research
The **Research Agent** investigates the suggestion. It searches existing
documentation, finds external sources, and assesses the novelty and value.

**Trigger:** `acknowledged` label present
**Agent:** issue-research.md
**Labels added:** `researched`
**Output:** Detailed research report as issue comment

**Optional substitute:** `issue-triage-lite.md` can replace Stages 1–2 for
low-risk issues when a single acknowledgment + research pass is sufficient.

### Stage 3: Multi-Model Discussion
Two different AI models provide their perspectives:

- **Claude Agent**: Focuses on safety, clarity, and implementation concerns
- **Copilot Agent**: Focuses on code examples, developer experience, and GitHub integration

**Trigger:** `researched` label present
**Agents:** issue-discuss-claude.md, issue-discuss-copilot.md
**Labels added:** `discussed`
**Output:** Two perspective comments from different models

**Optional substitute:** `issue-synthesis.md` can replace Stage 3 when a single
consolidated perspective is preferred.

### Stage 4: Content Writing
The **Writer Agent** synthesizes all contributions and drafts actual content.
It creates or updates book chapters and opens a pull request.

**Trigger:** `discussed` label AND `ready-for-writing` label
**Agent:** issue-writer.md
**Labels added:** `content-drafted`
**Output:** Pull request with new content

**Optional substitute:** `issue-fast-track.md` can replace Stages 4–5 for small,
low-risk edits that can be delivered in one PR.

### Stage 5: Completion
After the PR is merged, the **Completion Agent** summarizes the outcome,
thanks contributors, and closes the issue.

**Trigger:** PR merged AND `content-drafted` label
**Agent:** issue-complete.md
**Labels added:** `completed`
**Output:** Summary comment, issue closed

## Human Checkpoints

The workflow includes human checkpoints for quality control:

1. **After Research**: Maintainers review the research and add `ready-for-writing`
   label to proceed, or add `needs-revision` for more information.

2. **Pull Request Review**: Maintainers review and merge the content PR.

3. **Any Stage**: Maintainers can pause the workflow by removing labels or
   adding `on-hold`.

## Label Flow

```
[opened] → acknowledged → researched → discussed → ready-for-writing → content-drafted → completed
                                                   ↑
                                            (human gate)
```

## Error Handling

- If an agent fails, it adds `agent-error` label
- Manual intervention can restart from any stage
- All agent actions are logged in issue comments

## Notes

This workflow demonstrates the **ResearchPlanAssign** pattern from Chapter 5.
It keeps humans in control while delegating research and execution to agents.
