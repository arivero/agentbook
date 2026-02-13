---
title: "Agent Platform Comparison: Google, Anthropic, and OpenAI"
order: 8.5
---

# Agent Platform Comparison: Google, Anthropic, and OpenAI

## Chapter Preview

This chapter provides a structured, vendor-neutral comparison of the three dominant agent platforms as of early 2026: Google (Gemini CLI, Vertex AI), Anthropic (Claude Code, Claude API), and OpenAI (Codex CLI, OpenAI Platform). It covers their console and CLI agents, cloud and web platforms, architecture and sandboxing approaches, tool ecosystems, multi-agent patterns, pricing, and enterprise governance. By the end you will understand each platform's strengths, trade-offs, and ideal use cases, enabling informed decisions for your own agentic workflows.

> **Note:** Treat this chapter as a dated landscape snapshot. Agent platforms evolve rapidly; verify details against current vendor documentation before making adoption decisions.

## The Three-Way Platform Race

On and around February 5, 2026, all three companies made major announcements within hours of each other: Anthropic released Claude Opus 4.6 with Agent Teams, OpenAI launched GPT-5.3-Codex and the OpenAI Frontier enterprise platform, and Google continued expanding Vertex AI Agent Builder with enhanced tool governance. This convergence underscores that the agent platform race reached full intensity in early 2026, with each vendor staking out differentiated positions.

**Google** leads on open protocols and free access. The Gemini CLI is Apache 2.0 licensed with the industry's most generous free tier, and Google created the Agent-to-Agent (A2A) protocol for cross-framework agent communication.

**Anthropic** leads on tool sophistication and developer experience. Anthropic created the Model Context Protocol (MCP), and Claude Code offers advanced capabilities like Tool Search and Programmatic Tool Calling that reduce context usage and round-trips.

**OpenAI** leads on sandboxed security and enterprise identity. The Codex CLI features native OS-level sandboxing, and the new OpenAI Frontier platform introduces per-agent identity with explicit permissions.

## Console and CLI Agents

All three vendors offer terminal-based agents that run locally and connect to cloud-hosted models for inference. Each takes a different approach to architecture, tooling, and trust boundaries.

### Google Gemini CLI

The Gemini CLI is an open-source agent (Apache 2.0) written in TypeScript and Node.js. It runs a ReAct (reason and act) loop with built-in tools, connecting to Google's Gemini models for inference. As of v0.27.0, it uses an event-driven scheduler for tool execution.

**Default model.** Gemini 3 Flash, which outperforms Gemini 2.5 Pro at three times the speed and lower cost.

**Context window.** 1 million tokens, the largest among the three CLI agents.

**Built-in tools.** `read_file`, `write_file`, `web_fetch`, `google_search` (grounding), and shell command execution. Full MCP server support via local stdio and remote transports.

**Subagent architecture.** Sub-agents are specialists that the main agent can delegate to, each with its own system prompt and restricted toolset. Sub-agents use JSON schema for input and are tracked by an AgentRegistry. Uniquely, Gemini CLI supports remote sub-agents via the A2A protocol, enabling cross-framework delegation that no other CLI agent offers natively.

**Agent Skills.** The Agent Skills format (a portable folder with `SKILL.md` following the Agent Skill Schema) is a stable feature. These skills also work in Claude Code, Copilot, and Cursor.

**Free tier.** 60 requests per minute and 1,000 requests per day with a personal Google account — the largest free allowance in the industry. Paid upgrades are available through Google AI Pro ($19.99/month) or AI Ultra subscriptions, plus enterprise options via Vertex AI.

### Anthropic Claude Code

Claude Code is Anthropic's official agentic CLI, written in TypeScript and Node.js. Unlike Gemini CLI and Codex CLI, it is proprietary (not open-source). It provides full filesystem access, Git integration, and extensibility through MCP.

**Default model.** Claude Opus 4.6, the flagship model released February 5, 2026.

**Context window.** 200,000 tokens standard, with a 1 million token beta available at premium rates.

**Built-in tools.** A rich set including file read/write, Bash execution, Glob (pattern-based file search), Grep (content search), Edit (precise string replacement), Write, NotebookEdit, WebSearch, and WebFetch. Claude Code also supports full MCP server integration.

**Subagent architecture.** Built-in subagent types include Explore (fast codebase search), Plan (implementation design), and general-purpose agents. Custom subagents can be defined with dedicated system prompts, specific tool access, independent permissions, and optional persistent memory directories. Claude Code can run up to seven simultaneous operations in parallel.

**Agent Teams.** A research preview launched with Opus 4.6 enables a lead session to spawn multiple independent teammates, each with its own full context window. The recommended configuration is two to five teammates with five to six tasks each. Teammates can message each other directly and the lead synthesizes results. In a stress test, 16 agents wrote a 100,000-line Rust C compiler across roughly 2,000 sessions.

**Advanced tool capabilities.** The Tool Search Tool (beta) lets Claude search semantically across thousands of tool definitions without loading them all into the context window, reducing token overhead by roughly 85 percent. Programmatic Tool Calling (beta) lets Claude write code in an execution container to call multiple tools without additional round-trips.

**Project instructions.** Claude Code uses `CLAUDE.md` and `AGENTS.md` convention files for per-project and per-directory instructions, giving teams fine-grained control over agent behaviour in different parts of a codebase.

### OpenAI Codex CLI

The Codex CLI is an open-source agent (Apache 2.0) written in Rust. It is the only CLI agent among the three with native OS-level sandboxing, making security a core differentiator.

**Default model.** GPT-5.3-Codex, which is 25 percent faster than GPT-5.2-Codex and combines frontier coding performance with GPT-5.2's reasoning capabilities.

**Built-in tools.** File read/write, shell commands, and web search (served from cache by default for security). MCP support is available via the Connector Registry in enterprise deployments.

**Native sandboxing.** This is Codex CLI's defining feature. On Linux, it uses bubblewrap-based sandboxing with configurable read-only access policies, shell environment controls, and approval modes. On Windows (experimental), it uses AppContainer-based sandboxing with restricted tokens and capability SIDs. In cloud mode, it runs in isolated OpenAI-managed containers with network access disabled by default. By default, agents are limited to editing files in the working folder and branch, with explicit approval required for elevated permissions.

**Parallel agents.** Codex supports multiple agents running simultaneously across projects using Git worktrees, both locally and via cloud environments. The desktop app (macOS) can orchestrate multiple AI coding agents in parallel.

### CLI Comparison Table

| Dimension | Google Gemini CLI | Anthropic Claude Code | OpenAI Codex CLI |
|---|---|---|---|
| **Language** | TypeScript/Node.js | TypeScript/Node.js | Rust |
| **License** | Apache 2.0 | Proprietary | Apache 2.0 |
| **Default model** | Gemini 3 Flash | Claude Opus 4.6 | GPT-5.3-Codex |
| **Context window** | 1M tokens | 200K (1M beta) | Varies by model |
| **Native sandbox** | No | No (hooks for validation) | Yes (bubblewrap, AppContainer) |
| **MCP support** | Consumer | Creator; producer and consumer | Consumer (via Connector Registry) |
| **A2A support** | Producer and consumer | No | No |
| **Subagent model** | Specialists + remote A2A agents | Explore/Plan/custom + Agent Teams | Parallel via worktrees |
| **Free tier** | 60 req/min, 1K req/day | None (API-based) | None (API-based) |
| **Agent Skills (SKILL.md)** | Stable | Supported | Via AgentKit |

## Cloud and Web Platforms

Beyond CLI agents, each vendor offers a cloud platform for building, deploying, and managing agents at scale. These platforms differ significantly in their approach to agent development, deployment, and governance.

### Google: AI Studio and Vertex AI Agent Builder

Google's cloud agent story spans two tiers. **AI Studio** is a browser-based prototyping environment for Gemini models, offering free access to the Gemini API for experimentation. **Vertex AI Agent Builder** is the full-stack enterprise platform for the entire agent lifecycle.

**Agent Development Kit (ADK).** An open-source Python framework (with Java support in development) for building multi-agent systems. Production-ready agents can be built in under 100 lines of Python. ADK provides a rich tool ecosystem including pre-built tools, custom functions, OpenAPI specs, and MCP tools.

**Cloud API Registry.** An enterprise governance layer where administrators curate and approve tools across the organization. Apigee integration transforms existing managed APIs into custom MCP servers, bridging the gap between existing enterprise infrastructure and agentic workflows.

**A2A protocol integration.** ADK agents can be exposed as `A2AServer` instances for cross-framework agent communication. Over 50 enterprise partners (Box, Deloitte, Elastic, PayPal, Salesforce, ServiceNow, UiPath, among others) are committed to A2A.

**Deployment.** Agents built with ADK deploy to the Vertex AI Agent Engine, with sessions and memory support now generally available. Pricing was lowered in January 2026.

### Anthropic: Claude Console and API Platform

Anthropic's cloud offering centres on the Claude Developer Platform (platform.claude.com), providing API access to all Claude models alongside the Claude Agent SDK.

**Agent SDK.** Available in both Python and TypeScript, the Agent SDK (renamed from "Claude Code SDK" to reflect its broader applicability) provides the same tools, agent loop, and context management that power Claude Code. Agents built with the SDK can autonomously read files, run commands, search the web, and edit code.

**TeammateTool.** The official multi-agent orchestration primitive, launched alongside Opus 4.6. It enables a lead agent to spawn teammates with dedicated context windows and coordinate their work through message passing.

**Computer Use.** Claude can interact with graphical user interfaces through screenshots and mouse/keyboard actions. Claude Sonnet 4.5 leads the OSWorld benchmark at 61.4 percent, making it the most capable computer-use model available. Computer Use is supported on Claude 3.5 Sonnet v2, Sonnet 4, Sonnet 4.5, Haiku 4.5, and Opus 4.

**Cowork.** A research preview desktop app (macOS) that brings agentic capabilities to knowledge work. Cowork runs with local VM access, file access, and MCP integrations, extending Claude's reach beyond coding into general productivity tasks.

**Cross-cloud availability.** Claude models are available not only through Anthropic's own API but also on AWS Bedrock and Google Cloud Vertex AI, giving enterprises flexibility in where they run inference.

### OpenAI: ChatGPT and API Platform

OpenAI has consolidated its platform around the **Responses API** (replacing the Assistants API, which sunsets August 26, 2026) and launched **OpenAI Frontier** as the enterprise agent platform.

**Responses API.** A simpler interaction model compared to the Assistants API: send input items, receive output items. It includes built-in tools for web search, file search, and computer use. The Conversations API adds durable threads and replayable state for long-running agent interactions.

**Agents SDK.** An open-source Python SDK that is the production-ready evolution of Swarm. Core primitives include Agents (LLMs plus instructions plus tools), Handoffs (agent-to-agent delegation), and Guardrails (input/output validation). Built-in tracing enables visualization, debugging, evaluation, and fine-tuning.

**AgentKit.** A suite of tools for building and deploying agents. Agent Builder provides a visual canvas for composing multi-agent workflows with drag-and-drop nodes, preview runs, inline evaluation, and full versioning (beta). ChatKit offers a toolkit for embedding chat-based agent experiences in products (generally available). The Connector Registry is a central admin hub for data and tool connections, including pre-built connectors for Dropbox, Google Drive, SharePoint, and Teams, plus third-party MCP servers (beta).

**OpenAI Frontier.** Launched February 2026, this enterprise platform is built on four pillars: Business Context, Agent Execution, Evaluation and Optimization, and Enterprise Security and Governance. A distinctive feature is that each AI agent receives its own identity with explicit permissions and guardrails, bringing agent governance closer to how enterprises manage human user identities.

### Cloud Platform Comparison Table

| Dimension | Google Vertex AI | Anthropic Claude Platform | OpenAI Platform |
|---|---|---|---|
| **Agent SDK language** | Python (Java coming) | Python and TypeScript | Python |
| **Multi-agent mechanism** | ADK delegation + A2A | TeammateTool + Agent SDK | Handoffs + AgentKit Builder |
| **Visual agent builder** | No (code-first) | No (code-first) | Yes (AgentKit Agent Builder) |
| **Enterprise platform** | Vertex AI Agent Builder | Claude Enterprise | OpenAI Frontier |
| **Cross-cloud** | Native (Google Cloud) | AWS Bedrock + Google Cloud | Native (OpenAI) |
| **Computer use** | No native offering | Yes (Sonnet 4.5 leads OSWorld) | Yes (via Responses API) |
| **Tool governance** | Cloud API Registry | Managed policy settings | Connector Registry |
| **Key differentiator** | A2A protocol, open ADK | Tool sophistication, computer use | Visual builder, agent identity |

## Architecture and Sandboxing

The three platforms take fundamentally different approaches to trust boundaries and code execution safety.

**OpenAI Codex CLI** offers the strongest isolation. Its bubblewrap-based sandbox on Linux restricts filesystem access to the working directory by default, disables network access, and requires explicit approval for elevated permissions. On Windows, AppContainer provides similar isolation through restricted tokens. In cloud mode, each agent runs in a dedicated container with no network access by default. This makes Codex CLI the safest choice for environments where untrusted code execution is a concern.

**Anthropic Claude Code** runs with the user's filesystem permissions and relies on a hooks system for validation rather than OS-level sandboxing. PreToolUse and PostToolUse hooks let teams intercept and validate tool calls before and after execution, providing a flexible but opt-in safety layer. For production deployments that require stronger isolation, teams typically run Claude Code inside containers or virtual machines.

**Google Gemini CLI** also lacks native sandboxing, running with the user's permissions. Security is managed through tool-level controls and MCP server configuration. Like Claude Code, stronger isolation requires external containerization.

> **Tip:** For enterprise adoption, consider the sandboxing requirements of your security posture. If native isolation is mandatory, Codex CLI provides it out of the box. If your teams already run agents inside containers (Docker, microVMs), the sandboxing difference matters less.

Example 8.5-1. Codex CLI sandbox configuration (illustrative)

```bash
# Codex CLI with full sandbox (default on Linux)
codex --approval-mode suggest

# Codex CLI with network access enabled (requires explicit opt-in)
codex --approval-mode auto-edit --full-auto

# Claude Code with PreToolUse hook for validation
# Configured in .claude/settings.json:
# { "hooks": { "PreToolUse": [{ "matcher": "Bash",
#     "command": "validate-command.sh" }] } }
claude

# Gemini CLI with restricted tool access
gemini --tools read_file,write_file,google_search
```

## Tool Ecosystems and Protocol Support

### MCP (Model Context Protocol)

MCP, created by Anthropic and donated to the Agentic AI Foundation (AAIF) under the Linux Foundation, standardizes how agents connect to tools and data sources. It defines a client-server protocol where agents (clients) discover and invoke tools exposed by MCP servers.

All three CLI agents support MCP as consumers. Anthropic additionally acts as an MCP producer, exposing Claude Code's own capabilities as MCP servers. The protocol is the closest the industry has to a universal agent-to-tool standard. See [Skills and Tools Management](040-skills-tools.md) for detailed MCP coverage.

### A2A (Agent-to-Agent Protocol)

A2A, created by Google, addresses a different layer: agent-to-agent communication rather than agent-to-tool communication. While MCP handles vertical integration (connecting an agent to tools), A2A handles horizontal integration (connecting agents to each other).

A2A is built on HTTP, Server-Sent Events, and JSON-RPC, with gRPC support for high-throughput scenarios. Agents publish Agent Cards that describe their capabilities, enabling dynamic discovery. Over 50 enterprise partners have committed to A2A. However, as of February 2026, neither Anthropic nor OpenAI has adopted A2A natively; their agents communicate through platform-specific mechanisms. See [Agent Orchestration](020-orchestration.md) for more on A2A.

### AGENTS.md Convention

The `AGENTS.md` convention, created by OpenAI and donated to AAIF, provides a standardized way to include agent instructions in a repository. All three CLI agents honour this convention in some form: Gemini CLI reads `AGENTS.md` files directly, Claude Code supports both `AGENTS.md` and its own `CLAUDE.md` convention, and Codex CLI processes `AGENTS.md` files for project context.

### Agentic AI Foundation (AAIF)

In December 2025, the Agentic AI Foundation was formed under the Linux Foundation, co-founded by Anthropic, Block, and OpenAI. Platinum members include AWS, Bloomberg, Cloudflare, Google, and Microsoft. The three founding projects are MCP (from Anthropic), goose (from Block), and AGENTS.md (from OpenAI). AAIF's existence signals industry alignment on shared standards despite fierce competition between the vendors.

| Protocol | Created by | Google | Anthropic | OpenAI |
|---|---|---|---|---|
| **MCP** | Anthropic | Adopted | Created, donated to AAIF | Adopted (March 2025) |
| **A2A** | Google | Created | Not adopted | Not adopted |
| **AGENTS.md** | OpenAI | Supported | Supported (plus CLAUDE.md) | Created, donated to AAIF |

## Multi-Agent Patterns

Each platform offers distinct primitives for multi-agent orchestration. The patterns differ in how agents discover each other, share context, and coordinate work.

**Google ADK** uses explicit delegation. A parent agent delegates tasks to child agents within the same ADK application, or to remote agents via A2A. The A2A integration means ADK agents can collaborate with agents built on entirely different frameworks, provided those frameworks also implement A2A.

Example 8.5-2. Google ADK multi-agent delegation (illustrative pseudocode)

```python
from google.adk import Agent, AgentGroup

researcher = Agent(
    name="researcher",
    model="gemini-3-flash",
    instructions="Research the given topic thoroughly.",
    tools=[google_search, web_fetch]
)

writer = Agent(
    name="writer",
    model="gemini-3-flash",
    instructions="Write clear, concise content based on research.",
    tools=[file_write]
)

team = AgentGroup(
    agents=[researcher, writer],
    orchestration="sequential"  # researcher runs first, writer second
)

result = team.run("Write a summary of recent MCP developments")
```

**Anthropic Agent Teams** uses a lead-and-teammate model. The lead session spawns independent teammates, each with its own full context window. Teammates can message each other and the lead coordinates their output. The TeammateTool API provides the programmatic interface for this pattern.

Example 8.5-3. Anthropic Agent Teams pattern (illustrative pseudocode)

```python
from claude_agent_sdk import Agent, TeammateTool

lead = Agent(
    model="claude-opus-4-6",
    tools=[TeammateTool(
        teammates={
            "researcher": {"prompt": "Research the given topic."},
            "reviewer": {"prompt": "Review content for accuracy."}
        },
        max_teammates=3
    )]
)

# Lead delegates research, then passes results to reviewer
result = lead.run("Research and review recent A2A protocol adoption")
```

**OpenAI Agents SDK** uses Handoffs. An agent explicitly transfers control to another agent, along with the conversation context. This is a production-ready evolution of the Swarm framework. AgentKit's Agent Builder adds a visual layer on top for composing these flows graphically.

Example 8.5-4. OpenAI Agents SDK handoff pattern (illustrative pseudocode)

```python
from agents import Agent, handoff

researcher = Agent(
    name="researcher",
    model="gpt-5.3-codex",
    instructions="Research the given topic.",
    tools=[web_search]
)

writer = Agent(
    name="writer",
    model="gpt-5.3-codex",
    instructions="Write content based on research.",
    handoffs=[handoff(target=researcher)]  # can hand back to researcher
)

# Orchestration via handoffs between agents
result = writer.run("Write a summary of recent MCP developments")
```

### Multi-Agent Comparison

| Dimension | Google (ADK) | Anthropic (Agent Teams) | OpenAI (Agents SDK) |
|---|---|---|---|
| **Orchestration model** | Delegation (parent-child) | Lead-teammate messaging | Handoffs (explicit transfer) |
| **Cross-framework** | Yes (via A2A) | No (platform-specific) | No (platform-specific) |
| **Max parallel agents** | Not specified | 2-5 teammates recommended | Multiple via worktrees |
| **Visual builder** | No | No | Yes (AgentKit) |
| **Context sharing** | Agent Card metadata | Full context per teammate | Conversation context on handoff |

## Pricing and Cost Optimization

API pricing varies significantly across vendors and models. The following table compares the primary models used in each CLI agent.

### API Pricing (per million tokens)

| Model | Input | Output | Notes |
|---|---|---|---|
| Gemini 3 Flash | Very low | Very low | Free tier: 1K req/day |
| Claude Opus 4.6 | $5.00 | $25.00 | Batch API: 50% off |
| Claude Sonnet 4.5 | Lower | Lower | Best computer-use model |
| Claude Haiku 4.5 | Lowest | Lowest | Fast, cost-effective |
| GPT-5 Codex | $1.25 | $10.00 | Standard API pricing |
| codex-mini-latest | $1.50 | $6.00 | Lighter-weight option |

### Subscription Tiers

| Tier | Google | Anthropic | OpenAI |
|---|---|---|---|
| **Free** | Gemini CLI (1K req/day) | None | None |
| **Individual** | AI Pro $19.99/mo | Pro $20/mo | Plus $20/mo |
| **Power user** | AI Ultra (higher) | Max $100-200/mo | Pro $200/mo |
| **Team** | Gemini Code Assist | Team $30/user/mo | Team plan |
| **Enterprise** | Vertex AI contracts | Enterprise plan | Frontier contracts |

### Cost-Saving Mechanisms

**Google** relies on its generous free tier and low per-token pricing for Gemini Flash models. For most experimentation and small-to-medium workloads, the free tier alone may suffice.

**Anthropic** offers two significant cost-reduction features. The Batch API provides a 50 percent discount for non-time-sensitive workloads. Prompt Caching can reduce costs by up to 90 percent for repeated context (system prompts, large documents, tool definitions).

**OpenAI** offers a Batch API for bulk processing and competitive per-token rates on Codex models. The codex-mini-latest model provides a lower-cost option for lighter tasks.

> **Tip:** For cost-sensitive workloads, consider using lighter models (Gemini Flash, Claude Haiku, codex-mini) for routine tasks and reserving flagship models (Gemini 3 Pro, Opus 4.6, GPT-5.3-Codex) for complex tasks. All three platforms support model routing, letting you match model capability to task complexity.

## Enterprise Governance and Security

Enterprise adoption requires more than raw model capability. Governance, compliance, and security controls often determine which platform an organization can use.

### Compliance Certifications

| Certification | Google | Anthropic | OpenAI |
|---|---|---|---|
| **SOC 2** | Yes (Type II) | Yes | Yes (Type II) |
| **ISO 27001** | Yes | Yes | Yes |
| **ISO 27017/27018** | Yes | Pending | Yes |
| **ISO 27701** | Yes | Pending | Yes |
| **HIPAA** | Yes (BAA available) | Yes (alignment) | Yes |
| **CSA STAR** | Yes | Pending | Yes |

### Tool Governance

Each vendor takes a different approach to controlling which tools agents can access.

**Google Cloud API Registry** lets administrators curate approved tool sets across the organization. Combined with Apigee, it transforms existing managed APIs into governed MCP servers with usage tracking and access control.

**Anthropic Managed Policies** provide organization-level settings that control tool permissions and file access restrictions. The Compliance API offers programmatic access to usage data for auditing, governance, and real-time flagging. BYOK (Bring Your Own Key) encryption support is planned for the first half of 2026.

**OpenAI Connector Registry** serves as a central admin hub for data and tool connections. OpenAI Frontier introduces per-agent identity, where each AI agent receives its own identity with explicit permissions and guardrails, similar to how enterprises manage human user access.

### Audit and Monitoring

| Capability | Google | Anthropic | OpenAI |
|---|---|---|---|
| **Audit trails** | End-to-end observability | Compliance API | Detailed audit logs |
| **Real-time monitoring** | Cloud Monitoring integration | Real-time flagging via API | Built-in monitoring |
| **Agent identity** | Google Cloud IAM | Organization-level seats | Per-agent identity (Frontier) |
| **Data residency** | Regional options | US/EU options | Regional options |

> **Warning:** Agent governance is evolving rapidly. Before deploying agents in regulated environments, verify current compliance certifications and data handling policies directly with each vendor. The information in this table reflects February 2026 status.

## Choosing a Platform

No single platform dominates every scenario. The right choice depends on your use case, existing infrastructure, security requirements, and team preferences.

**Choose Google** when you need open protocols and cross-framework interoperability (A2A), want the most generous free tier for experimentation, or your organization already runs on Google Cloud. Google's ADK is also the strongest choice when you need agents from different vendors or frameworks to communicate with each other.

**Choose Anthropic** when tool sophistication and developer experience are priorities. Claude Code's Tool Search, Programmatic Tool Calling, and Agent Teams offer capabilities the others lack. Anthropic is also the only vendor offering production-grade computer use (GUI interaction) and cross-cloud availability on both AWS and Google Cloud.

**Choose OpenAI** when sandboxed security is non-negotiable, when you need a visual agent builder for non-developer stakeholders, or when per-agent identity management aligns with your governance model. OpenAI Frontier is the most enterprise-security-focused platform of the three.

**Use multiple platforms** when your organization has diverse needs. Many enterprises run multiple agent platforms simultaneously, using each where it excels. GitHub's Agent HQ surface already supports assigning tasks to Copilot, Claude, or Codex side by side, normalising multi-vendor agent usage within a single development environment. See [Agents for Coding](080-agents-for-coding.md) for detailed coverage of Agent HQ and individual coding agent platforms.

## Key Takeaways

The agent platform landscape in early 2026 is a three-way race with clear differentiation: Google leads on open protocols and free access, Anthropic on tool sophistication and developer experience, and OpenAI on sandboxed security and enterprise identity. All three support MCP as the emerging standard for agent-to-tool communication, while A2A (Google-only for now) addresses agent-to-agent communication. For most organizations, the choice is not exclusive — multi-platform strategies are becoming the norm, with GitHub Agent HQ and the Agentic AI Foundation both pushing toward interoperability. The protocols and governance mechanisms covered in this chapter are evolving rapidly; revisit vendor documentation regularly to track changes. For deeper coverage of the tools, protocols, and orchestration patterns referenced here, see [Agent Orchestration](020-orchestration.md), [Skills and Tools Management](040-skills-tools.md), and [Future Developments](800-future-developments.md).

<!-- Edit notes:
New chapter covering agent platform comparison across Google, Anthropic, and OpenAI.
Sections: CLI agents, cloud platforms, architecture/sandboxing, tool ecosystems, multi-agent patterns, pricing, enterprise governance, decision framework.
Code examples labeled as illustrative pseudocode.
Cross-references: 020-orchestration.md, 040-skills-tools.md, 080-agents-for-coding.md, 800-future-developments.md.
Vendor-neutral framing maintained throughout.
-->
