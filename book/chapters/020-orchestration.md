---
title: "Agent Orchestration"
order: 2
---

# Agent Orchestration

## Chapter Preview

This chapter compares common orchestration patterns and explains when to use each, helping you choose the right approach for your specific workflow requirements. It maps orchestration concepts to the roles introduced earlier—planner, executor, and reviewer—showing how these components interact in practice. Finally, it presents practical guardrails for coordination at scale, addressing the challenges that emerge when multiple agents work together on complex tasks.

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

Anthropic's **Agent Teams** feature, released alongside Opus 4.6 in February 2026, turns Claude's earlier subagent workarounds into a first-class orchestration primitive. Instead of hand-rolling task queues with the Task tool or polling loops, a single **team lead** agent can now spawn specialised **teammates** via the TeammateTool API, assign work, and gather results with built-in coordination signals. This shifts Claude from "one agent with a bag of tools" to "a coordinator with native teammates," reducing boilerplate while preserving deterministic control.

Agent Teams formalise several long-standing patterns:

- **Team lead + specialists.** A lead agent owns the goal, decomposes it, and spawns teammates with targeted roles such as "write tests," "refactor," or "summarise context." Teammates inherit the project context and can request clarifications from the lead rather than calling the main model recursively.
- **Shared task queues.** Tasks live in a queue that any teammate can claim. Dependencies are expressed by pushing follow-up tasks when upstream work completes, avoiding brittle manual sequencing.
- **Idle notifications.** Teammates emit ready/idle signals so the lead can keep the queue populated without tight polling loops. This reduces latency and cost while increasing parallelism.
- **Mixed parallelism.** Independent tasks execute concurrently, while dependent tasks block until prerequisites finish. The runtime, not ad hoc Python control flow, enforces ordering.

The following pseudo-code shows the pattern. It is illustrative rather than an exact SDK surface; consult Claude Code documentation for the latest signatures.

```python
class TeamLead:
    def __init__(self, teammate_tool):
        self.teammate_tool = teammate_tool
        self.teammates = []

    def build_team(self):
        self.teammates = [
            self.teammate_tool.spawn(role="planner", skills=["decompose"]),
            self.teammate_tool.spawn(role="coder", skills=["edit", "test"]),
            self.teammate_tool.spawn(role="reviewer", skills=["lint", "qa"]),
        ]

    def dispatch(self, goal):
        queue = [{"task": f"plan: {goal}", "depends_on": None}]
        self.build_team()

        while queue or any(t.is_busy() for t in self.teammates):
            idle = [t for t in self.teammates if t.is_idle()]
            for teammate in idle:
                next_task = self._pop_ready_task(queue)
                if next_task:
                    teammate.claim(next_task)
                else:
                    teammate.notify_idle()

            for teammate in self.teammates:
                if teammate.has_result():
                    result = teammate.result()
                    queue.extend(self._followups(result))

    def _pop_ready_task(self, queue):
        for idx, item in enumerate(queue):
            if item["depends_on"] is None:
                return queue.pop(idx)
        return None

    def _followups(self, result):
        if result.get("type") == "plan":
            return [{"task": step, "depends_on": None} for step in result["steps"]]
        if result.get("type") == "code_change":
            return [{"task": "review change", "depends_on": None}]
        return []
```

Compared with pre-2026 workaround patterns (Task tool parallelism, manual fan-out/fan-in loops, or nested "assistant-calls-assistant" prompts), Agent Teams provide native lifecycle hooks, idle handling, and result aggregation. The lead retains control over task boundaries and can mix synchronous checkpoints (e.g., "wait for tests before deploy") with opportunistic parallelism. Community adopters report simpler orchestrators, fewer race conditions, and clearer logs because the framework surfaces which teammate owned each task.

Agent Teams also align with other orchestration flows in this book. Chapter 6 shows how GH-AW can target Claude as an engine; Agent Teams make that engine multi-agent by default. Chapter 8 (Claude Code) describes the subagent architecture used inside coding workflows—Agent Teams now supply the primitives behind that experience. Treat the feature as an evolving capability in public preview, and revisit interface details as Anthropic hardens the API.

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
