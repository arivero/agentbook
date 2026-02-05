# Workflows Guide

This document explains the workflows used in this repository and how they implement agentic automation.

## Overview

This repository uses GitHub Agentic Workflows (GH-AW) as the canonical approach to multi-agent automation.

## GitHub Agentic Workflows (GH-AW) - Canonical

**Status**: ✅ **Recommended and Canonical**

GH-AW is GitHub's specification for turning markdown into secure, composable repository automation. These workflows are compiled into `.lock.yml` files and executed with the GH-AW runtime scripts.

### Available GH-AW Workflows

#### 1. Issue Triage Lite (`issue-triage-lite.lock.yml`)
**Trigger**: When issues are opened  
**Purpose**: Initial acknowledgment and lightweight triage

**What it does:**
- Acknowledges the issue and restates the request
- Validates the issue template
- Performs fast research sweep for overlapping content
- Adds initial labels and recommends next steps

**Tools**: `github:issues`, `web-search`, `web-fetch`

#### 2. Issue Synthesis (`issue-synthesis.lock.yml`)
**Trigger**: When issues receive the `researched` label  
**Purpose**: Synthesize research into actionable recommendations

**What it does:**
- Summarizes existing research comments
- Weighs tradeoffs and risks
- Recommends clear next steps (Proceed/Revise/Decline)
- Adds `discussed` and potentially `ready-for-writing` labels

**Tools**: `github:issues`

#### 3. Issue Fast Track (`issue-fast-track.lock.yml`)
**Trigger**: When issues receive both `ready-for-writing` and `fast-track` labels  
**Purpose**: Rapidly implement small, low-risk changes

**What it does:**
- Implements minimal changes in relevant markdown files
- Opens a pull request linked to the issue
- Posts a summary comment
- Adds `content-drafted` label

**Tools**: `github:issues`, `github:pull_requests`, `edit`

### Why GH-AW is Canonical

GH-AW provides several advantages:

1. **Security**: Better agent isolation and permission controls
2. **Declarative**: Agent definitions in markdown are more maintainable
3. **Composability**: Easy to share and reuse agent components
4. **Integration**: Native integration with GitHub Copilot engine
5. **Tooling**: Standardized tool interfaces and safe outputs
6. **Evolution**: Aligned with GitHub's future direction

Learn more in the GH-AW documentation at <https://github.github.io/gh-aw/>.

## Other Workflows

### Pages Deployment (`pages.yml`)
**Trigger**: Push to main branch, manual dispatch  
**Purpose**: Deploy book to GitHub Pages

**Standard Jekyll deployment** - builds and publishes the site.

### PDF Generation (`build-pdf.yml`)
**Trigger**: Changes to `book/**/*.md`, manual dispatch  
**Purpose**: Generate PDF version of the book

Uses Pandoc to combine all chapters into a single PDF document.

## Workflow Selection Guide

### When to Use GH-AW Workflows

✅ Use for all new agent implementations  
✅ Use when implementing agent-based issue triage  
✅ Use when composing agent capabilities  
✅ Use when security and isolation are important

## Contributing New Workflows

When adding new agent workflows:

1. **Prefer GH-AW**: Generate `.lock.yml` workflows with `gh aw compile`
2. **Define Agents**: Create agent definitions in `.github/agents/` (markdown format)
3. **Use Standard Tools**: Leverage GH-AW tool ecosystem
4. **Document**: Update this file with your workflow's purpose and usage
5. **Test**: Validate with the GH-AW specification

See [WORKFLOW_PLAYBOOK.md](WORKFLOW_PLAYBOOK.md) for the research → plan → assign pattern.

## Agent Definitions

Agent definitions are stored in `.github/agents/` as markdown files:

- `issue-ack.md` - Acknowledgment agent
- `issue-research.md` - Research agent
- `issue-discuss-claude.md` - Claude perspective agent
- `issue-discuss-copilot.md` - Copilot perspective agent
- `issue-writer.md` - Content writing agent
- `issue-complete.md` - Completion agent
- `issue-workflow.md` - Main orchestration workflow

These agents are referenced by the GH-AW workflows and demonstrate the agent definition format.

## Troubleshooting

### GH-AW Workflow Not Running

1. Verify GH-AW workflows are compiled (`gh aw compile`)
2. Verify workflow permissions in repository settings
3. Check workflow syntax with GH-AW validator
4. Review workflow logs in Actions tab

## Further Reading

- [GitHub Agentic Workflows Documentation](https://github.github.io/gh-aw/)
- [Workflow Playbook](WORKFLOW_PLAYBOOK.md)
- [Contributing Guide](CONTRIBUTING.md)

---

**Last Updated**: February 4, 2026  
**Questions?** Open an issue with the `question` label.
