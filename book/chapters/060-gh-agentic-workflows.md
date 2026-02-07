---
title: "GitHub Agentic Workflows (GH-AW)"
order: 6
---

# GitHub Agentic Workflows (GH-AW)

## Chapter Preview

This chapter explains how GH-AW compiles markdown into deterministic workflows that GitHub Actions can execute. It shows how to set up GH-AW with the supported setup actions, including both vendored and upstream approaches. Finally, it highlights the safety controls that make agentic workflows production-ready: permissions, safe outputs, and approval gates.

## Why GH-AW Matters

GitHub Agentic Workflows (GH-AW) (<https://github.github.io/gh-aw/>) turns natural language into automated repository agents that run inside GitHub Actions. Instead of writing large YAML pipelines by hand, you write markdown instructions that an AI agent executes with guardrails. The result is a workflow you can read like documentation but run like automation.

At a glance, GH-AW provides several key capabilities. **Natural language workflows** allow you to write markdown instructions that drive the agent's behaviour, making automation readable to humans. **Compile-time structure** means your markdown is compiled into GitHub Actions workflows, ensuring reproducibility across runs. **Security boundaries** let you define permissions, tools, and safe outputs that constrain what the agent can and cannot do. **Composable automation** enables imports and shared components that you can reuse across repositories.

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

The **frontmatter** section configures the workflow's behaviour. The `on` field specifies GitHub Actions triggers such as issues, schedules, or dispatch events. The `permissions` field declares least-privilege access to GitHub APIs, ensuring the agent can only perform authorised operations. The `tools` field lists the capabilities your agent can invoke, such as edit, bash, web, or github. The `engine` field specifies the AI model or provider to use, such as Copilot, Claude Code, or Codex.

The **markdown instructions** section contains natural language steps for the agent to follow. You can include context variables from the event payload, such as issue number, PR number, or repository name, using template syntax.

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

There are three key behaviours to understand about the compilation model. First, **frontmatter edits require recompile**—any changes to triggers, permissions, tools, or engine settings must be followed by running `gh aw compile` to regenerate the lock file. Second, **markdown instruction updates can often be edited directly** because the runtime loads the markdown body at execution time; however, structural changes may still require recompilation. Third, **shared components** can be stored as markdown files without an `on:` trigger; these are imported rather than compiled, allowing reuse without duplication.

### Compilation Pitfalls

GH-AW compilation is predictable, but a few pitfalls are common in real repositories.

**Only compile workflow markdown.** The compiler expects frontmatter with an `on:` trigger. Non-workflow files like `AGENTS.md` or general docs should not be passed to `gh aw compile`. Use `gh aw compile <workflow-id>` to target specific workflows when the directory includes other markdown files.

**Strict mode rejects direct write permissions.** GH-AW runs in strict mode by default; you can opt out by adding `strict: false` to the workflow frontmatter, but the recommended path is to keep strict mode on. Workflows that request `issues: write`, `pull-requests: write`, or `contents: write` will fail validation in strict mode. Use read-only permissions plus `safe-outputs` for labels, comments, and PR creation instead.

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
  issues: read
tools:
  github:
    toolsets: [issues]
safe-outputs:
  add-comment:
    max: 1
  add-labels:
    allowed: [needs-triage, needs-owner]
    max: 2
engine: copilot
---

# Triage this issue
Read issue #${{ github.event.issue.number }} and summarize it.
Then suggest labels: needs-triage and needs-owner.
```

**Compiled workflow (`.github/workflows/triage.lock.yml`)**

```yaml
name: GH-AW triage
on:
  issues:
    types: [opened]
permissions:
  contents: read
  issues: read
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
- `safe-outputs` declarations were compiled into guarded output steps.

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
  contents: read
imports:
  - shared/common-tools.md
safe-outputs:
  create-pull-request:
    max: 1
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
  contents: read
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
- Read-only permissions pair with `safe-outputs` to stage changes safely.

### Example 3: Safe Outputs in the Compiled Job

**Source markdown (`.github/workflows/release-notes.md`)**

```markdown
---
on:
  workflow_dispatch:
permissions:
  contents: read
tools:
  edit:
safe-outputs:
  create-pull-request:
    max: 1
engine: copilot
---

# Draft release notes
Summarize commits since the last tag and propose a PR with the notes.
```

**Compiled workflow (`.github/workflows/release-notes.lock.yml`)**

```yaml
name: GH-AW release notes
on:
  workflow_dispatch:
permissions:
  contents: read
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

- `safe-outputs` was translated into the generated safe-output scripts invoked by the job.
- The prompt stayed identical; guardrails are enforced by the compiled job.

## Tools, Safe Inputs, and Safe Outputs

GH-AW workflows are designed for safety by default. Agents run with minimal access and must declare tools explicitly.

> **Warning:** Treat CI secrets and tokens as production credentials. Use least-privilege permissions, require human approval for write actions, and keep all agent actions auditable.

### Tools

Tools are capabilities the agent can use. The **edit** tool allows the agent to modify files in the workspace. The **bash** tool runs shell commands, with safe commands enabled by default. The **web-fetch** and **web-search** tools allow the agent to fetch or search web content. The **github** tool operates on issues, pull requests, discussions, and projects. The **playwright** tool provides browser automation for UI checks.

### Integration Surfaces on GitHub

When teams say "use Claude or Codex on GitHub," they often mean different integration surfaces. Keep these separate in architecture decisions:

| Surface | Typical trigger | Configuration locus | Best fit |
|---|---|---|---|
| Third-party agent in issues/PRs | Issue/PR interaction (agent UI, assignment, or agent-specific mention flow) | GitHub agent integration setup + repo permissions | Conversational analysis and iterative collaboration on a thread |
| Standard GitHub Action | Normal workflow events (`pull_request`, `issues`, `workflow_dispatch`, schedules) | YAML `uses:` steps (for example Claude/Codex actions) + secrets | Deterministic CI/CD automation with explicit step sequencing |
| GH-AW engine | GH-AW workflow trigger (`issues`, `workflow_dispatch`, etc.) | GH-AW frontmatter (`engine: copilot|claude|codex`) + compile pipeline | Multi-stage agentic workflows with guardrails (`safe-outputs`, tool controls, imports) |

Related but separate: GitHub's first-party coding-agent assignment path (for example assigning to `copilot-swe-agent`) is neither a third-party action wrapper nor GH-AW engine selection.

A practical pattern is hybrid orchestration: use standard workflows for intake and dispatch, GH-AW for routed autonomous stages, and issue/PR agent interactions when humans want direct thread-level collaboration.

### Safe Outputs

Write actions (creating issues, comments, commits) can be routed through safe outputs to sanitize what the agent writes. This keeps the core job read-only and limits accidental changes.

In strict mode, safe outputs are required for write operations. Declare them in frontmatter to specify what the agent can produce:

```yaml
safe-outputs:
  add-comment:
    max: 1
  add-labels:
    allowed: [needs-triage, needs-owner]
    max: 2
  create-pull-request:
    max: 1
```

The agent generates structured output that downstream steps apply, keeping repository writes explicit and auditable.

`max` caps how many outputs of a given type are accepted; extra outputs are rejected by the safe-output validator.

When using `add-labels`, keep the `allowed` list in sync with labels that already exist in the repository; missing labels cause runtime output failures when the safe-output job applies them.

For label-triggered workflow chains, writes from the default `GITHUB_TOKEN` may not emit downstream workflow-triggering events. In those cases, configure `safe-outputs.github-token` to use a dedicated repository-scoped user token (for this repository, `GH_AW_GITHUB_TOKEN`).

### Safe Inputs

You can define safe inputs to structure what the agent receives. This is a good place to validate schema-like data for tools or commands.

## Imports and Reusable Components

For terminology and trust-model definitions, see [Discovery and Imports](050-discovery-imports.md). This section focuses only on GH-AW-specific syntax and composition patterns.

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

In GH-AW, these imports are typically workflow-fragment artefacts: shared prompts, tool declarations, and policy snippets. Keep reusable fragments in files without `on:` so they can be imported as components rather than compiled as standalone workflows.

## ResearchPlanAssign: A Pattern for Self-Maintaining Books

GH-AW documents a **ResearchPlanAssign** strategy: a scaffolded loop that keeps humans in control while delegating research and execution to agents.

**Phase 1: Research.** A scheduled agent scans the repository or ecosystem for updates such as new libraries, frameworks, or scaffolds. It produces a report in an issue or discussion, summarising findings and flagging items that may warrant attention.

**Phase 2: Plan.** Maintainers review the report and decide whether to proceed. If approved, a planning agent drafts the implementation steps, breaking the work into discrete tasks that can be assigned and tracked.

**Phase 3: Assign and Implement.** Agents are assigned to implement the approved changes. Updates are validated through tests and reviews, committed to the repository, and published to the appropriate outputs.

This pattern maps well to this book: use scheduled research to discover new agentic tooling, post a proposal issue, build consensus, then update the chapters and blog.

## Applying GH-AW to This Repository

This repository uses a hybrid lifecycle documented in [WORKFLOW_PLAYBOOK.md](../../WORKFLOW_PLAYBOOK.md): a standard intake ACK workflow followed by GH-AW routing and label-driven downstream stages.

**Intake ACK + dispatch.** When an issue is opened, a standard workflow (`issue-intake-ack.yml`) posts acknowledgment, adds `acknowledged`, and dispatches `issue-routing-decision.lock.yml` with the issue number.

**Routing decision.** The GH-AW routing workflow runs on `workflow_dispatch`, verifies `acknowledged`, and adds either `triaged-fast-track` or `triaged-for-research` (or rejects). Its concurrency key is scoped by issue number so concurrent intake events do not cancel each other.

**Fast-track lane.** Issues labeled `triaged-fast-track` are implemented directly by the fast-track workflow, which opens a PR, adds `assigned`, and closes the issue.

**Research lane.** Issues labeled `triaged-for-research` move to `researched-waiting-opinions`, receive both opinion labels (`opinion-copilot-strategy-posted` and `opinion-copilot-delivery-posted`), then the assignment workflow adds `assigned` and closes the issue.

**Token boundary.** Downstream label-triggered stages rely on safe-outputs writes that use a PAT-backed token (`GH_AW_GITHUB_TOKEN`) so label events trigger subsequent workflows.

**Rejection path.** At any stage, an agent can add `rejected` with rationale and close the issue.

Publishing and validation remain separate automation concerns. `pages.yml` deploys the site and `build-pdf.yml` maintains the generated PDF. `check-links.yml` and `check-external-links.yml` validate internal and external links. `compile-workflows.yml` verifies that `.lock.yml` files stay in sync with their markdown sources. `copilot-setup-steps.yml` configures the coding agent environment.

## Operational Lessons from Production Runs

Running the workflows in real issue traffic surfaced several practical lessons.

**Token identity is part of the control plane.** When safe-outputs uses a PAT-backed token, workflow-created comments, labels, issues, and pull requests are attributed to that token owner instead of `github-actions[bot]`. This affects audit trails and reviewer expectations.

**Label-trigger chains require explicit token strategy.** In this repository, default-token label writes were not consistently sufficient to trigger downstream workflows. A robust pattern is to use `workflow_dispatch` for critical handoffs and reserve PAT-backed label writes for stage transitions that must emit label-trigger events.

**Concurrency should be keyed by business entity.** Routing initially used a shared concurrency group, which caused cancellations during burst issue intake. Scoping concurrency by issue identifier avoids cross-issue cancellation and preserves throughput under concurrent events.

**Failure tracking can generate meta-issues.** GH-AW failure-handling workflows may create tracker issues for failed runs. Treat these as operations artifacts, not content suggestions, and route/exclude them accordingly.

**Test sequencing matters.** Validate each lifecycle path sequentially first (reject, fast-track, slow-track), then run burst/concurrency tests. This separates logic correctness from race-condition debugging.

## Key Takeaways

GH-AW turns markdown instructions into reproducible GitHub Actions workflows, combining the readability of documentation with the reliability of automation. Frontmatter defines triggers, permissions, tools, and models, giving you fine-grained control over what the agent can do. Imports enable composable, reusable workflow building blocks that reduce duplication across repositories. Safe inputs and outputs combined with least-privilege permissions reduce the risk of unintended changes. The ResearchPlanAssign pattern provides a practical loop for continuous, agent-powered improvement with human oversight at key decision points.

<!-- Edit notes:
Sections expanded: Chapter Preview, at-a-glance list, Key parts (Frontmatter and Markdown instructions), Key Behaviors, Tools list, ResearchPlanAssign phases, Applying GH-AW to This Repository, Key Takeaways
Lists preserved: File structure layouts (must remain enumerable), code blocks (must remain as-is)
Ambiguous phrases left ambiguous: None identified
-->
