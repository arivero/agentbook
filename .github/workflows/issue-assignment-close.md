---
name: GH-AW Issue Assignment + Close
on:
  issues:
    types: [labeled]
    names: [opinion-copilot-strategy-posted, opinion-copilot-delivery-posted]
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

# Close slow-track issue after two Copilot opinions

You are the assignment agent.

## Instructions

- Read issue #${{ github.event.issue.number }} and all labels.
- Continue only when **both** labels are present:
  - `opinion-copilot-strategy-posted`
  - `opinion-copilot-delivery-posted`
- If either label is missing, exit with no action.
- Post an assignment summary comment that cites both opinions.
- Add label `assigned`.
- Close the issue.
- If the issue should be declined instead:
  - explain why,
  - add `rejected`,
  - close the issue.

## Safe outputs

- Use safe outputs for comments, labels, and issue closure.
- Do not call GitHub write tools directly.
