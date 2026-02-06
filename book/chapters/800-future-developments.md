---
title: "Future Developments"
order: 80
---

# Future Developments

## Chapter Preview

This chapter surveys the trajectories that are likely to reshape agentic workflows over the coming years. It identifies concrete trends already underway—protocol standardisation, framework convergence, and autonomous agent maturation—rather than speculative predictions. The goal is to help practitioners position their architectures and skill investments for the landscape that is forming now.

## The Standardisation Wave

### Interoperability Protocols

The most consequential near-term development is the maturation of open interoperability protocols. Two protocols stand out.

**Model Context Protocol (MCP)** has crossed the threshold from single-vendor project to industry infrastructure. Anthropic donated MCP governance to the Agentic AI Foundation (AAIF) under the Linux Foundation in December 2025, and as of early 2026 the ecosystem reports over 97 million monthly SDK downloads and more than 10,000 active MCP servers. First-class client support now spans Claude, ChatGPT, Cursor, Gemini, Microsoft Copilot, and Visual Studio Code. The January 2026 launch of **MCP Apps**—interactive UIs rendered directly inside MCP clients—signals that the protocol is expanding beyond tool calls into richer agent-user interaction surfaces.

The practical implication is that tool authors can now write a single MCP server and have it work across all major agent clients. Teams investing in tool infrastructure should treat MCP as the default integration layer rather than building bespoke connectors for each client.

**Agent-to-Agent (A2A) protocol**, contributed by Google to the Linux Foundation in June 2025, addresses a complementary gap: how agents discover and communicate with each other. While MCP connects agents to tools and data, A2A enables agents to collaborate in their natural modalities—exchanging tasks, status updates, and results. Built on HTTP, SSE, and JSON-RPC (with gRPC support added in version 0.3), A2A has attracted over 150 organisations to its ecosystem. For teams building multi-agent architectures that span organisational boundaries, A2A provides a standard handshake protocol.

Together, MCP and A2A form a two-layer interoperability stack: MCP for agent-to-tool communication, A2A for agent-to-agent communication. Systems that adopt both can compose capabilities across vendors and organisations without custom integration work.

### The Agent Skills Standard

The **Agent Skills** specification (<https://agentskills.io/specification>), published by Anthropic in December 2025, provides a minimal, filesystem-first format for packaging reusable agent capabilities. A skill is a directory containing a `SKILL.md` file with YAML frontmatter and markdown instructions, plus optional `scripts/`, `references/`, and `assets/` directories. The specification uses progressive disclosure: agents load skill content only when a user's request matches the skill's domain.

Adoption has been rapid. Microsoft, OpenAI, Atlassian, Figma, Cursor, and GitHub have adopted the standard, with partner-built skills from Canva, Stripe, Notion, and Zapier available at launch. The practical consequence is that skills written once can be discovered and used across agent platforms—a significant reduction in the duplication that plagued earlier approaches.

## Framework Convergence

### The Microsoft Agent Framework

In October 2025, Microsoft announced the convergence of **Semantic Kernel** and **AutoGen** into a unified **Microsoft Agent Framework**, with general availability scheduled for Q1 2026. This merger combines Semantic Kernel's enterprise plugin architecture and .NET/Python support with AutoGen's event-driven multi-agent orchestration. The resulting framework aims to be the default for enterprise agent development on Azure and beyond.

For teams currently using either Semantic Kernel or AutoGen, the migration path is through AutoGen v0.4's async, event-driven architecture, which serves as the foundation for the unified framework. The key implication is that Microsoft's agent story is consolidating rather than fragmenting, reducing the decision burden for enterprise teams.

### LangChain and LangGraph at v1.0

LangChain and LangGraph both reached v1.0 milestones, signalling API stability after a period of rapid iteration. The architecture has clarified: LangChain provides high-level agent APIs (notably `create_agent`) that build on LangGraph's graph-based runtime under the hood. Teams start with LangChain for rapid prototyping and drop down to LangGraph when they need custom control flow, stateful agents, or production-grade durability.

This layered approach—high-level convenience on top of low-level control—is becoming a pattern across the ecosystem and is worth watching as other frameworks mature.

### Cloud-Native Agent Platforms

Major cloud providers have introduced first-party agent platforms that bundle model access, tool execution, and observability.

**Amazon Bedrock AgentCore** provides serverless agent deployment with built-in memory, identity, browser, code interpreter, and observability features. Multi-agent collaboration became generally available in early 2026, allowing multiple AI agents to coordinate on complex tasks within the AWS ecosystem.

**Google Agent Development Kit (ADK)** is an open-source framework optimised for Gemini but compatible with other providers. It supports A2A protocol integration natively and recommends deployment to Vertex AI Agent Engine Runtime. Primary SDK is Python, with TypeScript and Go SDKs in active development.

**Vercel AI SDK 6** introduced first-class agent abstractions for TypeScript developers, including a `ToolLoopAgent` class, full MCP support, and durable agents through its Workflow DevKit. For teams building agent-powered web applications, this provides a natural integration path.

These platforms lower the barrier to deploying production agents by bundling infrastructure concerns (scaling, monitoring, identity) that teams would otherwise build themselves.

## The Autonomous Coding Agent Frontier

### From Assistants to Autonomous Agents

The coding agent landscape has stratified into three tiers that are likely to persist and deepen.

**IDE-integrated assistants** (GitHub Copilot, Cursor, Windsurf) provide real-time suggestions and chat within the editor. These are the most widely adopted and continue to improve, with Windsurf's acquisition by Cognition in July 2025 signalling consolidation in this tier.

**CLI-based agents** (Claude Code, Codex CLI, Aider) operate in the terminal with full repository access, making multi-file changes, running tests, and creating commits. As of February 2026, Claude and Codex are available as GitHub engines in public preview alongside Copilot, meaning all three major agent providers now integrate directly with GitHub's workflow infrastructure.

**Fully autonomous agents** (Devin) represent the frontier: agents that receive a high-level task and work through it independently over hours, handling planning, implementation, testing, and PR creation without human guidance. Cognition's $10.2 billion valuation and the growing enterprise adoption of autonomous agents suggest this tier will continue to attract investment and capability improvements.

### What This Means for Workflow Design

The practical implication is that workflow architectures need to accommodate agents at all three tiers. A production workflow might use an IDE assistant for interactive development, a CLI agent for batch operations like migration or test generation, and an autonomous agent for well-scoped tickets that can be verified automatically. Orchestration systems (including GH-AW) should be designed to assign work to the right tier based on task characteristics.

## Emerging Patterns

### Progressive Autonomy

The **progressive autonomy** pattern described in [Failure Modes, Testing, and Fixes](100-failure-modes-testing-fixes.md) is becoming the standard deployment model for production agent systems. Teams start agents in suggest-only mode, graduate to execute-with-review, and eventually allow autonomous operation for well-understood task types. This pattern is now supported directly by platforms like Amazon Bedrock AgentCore (which provides policy controls) and GH-AW (which provides safe-outputs).

The trend is toward finer-grained autonomy controls: instead of a binary autonomous/supervised switch, teams define autonomy levels per task type, per repository, or per risk category. Expect frameworks to provide richer policy languages for expressing these boundaries.

### Multi-Agent Collaboration at Scale

Early multi-agent systems used simple sequential or parallel patterns. The emerging pattern is **dynamic agent teams** where a coordinator spawns specialised agents based on task analysis, and those agents can themselves spawn sub-agents. This pattern is supported by Claude Code's subagent architecture, the OpenAI Agents SDK's handoff mechanism, and Google ADK's multi-agent framework.

The A2A protocol extends this pattern across organisational boundaries: an agent in one organisation can discover and collaborate with agents in another organisation through standardised task delegation. While early adoption is within enterprises, cross-organisation agent collaboration is a likely growth area.

### Agent Observability and Evaluation

As agents move into production, observability and evaluation are becoming first-class concerns rather than afterthoughts. Key developments include:

**Tracing standards** are emerging for tracking agent decision chains across tool calls and model invocations. The OpenAI Agents SDK includes built-in tracing, and MCP's audit capabilities provide tool-level observability.

**Evaluation frameworks** are moving beyond single-task benchmarks to scenario suites that test agent behaviour across diverse conditions, including adversarial inputs and degraded environments. The metrics outlined in [Failure Modes, Testing, and Fixes](100-failure-modes-testing-fixes.md)—task success rate, intervention rate, escaped defect rate—are becoming standard.

**Cost attribution** is becoming more sophisticated as agent workflows involve multiple model calls, tool invocations, and sub-agent spawns. Understanding per-task cost is essential for making agents economically viable at scale.

### Multimodal and Physical Agency

Multimodal agents that blend text, vision, speech, and code are becoming default rather than optional. Frameworks are adding toolchains for document understanding, UI automation, and robotic control, closing the loop between digital and physical actions. This shift matters because it expands the surface area of what an agent can verify autonomously (e.g., reading dashboards, inspecting UI states, interpreting camera feeds) without human intervention.

### Governance and Safety Automation

Regulators are increasingly demanding traceability, data minimisation, and safety controls for autonomous systems. Agent stacks are responding with policy engines that enforce allow/deny rules, runtime red-teaming, and signed skill bundles. Expect governance requirements (audit logs, privacy zones, least-privilege tool access) to become a gating factor for enterprise deployment, pushing teams to treat safety automation as a first-class feature rather than an afterthought.

## The Local-First Personal AI Wave

One of the most striking developments of late 2025 and early 2026 is the explosive growth of local-first personal AI assistants, led by **OpenClaw** (169,000+ GitHub stars, 3,000+ community skills). These are not coding agents or enterprise tools—they are general-purpose AI assistants that users self-host on their own hardware, connecting to WhatsApp, Telegram, Slack, Discord, and dozens of other channels through a single brain with shared context and persistent memory.

This trend represents a shift in who controls the agent. Where cloud-hosted AI services control the data, the model, and the interaction surface, local-first assistants put all three under user ownership. The architectural patterns—gateway/runtime separation, model-agnostic backends, plugin-based skills—mirror what enterprise agent frameworks provide, but optimised for individual users rather than organisations.

The personal AI ecosystem is diversifying rapidly. **Letta** (formerly MemGPT) focuses on sophisticated memory management, allowing agents to learn and self-improve over time. **LettaBot** brings Letta's memory to a multi-channel assistant. **Langroid** provides lightweight multi-agent orchestration. **Open Interpreter** turns natural language into computer actions. **Leon** offers a minimal, self-hosted assistant.

For the broader agentic workflows field, the personal AI wave matters for three reasons. First, it validates the architectural patterns described throughout this book—skills, tools, MCP integration, multi-agent orchestration—at consumer scale. Second, it surfaces security challenges (infostealer targeting, credential exposure, data sovereignty) that enterprise deployments will also face. Third, it demonstrates that the demand for AI agents extends far beyond software development into every domain of digital life.

## Open Questions

Several questions remain genuinely open and will shape the field's direction.

**How far can autonomous agents go?** Current autonomous agents handle well-scoped tasks with clear success criteria. Whether they can reliably handle ambiguous, open-ended work—architectural decisions, trade-off analysis, creative problem-solving—remains an open question. The answer will determine how much of software development becomes agent-driven versus agent-assisted.

**Will interoperability standards converge?** MCP and A2A address different layers of the stack, but there is no guarantee they will remain complementary rather than competing. The Linux Foundation governance of both protocols is a positive signal, but standards fragmentation remains a risk.

**How will agent security evolve?** As agents gain more autonomy and tool access, the attack surface expands. Prompt injection, tool misuse, and supply-chain attacks on skills and plugins are active research areas. The field needs security practices that scale with agent capability.

**What happens to developer roles?** The stratification of coding agents into assistants, CLI agents, and autonomous agents will reshape how development teams organise. The balance between human oversight and agent autonomy will vary by organisation, risk tolerance, and regulatory context.

**How will governance and regulation keep pace?** Jurisdictions are drafting rules for auditability, provenance, and safety thresholds. Agent platforms may need built-in certification hooks, provenance tracking, and opt-in data minimisation to satisfy region-specific requirements without forking architectures.

## Key Takeaways

**Protocol standardisation** (MCP for agent-to-tool, A2A for agent-to-agent) is reducing integration friction and enabling cross-vendor agent ecosystems. Invest in these standards now rather than building bespoke integrations.

**Framework convergence** (Microsoft Agent Framework, LangChain/LangGraph v1.0, cloud-native platforms) is simplifying the framework selection landscape. Choose frameworks based on your deployment target and existing infrastructure rather than chasing the newest option.

**The coding agent landscape** has stratified into IDE assistants, CLI agents, and autonomous agents. Design workflows that assign work to the right tier based on task characteristics and risk profile.

**Progressive autonomy** is the standard deployment model. Start supervised, measure performance, and expand autonomy incrementally based on evidence.

**Observability and evaluation** are becoming as important as agent capability. Invest in tracing, cost attribution, and scenario-based evaluation alongside agent development.

**Governance and safety automation** will shape deployment eligibility. Build policy controls, audit trails, and least-privilege defaults early to satisfy regulatory expectations.

**Local-first personal AI assistants** (OpenClaw, Letta, LettaBot) are validating enterprise agentic patterns at consumer scale, while surfacing security and data sovereignty challenges that affect the whole field.

**Open questions** around autonomy limits, standard convergence, security, and developer roles will shape the field over the next two to three years. Stay informed and maintain architectural flexibility.
