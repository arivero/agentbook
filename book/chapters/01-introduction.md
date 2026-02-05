---
title: "Introduction to Agentic Workflows"
order: 1
---

# Introduction to Agentic Workflows

## Chapter Preview

- Define agentic workflows and the roles they coordinate.
- Establish the terminology used throughout the book.
- Show where agentic workflows create leverage in practice.

## What Are Agentic Workflows?

Agentic workflows represent a paradigm shift in how we approach software development and automation. Instead of writing explicit instructions for every task, we define goals and let AI agents determine the best path to achieve them.

### Key Concepts

**Agent**: An autonomous entity that can perceive its environment, make decisions, and take actions to achieve specific goals. In the context of software development, agents are AI-powered systems that can:
- Read and understand code
- Make modifications based on requirements
- Test and verify changes
- Interact with development tools and APIs

**Workflow**: A sequence of operations orchestrated to accomplish a complex task. Agentic workflows differ from traditional workflows by being:
- **Adaptive**: Agents can modify their approach based on feedback
- **Goal-oriented**: Focus on outcomes rather than rigid procedures
- **Context-aware**: Understanding the broader context of their actions

### Terminology and Roles

To keep the manuscript consistent, we use the following terms throughout:

- **Agentic workflow** (primary term): A goal-directed, tool-using workflow executed by one or more agents.
- **Tool**: A capability exposed through a protocol (for example, an API, CLI, or MCP server).
- **Skill**: A packaged, reusable unit of instructions and/or code (see [Skills and Tools Management](04-skills-tools.md)).
- **Orchestrator**: The component that sequences work across agents.
- **Planner**: The component that decomposes goals into steps.
- **Executor**: The component that performs actions and records results.
- **Reviewer**: The component (often a human) that approves, rejects, or requests changes.

> **Warning:** Prompt injection is a primary risk for agentic workflows. Treat external content as untrusted input and require explicit tool allowlists and human review for risky actions.

### Why Agentic Workflows?

Traditional automation has limitations:
- **Rigid**: Predefined steps that can't adapt to unexpected situations
- **Fragile**: Breaking when conditions change
- **Limited scope**: Only handling well-defined, narrow tasks

Agentic workflows solve these problems by:
1. **Flexibility**: Adapting to changing requirements and conditions
2. **Intelligence**: Understanding intent and making informed decisions
3. **Scalability**: Handling increasingly complex tasks through composition

## Real-World Applications

### Software Development
- Automated code reviews and improvements
- Bug fixing and testing
- Documentation generation and updates
- Dependency management

### Content Management
- Self-updating documentation (like this book!)
- Blog post generation and curation
- Translation and localization

### Operations
- Infrastructure as Code management
- Automated incident response
- Performance optimization

## The Agent Development Lifecycle

1. **Define Goals**: Specify what you want to achieve
2. **Configure Agents**: Set up agents with appropriate tools and permissions
3. **Execute Workflows**: Agents work toward goals autonomously
4. **Monitor and Refine**: Review outcomes and improve agent behavior
5. **Scale**: Compose multiple agents for complex tasks

## Getting Started

To work with agentic workflows, you need:
- Understanding of AI/LLM capabilities and limitations
- Familiarity with the problem domain
- Tools and frameworks for agent development
- Infrastructure for agent execution

In the following chapters, we'll explore how to orchestrate agents, build scaffolding for agent-driven systems, and manage skills and tools effectively.

## Key Takeaways

- Agentic workflows enable flexible, intelligent automation.
- Consistent terminology prevents confusion as systems scale.
- Security and human review guardrails are non-negotiable for production use.
- The rest of the book builds on these core concepts.
