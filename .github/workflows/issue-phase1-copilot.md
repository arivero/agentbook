---
name: GH-AW Issue Phase 1 (Copilot)
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
  - ../agents/phase1.md
safe-outputs:
  github-token: ${{ secrets.GH_AW_GITHUB_TOKEN || secrets.GITHUB_TOKEN }}
  add-comment:
    max: 1
    target: "*"
  add-labels:
    allowed: [phase-1-complete, rejected]
    max: 2
    target: "*"
  close-issue:
    max: 1
    target: "*"
engine: copilot
---

# Execute slow-track phase 1 with Copilot

Run the imported phase 1 instructions.
