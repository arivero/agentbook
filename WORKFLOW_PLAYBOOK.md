# Agentic Workflow Playbook for Agentbook

This playbook translates GitHub Agentic Workflows (GH-AW) guidance into a practical, repeatable process for maintaining this book. Use it to keep the repository aligned with the latest tools, libraries, and ideas in agentic workflows.

## Goals

- Discover new agentic workflow practices and tooling.
- Debate changes in public issues before implementation.
- Assign clear responsibilities to agents.
- Keep book chapters, table of contents, and blog posts in sync.

## The Research → Plan → Assign Loop

### 1) Research (Scheduled or Manual)

**Trigger:** scheduled workflow or `workflow_dispatch`.

**Agent tasks:**

- Scan the ecosystem for new libraries, scaffolds, or workflow patterns.
- Capture citations, links, and a short summary.
- Create a GitHub issue with a structured proposal.

**Suggested issue structure:**

- **Title:** `[Proposal] <tool or pattern name>`
- **Summary:** why the proposal matters
- **Evidence:** links, benchmarks, examples
- **Book impact:** which chapter(s) to update
- **Suggested next step:** accept, revise, or reject

### 2) Plan (Human-Gated)

**Trigger:** maintainer review of the proposal issue.

**Decision logic:**

- **Accept** → label `accepted` and request an agent update.
- **Revise** → label `needs-revision` and ask for clarifications.
- **Reject** → label `rejected` with rationale.

### 3) Assign & Implement

**Trigger:** accepted proposal.

**Agent tasks:**

- Update the relevant chapter(s) and the table of contents.
- Ensure the book homepage and index pages reflect new content.
- Add a blog post announcing the update.
- Let GitHub Actions rebuild the PDF and publish Pages.

## Required Artifacts per Update

- ✅ Chapter update or new chapter markdown
- ✅ `book/chapters/00-toc.md` and `book/index.md` refreshed
- ✅ Root `index.md` updated (homepage links)
- ✅ New `_posts/<date>-<slug>.md` blog entry

## Recommended GH-AW Workflow Components

Use shared components and imports to keep workflows consistent:

```markdown
---
imports:
  - shared/common-tools.md
  - shared/safe-outputs.md
  - shared/issue-templates.md
---
```

### Tooling baseline

- `edit` for file updates
- `github` toolset for issues/PRs
- `web-search` and `web-fetch` for research
- Optional `cache-memory` for trend tracking

## Example Consensus Checklist

- [ ] Proposal issue created
- [ ] At least one maintainer comment
- [ ] Outcome label applied (`accepted` / `needs-revision` / `rejected`)
- [ ] Agent assigned for implementation

## How This Supports the Book

This playbook ensures the book stays aligned with the evolving GH-AW ecosystem while keeping humans in control of what gets published. It also provides a repeatable, auditable process for future agents to follow.
