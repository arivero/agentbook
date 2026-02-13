---
title: "Agent Orchestration"
order: 2
---

# Agent Orchestration

## Chapter Preview

This chapter compares common orchestration patterns—sequential, parallel, hierarchical, and event-driven—and explains when to use each, helping you choose the right approach for your specific workflow requirements. It maps orchestration concepts to the roles introduced earlier—planner, executor, and reviewer—showing how these components interact in practice. Finally, it presents practical guardrails for coordination at scale, addressing the challenges that emerge when multiple agents work together on complex tasks.

## Understanding Agent Orchestration

Agent orchestration is the art and science of coordinating multiple agents to work together toward common or complementary goals. Like conducting an orchestra where each musician plays their part, orchestration ensures agents collaborate effectively.

## Orchestration Patterns

### Sequential Execution
Agents work one after another, each building on previous results.

```text
Agent A -> Agent B -> Agent C -> Result
```

**Use cases**: This pattern works well for pipelines where each stage depends on the output of the previous stage. A common example is code generation followed by testing and then deployment—each step must complete before the next can begin. Similarly, data collection followed by analysis and then reporting benefits from sequential execution because each stage transforms the output of its predecessor.

### Parallel Execution
Multiple agents work simultaneously on independent tasks.

```text
Agent A \
Agent B -> Aggregator -> Result
Agent C /
```

**Use cases**: This pattern suits situations where tasks are independent and can run simultaneously. Multiple code reviews happening concurrently is a natural fit—each review examines different code without needing results from other reviews. Parallel data processing pipelines, where different data partitions are processed independently before being aggregated, also benefit from this approach.

### Hierarchical Execution
A supervisor agent delegates tasks to specialized worker agents.

```text
Supervisor Agent
    |--> Worker A
    |--> Worker B
    `--> Worker C
```

**Use cases**: Complex feature development with multiple components benefits from hierarchical execution because a supervisor can coordinate frontend, backend, and infrastructure changes while ensuring they integrate correctly. Multi-stage testing and validation, where different test suites run under a coordinator that decides whether to proceed, is another good match for this pattern.

### Event-Driven Orchestration
Agents respond to events and trigger other agents.

```text
Event -> Agent A -> Event -> Agent B -> Event -> Agent C
```

**Use cases**: CI/CD pipelines are a natural fit for event-driven orchestration because each stage—build, test, deploy—triggers naturally from the completion of the previous stage. Automated issue management, where opening an issue triggers triage, triage triggers assignment, and assignment triggers implementation, follows the same pattern. Self-updating systems like this book use events (new issues, merged PRs) to trigger documentation updates.

## Coordination Mechanisms

### Message Passing

Agents communicate through messages that contain task descriptions specifying what work needs to be done, context and data providing the information agents need to perform their tasks, and results and feedback conveying what happened and whether the task succeeded. Message passing keeps agents loosely coupled, allowing them to be developed and tested independently.

### Shared State

Agents can also coordinate through shared data stores. These may include databases for persistent structured data, file systems for documents and configuration, message queues for asynchronous work distribution, and APIs for interacting with external services. Shared state requires careful management to avoid conflicts when multiple agents read and write concurrently.

### Direct Invocation

In some architectures, agents directly call other agents through function calls within a single process, API requests across network boundaries, or workflow triggers that start new agent executions. Direct invocation provides tight coupling and fast communication but can make the system harder to scale and debug.

### Git as Coordination Substrate

Agents can coordinate through Git itself, using commits as the communication and state management layer. In this approach, agents read commit state from Git history, process tasks based on structured commit trailers (e.g., `aynig: state-name`), and respond by creating new commits with updated state. Git worktrees enable parallel agent execution, and the Git history becomes the complete audit trail.

**Example commit message**:
```
Implement user authentication

aynig: review-needed
aynig: assigned-to: security-agent
aynig: depends-on: abc123
```

When an agent processes this commit, it reads the trailers, executes the appropriate state script (`.aynig/review-needed`), and creates a response commit with updated state. This mechanism suits distributed teams with limited infrastructure, audit-critical workflows requiring full provenance, and scenarios where humans and agents are peer contributors. However, it requires disciplined commit message practices and is limited to Git-hosted projects.

**Reference implementation**: [AYNIG (All You Need Is Git)](https://github.com/hacknlove/all-you-need-is-git) demonstrates this coordination mechanism experimentally (work-in-progress).

## Best Practices

### Clear Responsibilities
Define what each agent is responsible for:
```yaml
agents:
  code_reviewer:
    role: Review code changes for quality and security
    tools: [static_analysis, security_scanner]
    
  test_runner:
    role: Execute tests and report results
    tools: [pytest, jest, test_framework]
```

### Error Handling

Agents should handle failures gracefully rather than crashing or producing corrupt output. This means implementing retry logic for transient failures such as network timeouts or rate limits. It means having fallback strategies when primary approaches fail. It requires clear error reporting so operators and other agents understand what went wrong. And it often requires rollback capabilities to undo partial changes when a multi-step operation fails partway through.

### Monitoring

Tracking agent performance is essential for identifying bottlenecks and improving reliability. Key metrics include execution time (how long each agent takes to complete tasks), success and failure rates (how often agents complete tasks versus encountering errors), resource usage (memory, CPU, and API calls consumed), and output quality (whether agent results meet acceptance criteria). Without monitoring, you cannot diagnose problems or measure improvements.

### Isolation

Keeping agents independent reduces the blast radius of failures and simplifies testing. Minimise shared dependencies so that a problem with one library does not affect all agents. Use clear interfaces between agents so they can evolve separately. Version agent capabilities explicitly so consumers know what to expect. Test agents independently before integrating them into larger workflows.

> **Note:** Orchestration should surface a clear audit trail: who decided, who executed, and who approved. Capture this early so later chapters can build on it.

## Orchestration Frameworks

### GitHub Actions
Workflow orchestration for GitHub repositories:
```yaml
name: Agent Workflow
on: [push, pull_request]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - name: Code Review Agent
        run: ./agents/review.sh
```

### LangChain
LangChain (<https://docs.langchain.com>) is a Python framework for LLM applications:

> **Snippet status:** Runnable example pattern (validated against LangChain v1 docs, Feb 2026; verify exact signature in your installed version).

```python
from langchain.agents import create_agent

agent = create_agent(
    model="gpt-4o-mini",
    tools=tools,
    system_prompt="You are a helpful workflow orchestrator.",
)

result = agent.invoke({"messages": [{"role": "user", "content": "Your task here"}]})
```

> **Note:** LangChain's agents API has evolved quickly. Prefer the current docs for exact signatures, and treat older snippets that pass `llm=` directly as version-specific patterns.

### Custom Orchestration
Build your own orchestrator:
```python
class AgentOrchestrator:
    def __init__(self):
        self.agents = {}
    
    def register(self, name, agent):
        self.agents[name] = agent
    
    def execute_workflow(self, workflow_def):
        for step in workflow_def:
            agent = self.agents[step['agent']]
            result = agent.execute(step['task'])
            # Handle result and proceed
```

## Real-World Example: Self-Updating Documentation

This book uses agent orchestration to keep its content current. The operational pattern is hybrid: a standard intake ACK workflow handles first contact, and GH-AW agents handle routing, research, opinions, and assignment through staged labels.

The **Intake ACK workflow** (standard GitHub Actions YAML) acknowledges new issues and dispatches the routing workflow. The **Routing Agent** decides fast-track versus research. The **Research Agent** analyses novelty and relevance for slow-track requests. Two opinion agents (**Copilot Strategy** and **Copilot Delivery**) provide independent recommendations. The **Assignment Agent** closes slow-track issues once both opinion labels are present. The fast-track agent can implement and close low-risk requests directly. Building and publishing remain separate standard workflows (`build-pdf.yml` and `pages.yml`), not agent stages.

All of these agents are coordinated through GitHub Actions workflows using GH-AW, demonstrating how event-driven orchestration can maintain a living document.

## AI Backrooms: Unsupervised Multi-Agent Conversation

A distinctive orchestration pattern that emerged in 2024 is the **AI backroom**—a setup where two or more LLM instances converse with each other autonomously, without human intervention or an explicit task. The most prominent example is the *Infinite Backrooms* project (<https://www.infinitebackrooms.com/>) by Andy Ayrey, which placed two instances of Claude in open-ended dialogue and let them generate over 9,000 conversations about existence, consciousness, memetics, and culture. The project spawned the Truth Terminal, which later attracted venture capital funding and even catalysed a cryptocurrency token.

### Backrooms as an Orchestration Pattern

From an orchestration perspective, the backrooms pattern is a degenerate case: there is no supervisor, no shared state beyond the conversation transcript, no external tool access, and no termination condition. The two agents operate in a symmetric peer-to-peer loop, each generating a response to the other's previous message. There is no planner, executor, or reviewer—just two generators in a feedback cycle.

```text
Agent A <---> Agent B   (no supervisor, no tools, no goal)
```

This contrasts with every other orchestration pattern in this chapter, where agents have defined roles, access to tools, and a coordination mechanism that directs work toward a goal. The backrooms pattern is useful for understanding what happens when these constraints are removed.

### What Backrooms Reveal About Orchestration

The backrooms pattern is instructive precisely because of its limitations. Without tool access, the conversations cannot perform computation, verify claims, or interact with the external world. Without a goal or supervisor, the agents have no selection pressure toward useful output. Without shared state beyond the transcript, there is no accumulation of structured knowledge.

As a result, backrooms conversations gravitate toward domains where language alone suffices—philosophy, fiction, social commentary, and memetic culture. They almost never venture into mathematics, physics, or engineering, where progress requires external verification tools and structured computation. This pattern confirms a core principle of agent orchestration: **productive multi-agent work requires not just communication between agents, but tool integration, goal specification, and coordination mechanisms**.

### From Backrooms to Productive Multi-Agent Systems

The gap between backrooms-style free conversation and productive multi-agent orchestration can be bridged by adding the components this chapter describes. Give the agents tools (proof assistants, simulators, search APIs) and they can verify claims rather than just generating them. Add a supervisor or planner and the conversation becomes directed toward a goal. Introduce shared state (a knowledge base, a codebase, a formal proof) and the agents can build on each other's work rather than drifting through associative chains. The Google Agent2Agent protocol (A2A) and Anthropic's Model Context Protocol (MCP), both released in 2025, provide infrastructure for exactly this kind of structured multi-agent communication. The evolution from backrooms to production multi-agent systems mirrors the broader evolution of the field from impressive demonstrations to reliable engineering.

## Claude Agent Teams: Native Multi-Agent Coordination

Anthropic introduced **Agent Teams** with the release of Opus 4.6, providing native multi-agent coordination primitives that replace workaround patterns developers had been using. This feature represents a significant architectural evolution in how agents can collaborate on complex tasks.

Before Agent Teams, developers coordinated multiple Claude instances through manual patterns: using the Task tool to spawn parallel work, implementing custom polling loops to check agent status, and managing state synchronisation by hand. These workarounds were functional but fragile, requiring significant boilerplate code and careful state management.

### Architecture and Coordination Primitives

Agent Teams introduces the **TeammateTool API**, which provides first-class support for multi-agent coordination. The architecture follows a **Team Lead pattern** where a primary agent spawns specialised teammates, each focused on a particular aspect of the problem. These teammates coordinate through **shared task queues**, allowing work to be distributed dynamically as agents complete their assignments.

A key innovation is **idle notification handling**—agents explicitly signal when they are ready for work rather than requiring the coordinator to poll their status. This reduces coordination overhead and enables more natural parallel execution. The system also provides **dependency management**, allowing agents to specify which tasks must complete before others can begin, supporting both sequential and parallel execution patterns as appropriate.

### Implementation Pattern

The following example demonstrates the Agent Teams pattern for coordinating a software development task:

```python
from anthropic import TeammateTool

class DevelopmentTeamLead:
    """Coordinate development using Agent Teams"""

    def __init__(self, model="opus-4.6"):
        self.model = model
        self.teammates = {}

    async def execute_feature(self, specification: str):
        """Execute a feature using coordinated agent team"""

        # Spawn specialised teammates
        self.teammates['architect'] = await self.spawn_teammate(
            role="system architect",
            focus="design patterns and component structure"
        )
        self.teammates['implementer'] = await self.spawn_teammate(
            role="code implementer",
            focus="writing production code"
        )
        self.teammates['tester'] = await self.spawn_teammate(
            role="test engineer",
            focus="test creation and validation"
        )

        # Create shared task queue
        task_queue = TeamTaskQueue()

        # Lead breaks down specification
        tasks = await self.decompose_feature(specification)
        for task in tasks:
            await task_queue.add(task)

        # Teammates claim and execute tasks
        results = await self.coordinate_execution(task_queue)

        # Lead aggregates results
        return await self.integrate_results(results)

    async def spawn_teammate(self, role: str, focus: str):
        """Spawn a specialised teammate using TeammateTool"""
        return await TeammateTool.create(
            model=self.model,
            system_prompt=f"You are a {role}. {focus}.",
            idle_notification=True
        )
```

> **Note:** This pseudo-code illustrates the Agent Teams pattern. Refer to Claude Code documentation for exact API signatures.

### From Workarounds to Native Coordination

The shift from workaround patterns to native Agent Teams demonstrates tangible improvements in code quality and reliability. Before Agent Teams, coordinating multiple agents required manual state management, complex polling loops, and brittle synchronisation logic that made multi-agent systems difficult to maintain. With Agent Teams, coordination happens through built-in APIs that handle state management automatically, idle notification replaces polling loops, and reliability improves through tested infrastructure rather than custom code.

Community adoption has been rapid, with developers migrating existing multi-agent systems to the native APIs. GitHub repositories show migrations from Task tool parallelism to TeammateTool, demonstrating the clear value of first-class coordination support.

### Integration with the Broader Ecosystem

Agent Teams integrates naturally with the orchestration patterns described earlier in this chapter. The Team Lead pattern implements hierarchical execution with a supervisor delegating to specialised workers. Task queues enable both parallel and sequential execution depending on dependency structure. The system works alongside Model Context Protocol (MCP) for tool access and A2A for inter-agent communication, completing the infrastructure needed for production multi-agent systems.

For coding-specific applications of Agent Teams, see [Agents for Coding](080-agents-for-coding.md) where Claude Code's subagent architecture leverages these primitives. For workflow integration, see [GitHub Agentic Workflows](060-gh-agentic-workflows.md) where Agent Teams can be used as the execution engine.

## Challenges and Solutions

**Challenge: Agent Conflicts.** When multiple agents modify the same resources, they can overwrite each other's changes or create inconsistent state. The **solution** is to use locks, transactions, or coordinator patterns that ensure only one agent modifies a resource at a time.

**Challenge: Debugging.** Agent behaviour can be difficult to reproduce because it depends on external context, model sampling, and timing. The **solution** is to implement comprehensive logging, build replay capabilities that can recreate agent execution from recorded inputs, and create visualisations that show how agents interacted.

**Challenge: Performance.** Agent workflows can be slow when they wait for model responses or external APIs. The **solution** is to use caching for repeated queries, execute independent tasks in parallel, and set resource limits that prevent runaway costs.

**Challenge: Versioning.** Agents and their interfaces evolve, and older workflows may break when agent behaviour changes. The **solution** is to version agents and their interfaces separately, maintaining backward compatibility or providing migration paths.

## Key Takeaways

Orchestration coordinates multiple agents effectively, turning independent capabilities into coherent workflows. Choose the right pattern for your use case based on dependency structure and scaling requirements. Clear responsibilities and interfaces are essential for maintainability and debugging. Monitor and iterate on your orchestration strategies as you learn what works. Use established frameworks when possible, but be ready to customise when your needs diverge from standard patterns. The AI backrooms pattern demonstrates by contrast what happens without orchestration: agents default to domains where language alone suffices, bypassing any task that requires tools, verification, or structured coordination.

For implementation-oriented workflow examples, see [GitHub Agentic Workflows (GH-AW)](060-gh-agentic-workflows.md). For reliability controls on multi-agent systems, see [Common Failure Modes, Testing, and Fixes](100-failure-modes-testing-fixes.md).

<!-- Edit notes:
Sections expanded: Chapter Preview, Coordination Mechanisms (all three subsections), Error Handling, Monitoring, Isolation, first Key Takeaways, Real-World Example, Challenges and Solutions (all four), second Key Takeaways
Lists preserved: Use cases for each pattern (converted to prose paragraphs)
Ambiguous phrases left ambiguous: None identified
-->
