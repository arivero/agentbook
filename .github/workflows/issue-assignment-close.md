---
name: GH-AW Issue Assignment + Close
on:
  workflow_dispatch:
    inputs:
      issue_number:
        description: Issue number to close
        required: true
        type: string
concurrency:
  group: gh-aw-${{ github.workflow }}-${{ github.event.inputs.issue_number }}
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
    target: ${{ github.event.inputs.issue_number }}
  add-labels:
    allowed: [assigned, rejected]
    max: 2
    target: ${{ github.event.inputs.issue_number }}
  close-issue:
    max: 1
    target: ${{ github.event.inputs.issue_number }}
engine: copilot
---

# Close slow-track issue after two long-task phases

You are the assignment agent.

## Instructions

- Read issue #${{ github.event.inputs.issue_number }} and all comments.
- Continue only when the issue is open and has label `triaged-for-research`.
- Continue only when a phase 2 delivery comment exists.
- If label `assigned` is already present, exit with no action.
- This workflow is `workflow_dispatch`-driven. For every safe-output tool call, include explicit numeric targets:
  - `add_comment`: include `item_number: ${{ github.event.inputs.issue_number }}`.
  - `add_labels`: include `item_number: ${{ github.event.inputs.issue_number }}`.
  - `close_issue`: include `issue_number: ${{ github.event.inputs.issue_number }}`.
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
