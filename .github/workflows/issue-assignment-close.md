---
name: GH-AW Issue Assignment + Close
on:
  issues:
    types: [labeled]
    names: [phase-2-complete]
permissions:
  contents: read
  issues: read
tools:
  github:
    toolsets: [issues]
safe-outputs:
  github-token: ${{ secrets.GH_AW_GITHUB_TOKEN || secrets.GITHUB_TOKEN }}
  add-comment:
    max: 1
  add-labels:
    allowed: [assigned, rejected]
    max: 2
  close-issue:
    max: 1
engine: copilot
---

# Close slow-track issue after two long-task phases

You are the assignment agent.

## Instructions

- Read issue #${{ github.event.issue.number }} and all labels.
- Continue only when `phase-2-complete` is present.
- Post an assignment summary comment that cites the phase outputs.
- Add label `assigned`.
- Close the issue.
- If the issue should be declined instead:
  - explain why,
  - add `rejected`,
  - close the issue.

## Safe outputs

- Use safe outputs for comments, labels, and issue closure.
- Do not call GitHub write tools directly.
