---
name: GH-AW Issue Phase 2 (Claude)
on:
  workflow_dispatch:
    inputs:
      issue_number:
        description: Issue number to process
        required: true
        type: string
concurrency:
  group: gh-aw-${{ github.workflow }}-${{ github.event.inputs.issue_number }}
permissions:
  contents: read
  issues: read
  pull-requests: read
imports:
  - ../agents/phase2.md
safe-outputs:
  github-token: ${{ secrets.GH_AW_GITHUB_TOKEN || secrets.GITHUB_TOKEN }}
  add-comment:
    max: 1
    target: "*"
  add-labels:
    allowed: [phase-2-complete, rejected]
    max: 2
    target: "*"
  close-issue:
    max: 1
    target: "*"
engine: claude
---

# Execute slow-track phase 2 with Claude

Run the imported phase 2 instructions.
