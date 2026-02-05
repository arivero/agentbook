---
title: "GitHub Agentic Workflows (GH-AW)"
order: 5
---

# GitHub Agentic Workflows (GH-AW)

## Chapter Preview

- Explain how GH-AW compiles markdown into deterministic workflows.
- Show how to set up GH-AW with the supported setup actions.
- Highlight safety controls (permissions, safe outputs, approvals).

## Why GH-AW Matters

GitHub Agentic Workflows (GH-AW) (<https://github.github.io/gh-aw/>) turns natural language into automated repository agents that run inside GitHub Actions. Instead of writing large YAML pipelines by hand, you write markdown instructions that an AI agent executes with guardrails. The result is a workflow you can read like documentation but run like automation.

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

### File Location

Both the source markdown files and the compiled `.lock.yml` files live in the `.github/workflows/` directory:

```text
.github/workflows/
|-- triage.md          # Source (human-editable)
|-- triage.lock.yml    # Compiled (auto-generated, do not edit)
|-- docs-refresh.md
`-- docs-refresh.lock.yml
```

Use `gh aw compile` (from the GH-AW CLI at <https://github.com/github/gh-aw>) in your repository root to generate `.lock.yml` files from your markdown sources. Only edit the `.md` files; the `.lock.yml` files are regenerated on compile.

If you do not vendor the GH-AW `actions/` directory in your repository, you can instead reference the upstream setup action directly (pin to a commit SHA for security):

```yaml
- name: Setup GH-AW scripts
  uses: github/gh-aw/actions/setup@5a4d651e3bd33de46b932d898c20c5619162332e
  with:
    destination: /opt/gh-aw/actions
```

### Key Behaviors

- **Frontmatter edits require recompile**.
- **Markdown instruction updates can often be edited directly** (the runtime loads the markdown body).
- **Shared components** can be stored as markdown files without `on:`; they are imported, not compiled.

## Compilation Model Examples

GH-AW compilation is mostly a structural translation: frontmatter becomes the workflow header, the markdown body is packaged as a script or prompt payload, and imports are inlined or referenced. The compiled `.lock.yml` is the contract GitHub Actions executes. The examples below show how a markdown workflow turns into a compiled job.

### Example 1: Issue Triage Workflow

**Source markdown (`.github/workflows/triage.md`)**

```markdown
---
on:
  issues:
    types: [opened]
permissions:
  contents: read
  issues: write
tools:
  github:
    toolsets: [issues]
engine: copilot
---

# Triage this issue
Read issue #${{ github.event.issue.number }} and summarize it.
Then add labels: needs-triage and needs-owner.
```

**Compiled workflow (`.github/workflows/triage.lock.yml`)**

```yaml
name: GH-AW triage
on:
  issues:
    types: [opened]
permissions:
  contents: read
  issues: write
jobs:
  agent:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout actions folder
        uses: actions/checkout@8e8c483db84b4bee98b60c0593521ed34d9990e8 # v6
        with:
          sparse-checkout: |
            actions
          persist-credentials: false
      - name: Setup GH-AW scripts
        uses: ./actions/setup
        with:
          destination: /opt/gh-aw/actions
      - name: Run GH-AW agent (generated)
        uses: actions/github-script@ed597411d8f924073f98dfc5c65a23a2325f34cd # v8.0.0
        with:
          script: |
            const { setupGlobals } = require('/opt/gh-aw/actions/setup_globals.cjs');
            setupGlobals(core, github, context, exec, io);
            // Generated execution script omitted for brevity.
```

**What changed during compilation**

- Frontmatter was converted into workflow metadata (`on`, `permissions`, `jobs`).
- Generated steps reference the GH-AW scripts copied by the setup action.
- The markdown body became the prompt payload executed by the agent runtime.

### Example 2: Reusable Component + Import

**Component (`.github/workflows/shared/common-tools.md`)**

```markdown
---
tools:
  bash:
  edit:
engine: copilot
---
```

**Workflow using an import (`.github/workflows/docs-refresh.md`)**

```markdown
---
on:
  workflow_dispatch:
permissions:
  contents: write
imports:
  - shared/common-tools.md
---

# Refresh docs
Update the changelog with the latest release notes.
```

**Compiled workflow (`.github/workflows/docs-refresh.lock.yml`)**

```yaml
name: GH-AW docs refresh
on:
  workflow_dispatch:
permissions:
  contents: write
jobs:
  agent:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout actions folder
        uses: actions/checkout@8e8c483db84b4bee98b60c0593521ed34d9990e8 # v6
        with:
          sparse-checkout: |
            actions
          persist-credentials: false
      - name: Setup GH-AW scripts
        uses: ./actions/setup
        with:
          destination: /opt/gh-aw/actions
      - name: Run GH-AW agent (generated)
        uses: actions/github-script@ed597411d8f924073f98dfc5c65a23a2325f34cd # v8.0.0
        with:
          script: |
            const { setupGlobals } = require('/opt/gh-aw/actions/setup_globals.cjs');
            setupGlobals(core, github, context, exec, io);
            // Generated execution script omitted for brevity.
```

**What changed during compilation**

- `imports` were resolved and merged with the workflow frontmatter.
- The component’s `tools` and `engine` were applied to the final workflow.
- Only workflows with `on:` are compiled; components remain markdown-only.

### Example 3: Safe Outputs in the Compiled Job

**Source markdown (`.github/workflows/release-notes.md`)**

```markdown
---
on:
  workflow_dispatch:
permissions:
  contents: read
  pull-requests: write
tools:
  edit:
safe_outputs:
  pull_request_body:
    format: markdown
engine: copilot
---

# Draft release notes
Summarize commits since the last tag and open a PR with the notes.
```

**Compiled workflow (`.github/workflows/release-notes.lock.yml`)**

```yaml
name: GH-AW release notes
on:
  workflow_dispatch:
permissions:
  contents: read
  pull-requests: write
jobs:
  agent:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout actions folder
        uses: actions/checkout@8e8c483db84b4bee98b60c0593521ed34d9990e8 # v6
        with:
          sparse-checkout: |
            actions
          persist-credentials: false
      - name: Setup GH-AW scripts
        uses: ./actions/setup
        with:
          destination: /opt/gh-aw/actions
      - name: Run GH-AW agent (generated)
        uses: actions/github-script@ed597411d8f924073f98dfc5c65a23a2325f34cd # v8.0.0
        with:
          script: |
            const { setupGlobals } = require('/opt/gh-aw/actions/setup_globals.cjs');
            setupGlobals(core, github, context, exec, io);
            // Generated execution script omitted for brevity.
```

**What changed during compilation**

- `safe_outputs` was translated into the generated safe-output scripts invoked by the job.
- The prompt stayed identical; guardrails are enforced by the compiled job.

## Tools, Safe Inputs, and Safe Outputs

GH-AW workflows are designed for safety by default. Agents run with minimal access and must declare tools explicitly.

> **Warning:** Treat CI secrets and tokens as production credentials. Use least-privilege permissions, require human approval for write actions, and keep all agent actions auditable.

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
{% raw %}{{#import shared/common-tools.md}}{% endraw %}
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
