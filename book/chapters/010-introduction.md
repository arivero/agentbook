---
title: "Introduction to Agentic Workflows"
order: 1
---

# Introduction to Agentic Workflows

## Chapter Preview

This chapter defines agentic workflows and explains the roles they coordinate within software systems. It establishes the terminology used throughout the rest of the book, ensuring readers share a common vocabulary. Finally, it shows where agentic workflows create practical leverage, illustrating why this paradigm is gaining traction in real-world development environments.

## What Are Agentic Workflows?

Agentic workflows represent a paradigm shift in how we approach software development and automation. Instead of writing explicit instructions for every task, we define goals and let AI agents determine the best path to achieve them.

### Key Concepts

**Agent**: An autonomous entity that can perceive its environment, make decisions, and take actions to achieve specific goals. In the context of software development, agents are AI-powered systems that can read and understand code, make modifications based on requirements, test and verify changes, and interact with development tools and APIs. These capabilities allow agents to participate meaningfully in development workflows rather than merely responding to isolated queries.

**Workflow**: A sequence of operations orchestrated to accomplish a complex task. Agentic workflows differ from traditional workflows in three important ways. First, they are **adaptive**, meaning agents can modify their approach based on feedback rather than following a fixed script. Second, they are **goal-oriented**, focusing on outcomes rather than rigid procedures—if one path fails, the agent can try alternatives. Third, they are **context-aware**, understanding the broader context of their actions so they can make informed decisions about what to do next.

### Terminology and Roles

To keep the manuscript consistent, we use the following terms throughout.

An **agentic workflow** (the primary term in this book) is a goal-directed, tool-using workflow executed by one or more agents. A **tool** is a capability exposed through a protocol, such as an API, command-line interface (CLI), or Model Context Protocol (MCP) server. A **skill** is a packaged, reusable unit of instructions and/or code; see [Skills and Tools Management](040-skills-tools.md) for a detailed treatment.

Beyond these core terms, several role-specific components appear frequently. An **orchestrator** is the component that sequences work across agents, deciding which agent handles which task. A **planner** is the component that decomposes high-level goals into discrete steps an agent can execute. An **executor** is the component that performs actions and records results. A **reviewer** is the component—often a human—that approves, rejects, or requests changes to agent output.

> **Warning:** Prompt injection is a primary risk for agentic workflows. Treat external content as untrusted input and require explicit tool allowlists and human review for risky actions.

### Why Agentic Workflows?

Traditional automation has inherent limitations. It is **rigid**, relying on predefined steps that cannot adapt to unexpected situations. It is **fragile**, breaking when conditions change even slightly from what was anticipated. And it has **limited scope**, handling only well-defined, narrow tasks that fit the script exactly.

Agentic workflows address these problems through three key characteristics. The first is **flexibility**: agents can adapt to changing requirements and conditions because they reason about goals rather than following fixed instructions. The second is **intelligence**: agents understand intent and make informed decisions, choosing among alternatives rather than failing when a single path is blocked. The third is **scalability**: agents can handle increasingly complex tasks through composition, combining multiple agents and tools to tackle problems that would overwhelm a monolithic script.

## Real-World Applications

### Software Development

In software development, agentic workflows can automate code reviews and improvements, identifying issues that static analysis might miss and suggesting concrete fixes. They can handle bug fixing and testing, tracing failures to root causes and generating patches. Documentation generation and updates become more maintainable when agents can detect when docs drift from code. Dependency management benefits from agents that can evaluate upgrade paths and test compatibility automatically.

### Content Management

Content management is another area where agentic workflows excel. Self-updating documentation—like this book—uses agents to incorporate community feedback and keep material current. Blog post generation and curation can be partially automated, with agents drafting content that humans refine. Translation and localisation workflows benefit from agents that understand context rather than translating word by word.

### Operations

Operations teams use agentic workflows to manage Infrastructure as Code, detecting configuration drift and proposing corrections. Automated incident response can triage alerts, gather diagnostic information, and suggest remediation steps. Performance optimisation workflows can identify bottlenecks, test configuration changes, and roll back if metrics degrade.

## The Agent Development Lifecycle

The agent development lifecycle proceeds through five stages. The first stage is **Define Goals**, where you specify what you want to achieve in terms an agent can act upon—clear success criteria and boundaries help agents stay on track. The second stage is **Configure Agents**, where you set up agents with appropriate tools and permissions; this includes selecting which capabilities agents may use and which they must avoid. The third stage is **Execute Workflows**, where agents work toward goals autonomously, invoking tools, interpreting results, and adapting their approach as needed. The fourth stage is **Monitor and Refine**, where you review outcomes and improve agent behaviour based on what worked and what did not. The fifth stage is **Scale**, where you compose multiple agents for complex tasks, dividing responsibilities so that each agent can focus on what it does best.

## Getting Started

To work with agentic workflows, you need several foundational elements. You need an understanding of AI/LLM capabilities and limitations so you can anticipate where agents will succeed and where they may struggle. You need familiarity with the problem domain so you can specify goals that make sense and evaluate agent output critically. You need tools and frameworks for agent development, which may range from orchestration libraries to managed platforms. And you need infrastructure for agent execution, including compute resources, API access, and observability tooling.

In the following chapters, we explore how to orchestrate agents, build scaffolding for agent-driven systems, and manage skills and tools effectively.

## Key Takeaways

Agentic workflows enable flexible, intelligent automation that adapts to changing conditions rather than breaking when the unexpected occurs. Consistent terminology—using terms like orchestrator, planner, executor, and reviewer with precise meanings—prevents confusion as systems scale and teams grow. Security and human review guardrails are non-negotiable for production use; agents must operate within clearly defined boundaries, and humans must approve consequential changes. The rest of the book builds on these core concepts, exploring orchestration patterns, scaffolding architecture, and practical tool management.

<!-- Edit notes:
Sections expanded: Chapter Preview, Key Concepts (Agent and Workflow definitions), Terminology and Roles, Why Agentic Workflows, Real-World Applications (all three subsections), The Agent Development Lifecycle, Getting Started, Key Takeaways
Lists preserved: None (all original lists were shorthand that read better as prose)
Ambiguous phrases left ambiguous: None identified
-->
