---
name: GH-AW Issue Opinion (Copilot Strategy Model)
on:
  issues:
    types: [labeled]
    names: [researched-waiting-opinions]
permissions:
  contents: read
  issues: read
tools:
  github:
    toolsets: [issues]
safe-outputs:
  add-comment:
    max: 1
  add-labels:
    allowed: [opinion-copilot-strategy-posted, rejected]
    max: 2
  close-issue:
    max: 1
engine: copilot
---

# Post slow-track strategy opinion from Copilot

You are the Copilot strategy-model opinion agent for slow-track issues.

## Instructions

- Read issue #${{ github.event.issue.number }} and all comments.
- If `researched-waiting-opinions` is not present, exit with no action.
- If `opinion-copilot-strategy-posted` is already present, exit with no action.
- Use a strategy-focused Copilot model profile (architecture/safety/clarity emphasis).
- Post one strategy opinion comment.
- Add label `opinion-copilot-strategy-posted`.
- If the issue should be declined:
  - explain why,
  - add `rejected`,
  - close the issue.

## Safe outputs

- Use safe outputs for comments, labels, and issue closure.
- Do not call GitHub write tools directly.
