# Chapter 5: GitHub Agentic Workflows (GH-AW)

## Why GH-AW Matters

GitHub Agentic Workflows (GH-AW) turns natural language into automated repository agents that run inside GitHub Actions. Instead of writing large YAML pipelines by hand, you write markdown instructions that an AI agent executes with guardrails. The result is a workflow you can read like documentation but run like automation.

At a glance, GH-AW provides:

- **Natural language workflows**: Markdown instructions drive the agent’s behavior.
- **Compile-time structure**: Markdown is compiled into GitHub Actions workflows for reproducibility.
- **Security boundaries**: Permissions, tools, and safe outputs define what the agent can and cannot do.
- **Composable automation**: Imports and shared components enable reuse across repositories.

## Core Workflow Structure

A GH-AW workflow is a markdown file with frontmatter and instructions:

```markdown
---
on:
  issues:
    types: [opened]
permissions:
  contents: read
tools:
  edit:
  github:
    toolsets: [issues]
engine: copilot
---

# Triage this issue
Read issue #${{ github.event.issue.number }} and summarize it.
```

**Key parts:**

1. **Frontmatter**
   - `on`: GitHub Actions triggers (issues, schedules, dispatch, etc.)
   - `permissions`: least-privilege access to GitHub APIs
   - `tools`: the capabilities your agent can invoke (edit, bash, web, github)
   - `engine`: AI model/provider (Copilot, Claude Code, Codex)

2. **Markdown instructions**
   - Natural language steps for the agent
   - Context variables from the event payload (issue number, PR, repo)

## How GH-AW Runs

GH-AW compiles markdown workflows into `.lock.yml` GitHub Actions workflows. The compiled file is what GitHub actually executes, but the markdown remains the authoritative source. This gives you readable automation with predictable execution.

Key behaviors to remember:

- **Frontmatter edits require recompile**.
- **Markdown instruction updates can often be edited directly** (the runtime loads the markdown body).
- **Shared components** can be stored as markdown files without `on:`; they are imported, not compiled.

## Tools, Safe Inputs, and Safe Outputs

GH-AW workflows are designed for safety by default. Agents run with minimal access and must declare tools explicitly.

### Tools

Tools are capabilities the agent can use:

- **edit**: modify files in the workspace
- **bash**: run shell commands (by default only safe commands)
- **web-fetch / web-search**: fetch or search web content
- **github**: operate on issues, PRs, discussions, projects
- **playwright**: browser automation for UI checks

### Safe Outputs

Write actions (creating issues, comments, commits) can be routed through safe outputs to sanitize what the agent writes. This keeps the core job read-only and limits accidental changes.

### Safe Inputs

You can define safe inputs to structure what the agent receives. This is a good place to validate schema-like data for tools or commands.

## Imports and Reusable Components

GH-AW supports imports in two ways:

- **Frontmatter imports**

```yaml
imports:
  - shared/common-tools.md
  - shared/research-library.md
```

- **Markdown directive**

```markdown
{{#import shared/common-tools.md}}
```

Imports let you create a library of reusable workflow fragments (shared tools, standard prompts, or organization-wide policies). Files without `on:` become *components* that can be imported without being compiled into Actions.

## ResearchPlanAssign: A Pattern for Self-Maintaining Books

GH-AW documents a **ResearchPlanAssign** strategy: a scaffolded loop that keeps humans in control while delegating research and execution to agents.

**Phase 1: Research**
- A scheduled agent scans the repo or ecosystem (new libraries, frameworks, scaffolds).
- It produces a report in an issue or discussion.

**Phase 2: Plan**
- Maintainers review the report and decide whether to proceed.
- A planning agent drafts the implementation steps if approved.

**Phase 3: Assign & Implement**
- Agents are assigned to implement the approved changes.
- Updates are validated, committed, and published.

This pattern maps well to this book: use scheduled research to discover new agentic tooling, post a proposal issue, build consensus, then update the chapters and blog.

## Applying GH-AW to This Repository

Here’s how GH-AW can drive the book’s maintenance:

1. **Research (scheduled)**
   - Use web-search tooling to scan for new agentic workflow libraries.
   - Produce a structured report in a GitHub issue.
2. **Consensus (issues/discussions)**
   - Collect votes or comments to accept/reject the proposal.
   - Label outcomes (`accepted`, `needs-revision`, `rejected`).
3. **Implementation (assigned agent)**
   - Update or add chapters.
   - Refresh the table of contents and homepage.
   - Add a blog post summarizing the update.
4. **Publish (automation)**
   - Pages and PDF rebuild automatically after merge.

This approach keeps the book aligned with the latest GH-AW practices while maintaining a transparent, auditable workflow.

## Key Takeaways

- GH-AW turns markdown instructions into reproducible GitHub Actions workflows.
- Frontmatter defines triggers, permissions, tools, and models.
- Imports enable composable, reusable workflow building blocks.
- Safe inputs/outputs and least-privilege permissions reduce risk.
- ResearchPlanAssign provides a practical loop for continuous, agent-powered improvement.
