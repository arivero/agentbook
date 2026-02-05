---
name: GH-AW Issue Assignment + Close
on:
  issues:
    types: [labeled]
permissions:
  contents: read
  issues: write
tools:
  github:
    toolsets: [issues]
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
