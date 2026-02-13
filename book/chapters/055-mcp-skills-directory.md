---
title: "MCP Servers and Agent Skills: A Practical Directory"
order: 5.5
---

# MCP Servers and Agent Skills: A Practical Directory

## Chapter Preview

This chapter provides two things the preceding chapters intentionally left out: a curated directory of specific, useful MCP servers and Agent Skills organised by category, and concrete recipes for announcing your own MCPs and Skills to visiting AI models. Chapter [Skills and Tools Management](040-skills-tools.md) covered design principles and protocol mechanics; chapter [Discovery and Imports](050-discovery-imports.md) established the taxonomy of discovery, import, install, and activate. This chapter puts that theory to work with real names, real URLs, and real configuration files.

> **Note:** Treat this chapter as a dated landscape snapshot. The MCP ecosystem adds new servers weekly. Verify links and version numbers against current sources before adopting.

## The MCP Ecosystem at Scale

The Model Context Protocol ecosystem has grown from near-zero to an estimated 17,000 or more server implementations in under two years. The official MCP Registry at registry.modelcontextprotocol.io indexes a curated subset; third-party directories track the broader landscape. The community-maintained `punkpeye/awesome-mcp-servers` repository alone has over 80,000 GitHub stars.

A significant shift occurred in late 2025 and early 2026: major companies began maintaining their own official MCP servers, replacing earlier community reference implementations. The MCP Steering Group archived several former reference servers (Brave Search, GitHub, GitLab, Google Drive, PostgreSQL, Puppeteer, Slack, and others) as vendors took over maintenance. This transition means that the most reliable servers are increasingly the official ones published by the companies whose services they expose.

## Finding MCP Servers

### The Official MCP Registry

The official registry launched in September 2025 in preview at registry.modelcontextprotocol.io. It is maintained by the MCP Steering Group and acts as the authoritative source for publicly available MCP servers. The registry API (v0.1) supports search by name, category, and usage metrics.

The reference server repository at github.com/modelcontextprotocol/servers (approximately 78,000 stars) contains implementations maintained directly by the Steering Group. These reference servers serve as both functional tools and implementation examples.

### Third-Party Directories

Several third-party directories track the broader ecosystem beyond the official registry.

| Directory | Approximate Scale | Focus |
|---|---|---|
| **PulseMCP** (pulsemcp.com) | 8,000+ servers | Curated, updated daily, excludes low-quality implementations |
| **Smithery** (smithery.ai) | 2,200+ servers | Installation guides, one-click setup |
| **Glama** (glama.ai/mcp/servers) | Synced with awesome lists | Marketplace format, synced with community lists |
| **MCP Market** (mcpmarket.com) | Top 100 leaderboard | Ranked by GitHub stars and usage |
| **mcpservers.org** | Web directory | Companion to awesome lists, browsable categories |

### Awesome Lists

The `punkpeye/awesome-mcp-servers` repository organises servers into over 25 categories and is the most widely referenced starting point. The meta-list `esc5221/awesome-awesome-mcp-servers` aggregates multiple awesome lists for comprehensive discovery.

## MCP Servers by Category

The tables below list specific servers that are actively maintained as of February 2026. Entries marked "Official" are maintained by the service vendor; entries marked "Community" are maintained by independent developers.

### Reference Servers (MCP Steering Group)

These are maintained in the `modelcontextprotocol/servers` repository and serve as both functional tools and reference implementations.

| Server | Purpose |
|---|---|
| **Everything** | Reference and test server exposing prompts, resources, and tools |
| **Fetch** | Web content fetching and conversion for efficient LLM consumption |
| **Filesystem** | Secure file operations with configurable access controls |
| **Git** | Read, search, and manipulate Git repositories |
| **Memory** | Knowledge-graph-based persistent memory system |
| **Sequential Thinking** | Dynamic and reflective problem-solving through thought sequences |
| **Time** | Time and timezone conversion |

### Developer Tools

| Server | Maintainer | Description |
|---|---|---|
| **GitHub MCP Server** | Official | Repository management, pull requests, issues, code review |
| **GitLab MCP Server** | Official | Project data access, issue management, repository operations via OAuth 2.0 |
| **Jira MCP Server** | Community (sooperset/mcp-atlassian) | Issue tracking, automated ticket creation, task prioritisation |
| **Linear MCP** | Community | Issues, cycles, project updates; suited for high-velocity teams |
| **Sentry MCP** | Official | Real-time error tracking and performance issue context |
| **Playwright MCP** | Official (Microsoft) | Browser automation via accessibility snapshots; `npx @playwright/mcp@latest` |
| **Docker Hub MCP** | Official | Container orchestration and lifecycle management |
| **Figma MCP (Dev Mode)** | Official | Live Figma layer structure for design-to-code workflows |
| **E2B MCP** | Official | Secure cloud sandbox for Python and JavaScript code execution |
| **Desktop Commander** | Community | Terminal access, process management, advanced search |

### Databases

| Server | Maintainer | Description |
|---|---|---|
| **PostgreSQL MCP** | Community (archived reference) | Read-only SQL queries, schema inspection, explain plans |
| **Postgres MCP Pro** | Community (CrystalDBA) | Configurable read/write access and performance analysis |
| **SQLite MCP** | Community | SQLite file operations, Datasette-compatible metadata |
| **MongoDB Lens** | Official (MongoDB) | Read-only querying, aggregation, schema inspection |
| **DBHub** | Community (Bytebase) | Zero-dependency server for PostgreSQL, MySQL, SQL Server, MariaDB, SQLite |
| **MCP Toolbox for Databases** | Official (Google) | Managed MCP for PostgreSQL on Google Cloud |

### Cloud Providers

| Server | Maintainer | Description |
|---|---|---|
| **AWS MCP Servers** | Official | Multiple specialised servers for AWS services and best practices |
| **Azure MCP Server** | Official (Microsoft) | Azure resource management via natural language; RBAC and audit logging |
| **Google Cloud MCP** | Official | Servers for BigQuery, Google Maps, Compute Engine, Kubernetes Engine |
| **Kubernetes MCP** | Official (Microsoft/Azure) | Bridge between AI tools and Kubernetes clusters |

### Communication

| Server | Maintainer | Description |
|---|---|---|
| **Slack MCP Server** | Official | Channel interaction, messaging automation, real-time notifications |
| **Discord MCP Server** | Community | Full CRUD on channels, forums, messages, webhooks |
| **Gmail MCP** | Community | Common Gmail operations |
| **FastMail MCP** | Community | Email, calendar, contacts via JMAP API |

### Document and Knowledge Management

| Server | Maintainer | Description |
|---|---|---|
| **Notion MCP** | Official | Full workspace read/write, optimised for AI agents; hosted server with OAuth |
| **Google Drive MCP** | Community | Integration with Drive, Docs, Sheets, Slides |
| **Confluence MCP** | Community (sooperset/mcp-atlassian) | Atlassian Confluence page management for Cloud and Server editions |

### Search and Web

| Server | Maintainer | Description |
|---|---|---|
| **Brave Search MCP** | Official | Privacy-focused search with comprehensive operator support |
| **Exa MCP** | Community | Semantic search, real-time web searches, live crawling |
| **Tavily MCP** | Community | Optimised for factual information with strong citation support |
| **Perplexity MCP** | Community | Semantic search for deeper research (paid API) |
| **Context7 MCP** | Community (Upstash) | Fetches current documentation through a documentation-as-context pipeline |
| **Firecrawl MCP** | Community | Converts URLs to clean Markdown by removing boilerplate |
| **MCP Omnisearch** | Community | Unified access to Tavily, Brave, Kagi, Perplexity, Jina AI, Exa, and Firecrawl |

### AI and ML Tools

| Server | Maintainer | Description |
|---|---|---|
| **Hugging Face MCP Server** | Official | Search models, datasets, papers; connect to Gradio-based Spaces tools |
| **Hugging Face Spaces MCP** | Community | Interact directly with Hugging Face Spaces applications |

### Observability

| Server | Maintainer | Description |
|---|---|---|
| **Datadog MCP Server** | Official | Bridge to Datadog metrics, traces, and logs |
| **Grafana MCP Server** | Official (open source) | Access Grafana instance data; supports read-only mode via `--disable-write` |
| **Grafana MCP Observability** | Official | Monitors MCP implementations themselves: protocol health, session management |

### Finance and Commerce

| Server | Maintainer | Description |
|---|---|---|
| **Financial Modeling Prep MCP** | Official (FMP) | 250+ tools covering equities, SEC filings, ETFs, macroeconomic indicators |
| **Financial Datasets MCP** | Official | Income statements, balance sheets, cash flows, historical prices |
| **Stripe MCP** | Official | 100+ payment methods, documentation search, Stripe API interaction |
| **Salesforce MCP Connector** | Official | CRM data access, lead management, sales analytics |
| **Shopify MCP** | Community/Official | Agentic commerce interface; implements Universal Commerce Protocol (UCP) |

### Multi-App Aggregators

For teams that need broad integration without managing individual servers, aggregator servers connect to multiple services through a single MCP interface.

| Server | Scale | Description |
|---|---|---|
| **Pipedream** | 2,500+ integrations | Single MCP server connecting to thousands of APIs |
| **Rube** | 500+ apps | Gmail, Slack, GitHub, Notion, and more through one server |
| **MCPX** | Enterprise-focused | Production-ready gateway for enterprise MCP deployment |

> **Tip:** Start with official servers when available — they receive faster security patches and are less likely to be abandoned. Use community servers for services that lack official support, but pin versions and review source code before deploying in production. For supply-chain controls, see [Discovery and Imports](050-discovery-imports.md).

## MCP Apps: Interactive UI in Conversations

In January 2026, the MCP project announced **MCP Apps**, the first official MCP extension. Developed collaboratively by Anthropic, OpenAI, and the MCP-UI community, MCP Apps enable tools to return interactive UI components that render directly in the conversation, replacing plain-text responses with dashboards, forms, visualisations, and multi-step workflows.

The architecture uses two core primitives. First, tools include a `_meta.ui.resourceUri` field pointing to a UI resource. Second, UI resources are served via the `ui://` scheme and contain bundled HTML and JavaScript. The host fetches resources, renders them in sandboxed iframes, and establishes bidirectional communication using JSON-RPC over `postMessage`.

Client support as of February 2026 includes Claude (web and desktop), ChatGPT, Goose, and Visual Studio Code Insiders. Available example implementations include 3D visualisation (threejs-server), interactive maps (map-server), document viewing (pdf-server), real-time dashboards (system-monitor-server), and music notation (sheet-music-server).

The `@modelcontextprotocol/ext-apps` NPM package provides the developer API for building MCP Apps.

## Agent Skills Directory

### The Agent Skills Standard

Agent Skills is an open standard proposed by Anthropic in December 2025. Skills are directories containing a `SKILL.md` file with YAML frontmatter and Markdown instructions, packaging procedural knowledge into reusable, portable modules that AI agents load dynamically. The specification lives at agentskills.io.

Skills work across Claude Code, OpenAI Codex, GitHub Copilot, Cursor, Gemini CLI, Windsurf, and other tools that honour the standard. The format uses progressive disclosure: metadata (roughly 100 tokens) is loaded at startup for all skills, the full `SKILL.md` body (recommended under 5,000 tokens) is loaded when the skill activates, and resource files in `scripts/`, `references/`, and `assets/` directories are loaded on demand.

For detailed coverage of the SKILL.md format and design principles, see [Skills and Tools Management](040-skills-tools.md).

### Official Skill Collections

**Anthropic** (github.com/anthropics/skills, approximately 69,000 stars) publishes skills across four categories: document handling (DOCX, PPTX, XLSX, PDF processing), creative and design (frontend development patterns), development and technical (code-related workflows), and enterprise and communication (business workflows).

**OpenAI** (github.com/openai/skills) publishes skills focused on prototyping, documentation generation, code understanding, and CI/CD automation for use with Codex.

**Vercel Engineering** contributes React best practices, Next.js optimisation and upgrading, React Native performance, and web design guidelines.

**Cloudflare** contributes skills for AI agent development with stateful coordination, MCP server construction, Workers deployment, and web performance auditing.

**Trail of Bits** publishes over 23 security-focused skills covering cryptographic analysis, smart contract auditing, vulnerability detection, and compliance verification.

**Pulumi** publishes eight DevOps skills for infrastructure-as-code workflows.

### Community Collections

| Collection | Scale | Description |
|---|---|---|
| **VoltAgent/awesome-agent-skills** | 339+ skills | Cross-platform, includes official skills from Anthropic, Vercel, Cloudflare, Trail of Bits, Google Labs, Hugging Face, Stripe, Microsoft, Supabase, Expo, and Sentry |
| **sickn33/antigravity-awesome-skills** | 800+ skills | Battle-tested skills for Claude Code, Antigravity, and Cursor |
| **hesreallyhim/awesome-claude-code** | Varies | Skills, hooks, slash-commands, and agent orchestrators for Claude Code |

### Skill Registries

**SkillRegistry.io** is a browsable directory for SKILL.md files with 61 skills and over 3,000 downloads as of February 2026. **ClawHub** is the OpenClaw marketplace with over 3,000 skills, though it now requires identity verification and VirusTotal scanning after the ClawHavoc security incident (see [Failure Modes, Testing, and Fixes](100-failure-modes-testing-fixes.md)). Skills can also be distributed as plain Git repositories without formal registry submission.

### Security: The ToxicSkills Warning

In February 2026, Snyk researchers published the ToxicSkills report after scanning nearly 4,000 skills from public registries. They found that 13.4 percent had critical-level vulnerabilities and 76 contained confirmed malicious payloads. This underscores the importance of the supply-chain controls described in [Discovery and Imports](050-discovery-imports.md): pin versions, verify checksums, review source code, and prefer official skills from known publishers.

> **Warning:** Do not blindly install skills from public registries into production environments. Apply the same supply-chain scrutiny you would to any third-party dependency: review source, check publisher identity, pin versions, and run in sandboxed environments when possible.

## Announcing MCPs and Skills to Visiting Models

As AI agents increasingly browse the web, retrieve documentation, and interact with services, sites need machine-readable ways to advertise their capabilities. This section covers the current state-of-the-art conventions for announcing MCP servers, Agent Skills, and agent policies to visiting models.

### llms.txt: Machine-Readable Site Context

The `llms.txt` convention, proposed by Jeremy Howard in September 2024, places a Markdown file at a site's root path (`/llms.txt`) to provide LLM-friendly information about the site. The specification lives at llmstxt.org.

The format uses Markdown because it is the most widely understood format for language models. The structure is: an H1 heading with the project or site name (required), an optional blockquote with a short summary, optional body paragraphs, and H2-delimited sections containing lists of Markdown links. An optional "Optional" H2 section signals secondary information that can be omitted in shorter context windows.

Example 5.5-1. A minimal llms.txt file (illustrative)

```markdown
# Acme API Documentation

> Acme provides a REST API for widget management. Use these docs
> to integrate widget creation, updates, and analytics.

## Docs
- [Authentication](https://docs.acme.com/auth.md): API keys and OAuth setup
- [Widgets API](https://docs.acme.com/widgets.md): Create, update, delete widgets
- [Webhooks](https://docs.acme.com/webhooks.md): Real-time event notifications

## MCP Server
- [Acme MCP Server](https://docs.acme.com/mcp.md): Connect via MCP for direct API access

## Optional
- [Rate Limits](https://docs.acme.com/rate-limits.md): Throttling and quota details
- [Changelog](https://docs.acme.com/changelog.md): Recent API changes
```

A companion `llms-full.txt` file can contain a comprehensive Markdown export of all documentation. Anthropic, for example, publishes both `llms.txt` (roughly 8,000 tokens) and `llms-full.txt` (roughly 480,000 tokens).

As of February 2026, over 780 sites have adopted `llms.txt`, including Cloudflare, Vercel, Coinbase, Anthropic, Stripe, and Mintlify. The spec also recommends serving Markdown versions of HTML pages at the same URL with `.md` appended. Adoption is strongest among developer tools and AI companies.

### MCP Discovery via .well-known

MCP server discovery via `.well-known` endpoints is under active development through Spec Enhancement Proposals (SEPs), with target inclusion in the June 2026 specification release. Two key proposals define the emerging standard.

**SEP-1960** proposes a `/.well-known/mcp` endpoint following RFC 8615 conventions. This endpoint returns a JSON document describing the server's capabilities, transport endpoints, authentication requirements, rate limits, and security configuration.

Example 5.5-2. MCP discovery endpoint response (illustrative, based on SEP-1960)

```json
{
  "mcp_version": "1.0",
  "server_name": "Acme MCP Server",
  "server_version": "2.1.0",
  "endpoints": {
    "streamable_http": "https://mcp.acme.com/mcp",
    "sse": "https://mcp.acme.com/sse"
  },
  "capabilities": {
    "tools": true,
    "resources": true,
    "prompts": true,
    "sampling": false
  },
  "authentication": {
    "required": true,
    "methods": ["oauth2", "api_key"],
    "oauth2": {
      "authorization_endpoint": "https://auth.acme.com/authorize",
      "token_endpoint": "https://auth.acme.com/token",
      "scopes_supported": ["mcp:read", "mcp:write"]
    }
  },
  "rate_limits": {
    "requests_per_minute": 60,
    "tokens_per_minute": 100000
  },
  "documentation": "https://docs.acme.com/mcp"
}
```

**SEP-1649** proposes a more detailed **MCP Server Card** at `/.well-known/mcp/server-card.json`, which includes static tool and resource definitions for pre-connection discovery. The server card can also be exposed as an MCP resource at `mcp://server-card.json`.

The client discovery flow is: extract the server's base URL, request `GET /.well-known/mcp`, validate any cryptographic signatures, confirm capability compatibility, configure authentication, and connect to the selected transport endpoint.

> **Note:** These endpoints are at the SEP stage and not yet part of the released MCP specification. Implement them if you want to be ahead of the standard, but be prepared for changes before the June 2026 release.

### A2A Agent Cards

The Agent-to-Agent (A2A) protocol, created by Google, defines an **Agent Card** as a JSON metadata document published at `/.well-known/agent-card.json`. Agent Cards enable agent-to-agent discovery by advertising an agent's identity, capabilities, skills, endpoint, and authentication requirements.

Example 5.5-3. An A2A Agent Card (illustrative)

```json
{
  "id": "acme-support-agent",
  "name": "Acme Support Agent",
  "description": "Handles customer inquiries about Acme products and services.",
  "provider": {
    "organization": "Acme Inc.",
    "url": "https://acme.com"
  },
  "url": "https://agents.acme.com/a2a",
  "capabilities": {
    "streaming": true,
    "pushNotifications": false
  },
  "skills": [
    {
      "id": "order-lookup",
      "name": "Order Lookup",
      "description": "Look up order status by order ID or customer email.",
      "inputModes": ["text/plain", "application/json"],
      "outputModes": ["application/json"]
    },
    {
      "id": "return-request",
      "name": "Return Request",
      "description": "Initiate a product return or exchange.",
      "inputModes": ["application/json"],
      "outputModes": ["application/json"]
    }
  ],
  "interfaces": [
    { "protocol": "a2a", "version": "1.0" }
  ],
  "securitySchemes": {
    "bearerAuth": { "type": "http", "scheme": "bearer" }
  },
  "security": [{ "bearerAuth": [] }]
}
```

Agent Cards support three discovery methods: the well-known URI (primary), curated registries with capability-based queries, and direct configuration for private systems. Authenticated extended cards can return richer information after the client authenticates.

For more on the A2A protocol, see [Agent Orchestration](020-orchestration.md) and [Agent Platform Comparison](085-agent-platform-comparison.md).

### Agent Policies: robots.txt, ai.txt, and agent-permissions.json

Traditional `robots.txt` was designed for web crawlers and does not map cleanly to agentic use cases where AI systems interact with pages, fill forms, or take actions rather than simply indexing content.

Several conventions are emerging to fill this gap.

**ai.txt** was proposed by Spawning in May 2023 as a file at a site's root that controls how AI systems use content for training purposes. Unlike `robots.txt` (read during crawling), `ai.txt` is read when media is downloaded for training and allows real-time permission adjustments. However, adoption remains low and the standard is fragmented across competing proposals from Spawning, Guardian News and Media (via IETF), and community projects.

**agent-permissions.json**, proposed by the Lightweight Agent Standards Working Group (LAS-WG), is a more technically rigorous standard published at `/.well-known/agent-permissions.json`. It covers interactive agent behaviours (clicking, form-filling, navigation) rather than just crawling. The format uses CSS-selector-based resource rules for specific verbs (`click_element`, `submit_form`, `read_content`, `follow_link`) combined with advisory action guidelines using RFC 2119 directives (MUST, SHOULD, MUST NOT).

Example 5.5-4. An agent-permissions.json fragment (illustrative, based on LAS-WG spec)

```json
{
  "metadata": {
    "schema_version": "1.0",
    "last_updated": "2026-02-01",
    "author": "acme.com"
  },
  "strict": true,
  "resource_rules": [
    {
      "selector": "#purchase-button",
      "verb": "click_element",
      "allowed": false
    },
    {
      "selector": ".product-info",
      "verb": "read_content",
      "allowed": true,
      "modifiers": { "rate_limit": { "requests": 10, "period": "60s" } }
    }
  ],
  "action_guidelines": [
    {
      "directive": "MUST NOT",
      "description": "Create accounts without explicit human approval"
    }
  ]
}
```

### Publishing to the MCP Registry

To make your MCP server discoverable through the official registry, you create a `server.json` manifest, authenticate with the registry CLI, and publish.

Example 5.5-5. Publishing an MCP server to the official registry (runnable)

```bash
# Install the publisher CLI
brew install mcp-publisher

# Initialise a server.json template
mcp-publisher init

# Authenticate (for io.github.* namespaces)
mcp-publisher login github

# Validate without publishing
mcp-publisher publish --dry-run

# Publish to the registry
mcp-publisher publish
```

The `server.json` manifest specifies the server name (using reverse-domain namespace), description, repository URL, version, and package details.

Example 5.5-6. A server.json manifest (illustrative)

```json
{
  "$schema": "https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json",
  "name": "io.github.acme/weather",
  "description": "An MCP server providing weather forecasts and alerts.",
  "repository": {
    "url": "https://github.com/acme/mcp-weather-server",
    "source": "github"
  },
  "version": "1.0.1",
  "packages": [
    {
      "registryType": "npm",
      "identifier": "@acme/mcp-weather-server",
      "version": "1.0.1",
      "transport": { "type": "stdio" }
    }
  ]
}
```

Namespace authentication uses GitHub OAuth for `io.github.*` namespaces and DNS TXT record verification for custom domain namespaces like `com.acme.*`. Each package type requires ownership validation: npm packages include an `mcpName` field in `package.json`, PyPI packages include `mcp-name` in README metadata, and Docker images use an OCI label.

For cloud-hosted servers accessible over the network, use the `remotes` field instead of `packages`:

```json
{
  "name": "com.acme/weather-remote",
  "remotes": [
    {
      "transportType": "streamable-http",
      "url": "https://mcp.acme.com/weather"
    }
  ]
}
```

### Publishing Agent Skills

Agent Skills can be distributed through multiple channels. The simplest method is publishing a Git repository with the correct directory structure (a directory containing `SKILL.md` with proper YAML frontmatter). Claude Code and other tools can install skills directly from repositories.

For wider distribution, publish to **SkillRegistry.io** (a browsable directory for SKILL.md files) or vendor-specific registries. The `skills-ref` validation tool can verify your skill structure before publishing:

```bash
skills-ref validate ./my-skill
```

### Putting It All Together

A company that wants to make its services fully discoverable by AI agents can combine several of these mechanisms.

Example 5.5-7. Combined announcement strategy (illustrative)

```
https://acme.com/
├── llms.txt                           # LLM-readable site overview
├── llms-full.txt                      # Comprehensive documentation export
├── .well-known/
│   ├── mcp                            # MCP server discovery (SEP-1960)
│   ├── mcp/server-card.json           # MCP server card (SEP-1649)
│   ├── agent-card.json                # A2A Agent Card
│   └── agent-permissions.json         # Agent interaction policies
├── robots.txt                         # Traditional crawler rules
└── docs/
    ├── api.md                         # Markdown API documentation
    └── mcp.md                         # MCP server setup instructions
```

The `llms.txt` file points visiting models to the documentation. The `.well-known/mcp` endpoint tells agent runtimes how to connect to the MCP server. The A2A Agent Card enables other agents to discover and delegate tasks. The `agent-permissions.json` file sets boundaries on what visiting agents may do. Together, these mechanisms make the site a first-class participant in the agentic web.

| Convention | File or Endpoint | What It Announces | Status (Feb 2026) |
|---|---|---|---|
| **llms.txt** | `/llms.txt` | Site context for LLMs (Markdown) | Community standard, 780+ sites |
| **MCP Discovery** | `/.well-known/mcp` | MCP server capabilities and transport | SEP stage, targeting June 2026 |
| **MCP Server Card** | `/.well-known/mcp/server-card.json` | Detailed server metadata and tool definitions | SEP stage |
| **A2A Agent Card** | `/.well-known/agent-card.json` | Agent identity, skills, and endpoints | Released (A2A v1.0) |
| **Agent Permissions** | `/.well-known/agent-permissions.json` | What agents may and may not do on the site | LAS-WG proposal |
| **MCP Registry** | registry.modelcontextprotocol.io | Server discoverability via central index | Live preview (API v0.1) |
| **Agent Skills** | Git repos, SkillRegistry.io, ClawHub | Reusable skill packages | Released spec, multi-vendor |

## Key Takeaways

The MCP server ecosystem has grown to over 17,000 implementations, with major vendors now maintaining official servers that replace earlier community reference implementations. Agent Skills have achieved cross-platform portability across Claude Code, Codex, Copilot, Cursor, and Gemini CLI, with thousands of skills available through official and community collections. For announcing capabilities to visiting models, the current state of the art combines `llms.txt` for site context, `.well-known/mcp` for MCP server discovery (still in SEP stage), A2A Agent Cards for agent-to-agent discovery, and `agent-permissions.json` for interaction policies. Apply supply-chain security controls to all third-party MCP servers and skills: pin versions, verify publishers, and review source code before deploying in production. For MCP and Skills design principles, see [Skills and Tools Management](040-skills-tools.md); for discovery taxonomy, see [Discovery and Imports](050-discovery-imports.md); for security incidents involving MCP and skills, see [Failure Modes, Testing, and Fixes](100-failure-modes-testing-fixes.md).

<!-- Edit notes:
New chapter providing a curated directory of MCP servers and Agent Skills, plus recipes for announcing capabilities to visiting AI models.
Sections: ecosystem overview, finding servers, servers by category (10 categories), MCP Apps, skills directory, announcement recipes (llms.txt, .well-known/mcp, A2A Agent Cards, agent-permissions.json, registry publication).
Code examples labeled as illustrative or runnable.
Cross-references: 020-orchestration.md, 040-skills-tools.md, 050-discovery-imports.md, 085-agent-platform-comparison.md, 100-failure-modes-testing-fixes.md.
Security warnings included for supply-chain risks (ToxicSkills, ClawHavoc).
-->
