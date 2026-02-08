---
name: GH-AW Issue Phase 1 (Codex)
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
    target: ${{ github.event.inputs.issue_number }}
  add-labels:
    allowed: [rejected]
    max: 1
    target: ${{ github.event.inputs.issue_number }}
  close-issue:
    max: 1
    target: ${{ github.event.inputs.issue_number }}
engine: codex
---

# Execute slow-track phase 1 with Codex

Run the imported phase 1 instructions.
