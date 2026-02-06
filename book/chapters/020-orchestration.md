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

## Key Takeaways

Orchestration is the coordination layer that turns goals into reliable execution. Without it, agents work in isolation and cannot combine their strengths. Use the simplest pattern that matches your dependency graph—sequential for linear pipelines, parallel for independent tasks, hierarchical for complex delegation, and event-driven for reactive workflows. Isolation, monitoring, and auditability are core design constraints, not afterthoughts; they make the difference between a prototype and a production system.

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

This book uses agent orchestration to keep its content current. The workflow involves six coordinated agents.

The **Issue Monitor Agent** watches for new issues containing suggestions and validates that they follow the expected format. The **Analysis Agent** determines whether a suggestion fits the book's scope and assesses its novelty and value. The **Content Agent** writes or updates content based on approved suggestions. The **Build Agent** generates markdown and PDF versions of the updated book. The **Publishing Agent** updates GitHub Pages with the new content. The **Blog Agent** creates a blog post summarising the update.

All of these agents are coordinated through GitHub Actions workflows, demonstrating how event-driven orchestration can maintain a living document.

## Challenges and Solutions

**Challenge: Agent Conflicts.** When multiple agents modify the same resources, they can overwrite each other's changes or create inconsistent state. The **solution** is to use locks, transactions, or coordinator patterns that ensure only one agent modifies a resource at a time.

**Challenge: Debugging.** Agent behaviour can be difficult to reproduce because it depends on external context, model sampling, and timing. The **solution** is to implement comprehensive logging, build replay capabilities that can recreate agent execution from recorded inputs, and create visualisations that show how agents interacted.

**Challenge: Performance.** Agent workflows can be slow when they wait for model responses or external APIs. The **solution** is to use caching for repeated queries, execute independent tasks in parallel, and set resource limits that prevent runaway costs.

**Challenge: Versioning.** Agents and their interfaces evolve, and older workflows may break when agent behaviour changes. The **solution** is to version agents and their interfaces separately, maintaining backward compatibility or providing migration paths.

## Key Takeaways

Orchestration coordinates multiple agents effectively, turning independent capabilities into coherent workflows. Choose the right pattern for your use case based on dependency structure and scaling requirements. Clear responsibilities and interfaces are essential for maintainability and debugging. Monitor and iterate on your orchestration strategies as you learn what works. Use established frameworks when possible, but be ready to customise when your needs diverge from standard patterns.

<!-- Edit notes:
Sections expanded: Chapter Preview, Coordination Mechanisms (all three subsections), Error Handling, Monitoring, Isolation, first Key Takeaways, Real-World Example, Challenges and Solutions (all four), second Key Takeaways
Lists preserved: Use cases for each pattern (converted to prose paragraphs)
Ambiguous phrases left ambiguous: None identified
-->
