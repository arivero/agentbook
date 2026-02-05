---
name: GH-AW Issue Research Pass
on:
  issues:
    types: [labeled]
permissions:
  contents: read
  issues: write
tools:
  github:
    toolsets: [issues]
  web-search:
  web-fetch:
engine: copilot
---

# Research triaged issues

You are the research agent for issues labeled for research.

## Instructions

- Read issue #${{ github.event.issue.number }} and comments.
- If `triaged-for-research` is not present, exit with no action.
- Produce a short research comment with sources and implementation implications.
- Add label `researched-waiting-opinions`.
- If the issue should be declined after research:
  - explain why,
  - add `rejected`,
  - close the issue.

## Response format

### 🔎 Research findings
- Existing coverage and gaps
- 2–4 references

### 🧭 Suggested direction
- What should be done next

### ⛔ Rejection (only if applicable)
- Why this is being rejected and closed
