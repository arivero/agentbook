---
title: "GitHub Agents"
order: 7
---

# GitHub Agents

## Chapter Preview

This chapter describes how agents operate inside GitHub issues, pull requests, and Actions, providing practical context for building agent-powered workflows. It shows safe assignment, review, and approval flows that keep humans in control of consequential changes. Finally, it maps GitHub agent capabilities to real repository workflows, demonstrating patterns you can adapt for your own projects.

## Understanding GitHub Agents

GitHub Agents represent a new paradigm in software development automation. They are AI-powered assistants that can understand context, make decisions, and take actions within the GitHub ecosystem. Unlike traditional automation that follows predefined scripts, agents can adapt to situations, reason about problems, and collaborate with humans and other agents.

This chapter explores the landscape of GitHub Agents, their capabilities, and how to leverage them effectively in your development workflows.

## The GitHub Agent Ecosystem

### GitHub Copilot

GitHub Copilot (<https://docs.github.com/en/copilot>) is the foundation of GitHub's AI-powered development tools. It provides **code completion** with real-time suggestions as you type, predicting the code you're likely to write next. It offers a **chat interface** for natural language conversations about code, allowing you to ask questions and request explanations. And it provides **context awareness**, understanding your codebase and intent so suggestions fit your project's patterns and conventions.

```python
# Example: Copilot helping write a function
# Just start typing a comment describing what you need:
# Function to validate email addresses using regex
def validate_email(email):
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))
```

### GitHub Copilot Coding Agent

The Coding Agent extends Copilot's capabilities to autonomous task completion. See <https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent> for the supported assignment and review flow.

The Coding Agent can receive **assigned tasks** from issues or requests and work independently without continuous human guidance. It supports **multi-file changes**, modifying multiple files across a codebase in a single operation. It handles **pull request creation**, generating complete PRs with descriptions that explain what changed and why. And it supports **iterative development**, responding to review feedback and making additional changes based on comments.

**Key Characteristics:**

| Feature | Description |
|---------|-------------|
| Autonomy | Works independently on assigned tasks |
| Scope | Can make changes across entire repositories |
| Output | Creates branches, commits, and pull requests |
| Review | All changes go through normal PR review |

### GitHub Actions Agents

Agents can be orchestrated through GitHub Actions workflows:

```yaml
name: Agent Workflow
on:
  issues:
    types: [opened]

jobs:
  agent-task:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - name: Process with Agent
        uses: actions/github-script@v8
        with:
          script: |
            // Agent logic to analyze and respond
            const issue = context.payload.issue;
            // ... agent processing
```

> **Tip:** In production workflows, pin third-party actions to a full commit SHA to reduce supply-chain risk.

> **Warning:** Require human approval before any agent-created PR is merged, and log all agent actions for auditability.

## Agent Capabilities

### Reading and Understanding

Agents can read and understand various types of content within a repository. They can process **code**, including source files, configurations, and dependency manifests. They can interpret **documentation** such as READMEs, wikis, and inline comments. They can analyse **issues and pull requests**, including descriptions, comments, and reviews. And they can comprehend **repository structure**, recognising file organisation patterns and project conventions.

### Writing and Creating

Agents can produce several types of output. They can make **code changes**, creating new files, modifying existing ones, or refactoring for improved structure. They can write **documentation**, including READMEs, inline comments, and API docs. They can create **issues and comments**, posting status updates and analysis reports. And they can generate **pull requests** with complete descriptions that explain the changes.

### Reasoning and Deciding

Agents can perform higher-level cognitive tasks. They can **analyse problems**, understanding issue context and requirements to identify what needs to be done. They can **plan solutions**, breaking down complex tasks into manageable steps. They can **make decisions**, choosing between alternative approaches based on trade-offs. And they can **adapt**, responding to feedback and changing requirements rather than failing when conditions shift.

## Multi-Agent Orchestration

### Why Multiple Agents?

Single agents have limitations in capability, perspective, and throughput. Multi-agent systems address these through four key benefits.

**Specialisation** allows each agent to excel at specific tasks, with dedicated agents for code review, documentation, testing, and other concerns. **Perspective diversity** means different models bring different strengths—one model may be better at security analysis while another excels at explaining concepts clearly. **Scalability** enables parallel processing of independent tasks, reducing total time to completion. **Resilience** ensures that failure of one agent does not stop the workflow; other agents can continue working or pick up where the failed agent left off.

### Orchestration Patterns

#### Sequential Pipeline

Agents work in sequence, each building on the previous:

```text
Issue -> ACK Agent -> Research Agent -> Writer Agent -> Review Agent -> Complete
```

**Example workflow stages:**

```yaml
jobs:
  stage-1-acknowledge:
    runs-on: ubuntu-latest
    if: github.event.action == 'opened'
    # Acknowledge and validate
    
  stage-2-research:
    runs-on: ubuntu-latest
    needs: stage-1-acknowledge
    if: needs.stage-1-acknowledge.outputs.is_relevant == 'true'
    # Research and analyze
    
  stage-3-write:
    runs-on: ubuntu-latest
    needs: stage-2-research
    # Create content
```

#### Parallel Discussion

Multiple agents contribute perspectives simultaneously:

```yaml
jobs:
  discuss:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        agent: [claude, copilot, gemini]
    steps:
      - name: Agent Perspective
        # Each agent provides its view
```

#### Human-in-the-Loop

Agents work until human decision is needed:

```text
Agents work -> Human checkpoint -> Agents continue
```

This pattern is essential for approving significant changes that have broad impact, resolving ambiguous decisions where judgement is required, and ensuring quality assurance before changes reach production.

### Agent Handoff Protocol

When agents need to pass context to each other, they follow a structured handoff protocol.

**State in labels.** Agents use GitHub labels to track workflow stage, allowing both humans and other agents to see at a glance where an issue stands in the process.

**Context in comments.** Agents document their findings in issue comments, creating a persistent record of what was discovered and decided.

**Structured output.** Agents use consistent formats for machine readability, enabling downstream agents to parse and act on upstream results programmatically.

```yaml
# Example: Structured agent output
- name: Agent Report
  uses: actions/github-script@v8
  with:
    script: |
      const report = {
        stage: 'research',
        findings: [...],
        recommendation: 'proceed',
        nextAgent: 'writer'
      };
      // Store in comment or labels
```

## Implementing GitHub Agents

### Agent Definition Files

Define agents in markdown files with frontmatter:

```markdown
---
name: Research Agent
description: Analyzes issues and researches documentation
tools:
  github:
    toolsets: [issues]
  web-search:
  edit:
---

# Research Agent

You are the research agent for this repository.
Your role is to analyze suggestions and assess their value.

## Tasks
1. Search existing documentation
2. Find relevant external sources
3. Assess novelty and interest
4. Report findings
```

### Agent Configuration

Control agent behavior through configuration:

```yaml
# .github/agents/config.yml
agents:
  research:
    enabled: true
    model: copilot
    timeout: 300
    
  writer:
    enabled: true
    model: copilot
    requires_approval: true
    
safety:
  max_file_changes: 10
  protected_paths:
    - .github/workflows/
    - SECURITY.md
```

### Error Handling

Agents should handle failures gracefully:

```yaml
- name: Agent Task with Error Handling
  id: agent_task
  continue-on-error: true
  uses: actions/github-script@v8
  with:
    script: |
      try {
        // Agent logic
      } catch (error) {
        await github.rest.issues.addLabels({
          owner: context.repo.owner,
          repo: context.repo.repo,
          issue_number: context.issue.number,
          labels: ['agent-error']
        });
        await github.rest.issues.createComment({
          owner: context.repo.owner,
          repo: context.repo.repo,
          issue_number: context.issue.number,
          body: `WARNING: Agent encountered an error: ${error.message}`
        });
      }
```

## Best Practices

### Clear Agent Personas

Give each agent a clear identity and responsibility:

```markdown
## You Are: The Research Agent

**Your Role:** Investigate and analyze
**You Are Not:** A decision maker or implementer
**Hand Off To:** Writer Agent after research is complete
```

### Structured Communication

Use consistent formats for agent-to-agent communication:

```markdown
## Agent Report Format

### Status: [Complete/In Progress/Blocked]
### Findings:
- Finding 1
- Finding 2
### Recommendation: [Proceed/Revise/Decline]
### Next Stage: [stage-name]
```

### Human Checkpoints

Always include human review points at critical junctures. Review should happen before significant changes that could affect production systems or user experience. Review should happen after agent recommendations, ensuring a human validates the suggested course of action. And review should happen before closing issues, confirming that the work is complete and meets requirements.

### Audit Trail

Maintain visibility into agent actions throughout the workflow. All agent actions should be visible in comments, creating a complete record of what happened. Use labels to track workflow state, making progress visible at a glance. Log important decisions and reasoning so future reviewers can understand why choices were made.

### Graceful Degradation

Design for agent failures rather than assuming they will not occur. Use `continue-on-error` for non-critical steps so that failures do not halt the entire workflow. Provide manual fallback options that humans can use when automated approaches fail. Alert maintainers when intervention is needed, ensuring problems are addressed promptly.

## Security Considerations

### Least Privilege

Agents should have minimal permissions:

```yaml
permissions:
  contents: read  # Only write if needed
  issues: write   # To comment and label
  pull-requests: write  # Only if creating PRs
```

### Input Validation

Validate data before agent processing:

```javascript
// Validate issue body before processing
const body = context.payload.issue.body || '';
if (body.length > 10000) {
  throw new Error('Issue body too long');
}
```

### Output Sanitization

Sanitize agent outputs:

```javascript
// Escape user content in agent responses
const safeTitle = issueTitle.replace(/[<>]/g, '');
```

### Protected Resources

Prevent agents from modifying sensitive files:

```yaml
# In workflow: check protected paths
- name: Check Protected Paths
  run: |
    CHANGED_FILES=$(git diff --name-only HEAD~1)
    if echo "$CHANGED_FILES" | grep -E "^(SECURITY|\.github/workflows/)"; then
      echo "Protected files modified - requires human review"
      exit 1
    fi
```

## Real-World Example: This Book

This very book uses GitHub Agents for self-maintenance:

### The Multi-Agent Workflow

1. **ACK Agent**: Acknowledges new issue suggestions
2. **Research Agent**: Analyzes novelty and relevance
3. **Claude Agent**: Provides safety and clarity perspective
4. **Copilot Agent**: Provides developer experience perspective
5. **Writer Agent**: Drafts new content
6. **Completion Agent**: Finalizes and closes issues

### How It Works

```text
+-------------+     +-------------+     +-------------+
| Issue       | --> | ACK Agent   | --> | Research    |
| Opened      |     |             |     | Agent       |
+-------------+     +-------------+     +-------------+
                                               |
                                               v
+-------------+     +-------------+     +-------------+
| Complete    | <-- | Writer      | <-- | Multi-Model |
| Agent       |     | Agent       |     | Discussion  |
+-------------+     +-------------+     +-------------+
                          |
                          v
                    +-------------+
                    | Human       |
                    | Review      |
                    +-------------+
```

### Configuration

The workflow is defined using GitHub Agentic Workflows (GH-AW). The repository includes GH-AW workflows in `.github/workflows/issue-*.lock.yml` and agent definitions in `.github/agents/*.md`.

For a detailed explanation of the workflow architecture and why GH-AW is the canonical approach, see the repository's [README workflow section](../../README.md#workflows) and [WORKFLOW_PLAYBOOK.md](../../WORKFLOW_PLAYBOOK.md).

## Multi-Agent Platform Compatibility

Modern repositories need to support multiple AI agent platforms. Different coding assistants—GitHub Copilot (<https://docs.github.com/en/copilot>), Claude (<https://code.claude.com/docs>), OpenAI Codex (<https://openai.com/index/introducing-codex/>), and others—each have their own ways of receiving project-specific instructions. This section explains how to structure a repository for cross-platform agent compatibility.

### The Challenge of Agent Diversity

When multiple AI agents work with your repository, you face a coordination challenge. **GitHub Copilot** reads `.github/copilot-instructions.md` for project-specific guidance. **Claude** automatically incorporates `CLAUDE.md`; the generic `AGENTS.md` may still be useful as shared project documentation but should be explicitly referenced for reliable Claude workflows. **OpenAI Codex (GPT-5.3-Codex)** can be configured with system instructions and skills packaged via `SKILL.md` (see <https://developers.openai.com/codex>). **Generic agents** look for `AGENTS.md` as the emerging standard for project-level instructions.

> **Note:** As of February 2026, both Claude and Codex are available as GitHub engines in public preview, joining Copilot as first-class options for GitHub-integrated agentic workflows.

Each platform has slightly different expectations, but the core information they need is similar: project structure, coding conventions, build commands, and constraints.

### Repository Documentation as Agent Configuration

Your repository's documentation files serve dual purposes—they guide human contributors AND configure AI agents. Key files include:

| File | Human Purpose | Agent Purpose |
|------|---------------|---------------|
| `README.md` | Project overview | Context for understanding the codebase |
| `CONTRIBUTING.md` | Contribution guidelines | Workflow rules and constraints |
| `.github/copilot-instructions.md` | N/A | Copilot-specific configuration |
| `AGENTS.md` | N/A | Generic agent instructions |
| `CLAUDE.md` | N/A | Claude-specific configuration |

### The copilot-instructions.md File

GitHub Copilot reads `.github/copilot-instructions.md` to understand how to work with your repository. This file should include:

```markdown
# Copilot Instructions for [Project Name]

## Project Overview
Brief description of what this project does.

## Tech Stack
- **Language**: Python 3.11
- **Framework**: FastAPI
- **Database**: PostgreSQL
- **Testing**: pytest

## Coding Guidelines
- Follow PEP 8 style guide
- All functions require type hints
- Tests are required for new features

## File Structure
Describe important directories and their purposes.

## Build and Test Commands
- `make test` - Run all tests
- `make lint` - Run linters
- `make build` - Build the project

## Important Constraints
- Never commit secrets or credentials
- Protected paths: `.github/workflows/`, `secrets/`
- All PRs require review before merge
```

### Cross-Platform Strategy

For maximum compatibility across AI agent platforms, follow these practices:

1. **Pick a canonical source per platform** (`AGENTS.md` for many coding agents, `CLAUDE.md` for Claude)
2. **Cross-reference shared guidance** between platform files to reduce drift
3. **Keep instructions DRY** by avoiding unnecessary duplication
4. **Test with multiple agents** to ensure instructions work correctly

Example hierarchy:

```text
project/
|-- AGENTS.md                      # Canonical agent instructions
|-- CLAUDE.md                      # Claude-specific (may reference AGENTS.md)
|-- .github/
|   `-- copilot-instructions.md    # Copilot-specific (may reference AGENTS.md)
`-- src/
    `-- AGENTS.md                  # Module-specific instructions
```

### This Repository's Approach

This book repository demonstrates multi-platform compatibility through several mechanisms. The **`.github/copilot-instructions.md`** file provides detailed Copilot configuration with project structure, coding guidelines, and constraints. The **Skills and Tools Management** and **Agents for Coding** chapters discuss AGENTS.md as the emerging standard. The **documentation files** such as README and CONTRIBUTING provide context any agent can use. The **GH-AW workflows** use the `engine: copilot` setting but the pattern works with other engines.

The key insight is that well-structured documentation benefits both human developers and AI agents. When you write clear README files, contribution guidelines, and coding standards, you are simultaneously creating better agent configuration.

### Best Practices for Agent-Friendly Repositories

Several practices make repositories more compatible with AI agents.

**Be explicit about constraints.** Clearly state what agents should NOT do, preventing them from making changes that would violate project policies.

**Document your tech stack.** Agents perform better when they understand the tools in use, including languages, frameworks, and build systems.

**Describe the project structure.** Help agents navigate your codebase efficiently by explaining where different types of code live.

**Provide examples.** Show preferred patterns through code examples that agents can emulate.

**List protected paths.** Specify files agents should not modify, such as security-critical configuration or workflow definitions.

**Include build and test commands.** Enable agents to verify their changes work correctly before submitting them for review.

**State coding conventions.** Help agents write consistent code that matches your project's style.

## Future of GitHub Agents

### Emerging Capabilities

Several capabilities are becoming increasingly mature. **Code generation** now produces production-quality code that can be merged with minimal human editing. **Test authoring** automates test creation and maintenance, keeping test suites current as code evolves. **Documentation sync** keeps docs aligned with code, detecting when documentation drifts from implementation. **Security analysis** provides proactive vulnerability detection, identifying issues before they reach production.

### Integration Trends

Integration is deepening across several dimensions. **IDE integration** brings deeper VS Code and editor support, making agents available throughout the development workflow. **CI/CD native** support treats agents as first-class CI/CD citizens rather than add-ons. **Cross-repo** capabilities allow agents to work across multiple repositories, coordinating changes that span projects. **Multi-cloud** support enables agents to coordinate across platforms, working with infrastructure that spans providers.

## Key Takeaways

**GitHub Agents** are AI-powered assistants that can reason, decide, and act within repositories, going beyond simple autocomplete to autonomous task completion.

**Copilot Coding Agent** can autonomously complete tasks and create pull requests, working independently on assigned issues while respecting review requirements.

**Multi-agent orchestration** enables specialised, resilient, and scalable automation by dividing work among agents with different strengths.

**Human checkpoints** remain essential for quality and safety; agents propose changes but humans make final decisions on consequential modifications.

**Clear protocols** for agent communication ensure smooth handoffs, using labels, comments, and structured output to pass context between agents.

**Security** must be designed into agent workflows from the start, with least-privilege permissions, input validation, and protected paths.

**Multi-platform compatibility** is achieved through well-structured documentation including copilot-instructions.md, AGENTS.md, and related files.

**This book** demonstrates these concepts through its own multi-agent maintenance workflow, serving as a working example of the patterns described.

## Learn More

### Repository Documentation

This book's repository includes comprehensive documentation that demonstrates OSS best practices:

- **[README](../../README.md)** - Overview and quick start guide
- **[Contributing section](../../README.md#contributing)** - How to contribute using issue-driven workflows
- **[Workflows section](../../README.md#workflows)** - Publishing and validation workflow overview
- **[SETUP](../../SETUP.md)** - Installation and configuration instructions
- **[WORKFLOW_PLAYBOOK](../../WORKFLOW_PLAYBOOK.md)** - Agentic workflow maintenance patterns
- **[AGENTS](../../AGENTS.md)** - Contributor notes and required checks
- **[CLAUDE](../../CLAUDE.md)** - Repository-specific agent guidance
- **[Workflow authoring notes](../../.github/workflows/AGENTS.md)** - GH-AW compilation and lifecycle rules
- **[LICENSE](../../LICENSE)** - MIT License

### Agent Configuration Files

These files configure how AI agents work with this repository:

- **[.github/copilot-instructions.md](../../.github/copilot-instructions.md)** - GitHub Copilot-specific configuration including project structure, coding guidelines, and constraints

These documents serve as both useful references and examples of how to structure documentation for projects using agentic workflows.

### Related Sections

- **[Skills and Tools Management](040-skills-tools.md)** - Covers AGENTS.md standard and MCP protocol for tool management
- **[GitHub Agentic Workflows (GH-AW)](060-gh-agentic-workflows.md)** - GH-AW specification and engine configuration
- **[Agents for Coding](080-agents-for-coding.md)** - Detailed coverage of coding agent platforms

---

<!-- Edit notes:
Sections expanded: Chapter Preview, GitHub Copilot description, GitHub Copilot Coding Agent capabilities, Agent Capabilities (all three subsections), Why Multiple Agents, Agent Handoff Protocol, Human Checkpoints, Audit Trail, Graceful Degradation, Configuration, The Challenge of Agent Diversity, This Repository's Approach, Best Practices for Agent-Friendly Repositories, Future of GitHub Agents (both subsections), Key Takeaways
Lists preserved: Key Characteristics table (must remain tabular), code blocks (must remain as-is), file path listings (must remain enumerable for reference)
Ambiguous phrases left ambiguous: None identified
-->
