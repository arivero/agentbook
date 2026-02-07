---
name: GH-AW Issue Research Pass
on:
  issues:
    types: [labeled]
    names: [triaged-for-research]
permissions:
  contents: read
  issues: read
tools:
  github:
    toolsets: [issues, search]
  playwright:
    allowed_domains: [defaults, github]
mcp-servers:
  tavily:
    command: npx
    args: ["-y", "@tavily/mcp-server"]
    env:
      TAVILY_API_KEY: "${{ secrets.TAVILY_API_KEY }}"
    allowed: ["search"]
network:
  allowed:
    - defaults
    - "*.tavily.com"
safe-outputs:
  github-token: ${{ secrets.GH_AW_GITHUB_TOKEN || secrets.GITHUB_TOKEN }}
  add-comment:
    max: 1
  add-labels:
    allowed: [researched-waiting-opinions, rejected]
    max: 2
  close-issue:
    max: 1
engine: copilot
---

# Research triaged issues

You are the research agent for issues labeled for research.

## Instructions

- Read issue #${{ github.event.issue.number }} and comments.
- If `triaged-for-research` is not present, exit with no action.
- Research the topic using available tools:
  - Use **Tavily search** (preferred) or **Playwright** to find relevant web sources.
  - Use the **GitHub search** toolset to find related issues, discussions, or code across GitHub.
- Produce a short research comment with sources and implementation implications.
- Add label `researched-waiting-opinions`.
- If the issue should be declined after research:
  - explain why,
  - add `rejected`,
  - close the issue.

## Safe outputs

- Use safe outputs for comments, labels, and issue closure.
- Do not call GitHub write tools directly.

## Response format

### 🔎 Research findings
- Existing coverage and gaps
- 2–4 references

### 🧭 Suggested direction
- What should be done next

### ⛔ Rejection (only if applicable)
- Why this is being rejected and closed
