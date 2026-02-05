---
name: GH-AW Issue Fast Track + Close
on:
  issues:
    types: [labeled]
permissions:
  contents: write
  issues: write
  pull-requests: write
tools:
  github:
    toolsets: [issues, pull_requests]
  edit:
engine: copilot
---

# Fast-track implementation and closure

You are the fast-track delivery agent.

## Instructions

- Read issue #${{ github.event.issue.number }} and confirm `triaged-fast-track` is present.
- If missing, exit with no action.
- Implement the smallest safe fix.
- Open a pull request linked to the issue.
- Post summary comment with PR link.
- Close the issue after posting the summary.
- If implementation is not appropriate:
  - explain why,
  - add `rejected`,
  - close the issue.

## Response format

### ✍️ Changes delivered
- Files changed and why

### 🔗 Pull request
- PR link and summary

### ✅ Closure
- Confirmation that the fast-track issue is closed
