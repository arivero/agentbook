---
title: "Skills and Tools Management"
order: 4
---

# Skills and Tools Management

## Chapter Preview

This chapter defines tools and skills and explains how they map to operational workflows in agentic systems. It compares packaging formats and protocols for distributing skills, helping you choose the right approach for your organisation's needs. Finally, it walks through safe patterns for skill development and lifecycle management, covering versioning, testing, and deprecation.

## Understanding Skills vs. Tools

### Tools

**Tools** are atomic capabilities that agents can use to interact with their environment. They are the building blocks of agent functionality, each performing a single well-defined operation.

Examples of tools include file system operations such as read, write, and delete; API calls including GET, POST, PUT, and DELETE methods; shell commands that execute system operations; and database queries that retrieve or modify stored data.

### Skills

**Skills** are higher-level capabilities composed of multiple tools and logic. They represent complex behaviours that agents can learn and apply, combining atomic operations into coherent workflows.

Examples of skills include code review, which uses Git for diffs, static analysis for issue detection, and test execution for validation. Documentation writing is another skill, combining research tools to gather information, markdown editing tools to write content, and validation tools to check correctness. Bug fixing is a skill that combines debugging tools to identify causes, testing tools to verify fixes, and code editing tools to implement changes.

## Tool Design Principles

### Single Responsibility
Each tool should do one thing well.

```python
# Good: Focused tool
class FileReader:
    """Reads content from files"""
    
    def read(self, filepath: str) -> str:
        with open(filepath, 'r') as f:
            return f.read()

# Bad: Tool doing too much
class FileManager:
    """Does everything with files"""
    
    def read(self, filepath): ...
    def write(self, filepath, content): ...
    def delete(self, filepath): ...
    def search(self, pattern): ...
    def backup(self, filepath): ...
```

### Clear Interfaces
Tools should have well-defined inputs and outputs.

```python
from typing import Protocol

class Tool(Protocol):
    """Interface for all tools"""
    
    name: str
    description: str
    
    def execute(self, **kwargs) -> dict:
        """Execute the tool with given parameters"""
        ...
    
    def get_schema(self) -> dict:
        """Get JSON schema for tool parameters"""
        ...
```

### Error Handling
Tools must handle errors gracefully and provide useful feedback.

```python
class WebScraperTool:
    """Tool for scraping web content"""
    
    def execute(self, url: str, timeout: int = 30) -> dict:
        try:
            response = requests.get(url, timeout=timeout)
            response.raise_for_status()
            return {
                'success': True,
                'content': response.text,
                'status_code': response.status_code
            }
        except requests.Timeout:
            return {
                'success': False,
                'error': 'Request timed out',
                'error_type': 'timeout'
            }
        except requests.RequestException as e:
            return {
                'success': False,
                'error': str(e),
                'error_type': 'request_error'
            }
```

### Documentation
Every tool needs clear documentation.

```python
class GitDiffTool:
    """
    Tool for getting git diffs.
    
    Capabilities:
        - Get diff for specific files
        - Get diff between commits
        - Get diff for staged changes
    
    Parameters:
        filepath (str, optional): Specific file to diff
        commit1 (str, optional): First commit hash
        commit2 (str, optional): Second commit hash
        staged (bool): Whether to show staged changes only
    
    Returns:
        dict: Contains 'diff' (str) and 'files_changed' (list)
    
    Example:
        >>> tool = GitDiffTool()
        >>> result = tool.execute(staged=True)
        >>> print(result['diff'])
    """
    
    def execute(self, **kwargs) -> dict:
        # Implementation
        pass
```

## Creating Custom Tools

### Basic Tool Template

```python
from typing import Any, Dict
import json

class CustomTool:
    """Template for creating custom tools"""
    
    def __init__(self, name: str, description: str):
        self.name = name
        self.description = description
    
    def execute(self, **kwargs) -> Dict[str, Any]:
        """
        Execute the tool.
        
        Override this method in your tool implementation.
        """
        raise NotImplementedError("Tool must implement execute method")
    
    def validate_params(self, **kwargs) -> bool:
        """
        Validate tool parameters.
        
        Override for custom validation logic.
        """
        return True
    
    def get_schema(self) -> Dict[str, Any]:
        """
        Return JSON schema for tool parameters.
        """
        return {
            'name': self.name,
            'description': self.description,
            'parameters': {}
        }
```

### Example: Markdown Validation Tool

```python
import re
from typing import Dict, Any, List

class MarkdownValidatorTool:
    """Validates markdown content for common issues"""
    
    def __init__(self):
        self.name = "markdown_validator"
        self.description = "Validates markdown files for common issues"
    
    def execute(self, content: str) -> Dict[str, Any]:
        """Validate markdown content"""
        issues = []
        
        # Check for broken links
        issues.extend(self._check_links(content))
        
        # Check for heading hierarchy
        issues.extend(self._check_headings(content))
        
        # Check for code block formatting
        issues.extend(self._check_code_blocks(content))
        
        return {
            'valid': len(issues) == 0,
            'issues': issues,
            'issue_count': len(issues)
        }
    
    def _check_links(self, content: str) -> List[Dict]:
        """Check for broken or malformed links"""
        issues = []
        links = re.findall(r'\[([^\]]+)\]\(([^\)]+)\)', content)
        
        for text, url in links:
            if not url:
                issues.append({
                    'type': 'broken_link',
                    'message': f'Empty URL in link: [{text}]()',
                    'severity': 'error'
                })
        
        return issues
    
    def _check_headings(self, content: str) -> List[Dict]:
        """Check heading hierarchy"""
        issues = []
        lines = content.split('\n')
        prev_level = 0
        
        for i, line in enumerate(lines):
            if line.startswith('#'):
                level = len(line) - len(line.lstrip('#'))
                if level > prev_level + 1:
                    issues.append({
                        'type': 'heading_skip',
                        'message': f'Heading level skipped at line {i+1}',
                        'severity': 'warning'
                    })
                prev_level = level
        
        return issues
    
    def _check_code_blocks(self, content: str) -> List[Dict]:
        """Check code block formatting"""
        issues = []
        backticks = re.findall(r'```', content)
        
        if len(backticks) % 2 != 0:
            issues.append({
                'type': 'unclosed_code_block',
                'message': 'Unclosed code block detected',
                'severity': 'error'
            })
        
        return issues
```

## Agent Skills Standard (Primary Reference)

For practical interoperability, treat **Agent Skills** as the primary standard today. The authoritative docs are:

- Overview and motivation: <https://agentskills.io/home>
- Core concept page: <https://agentskills.io/what-are-skills>
- Full format specification: <https://agentskills.io/specification>
- Integration guidance: <https://agentskills.io/integrate-skills>

The current ecosystem signal is strongest around this filesystem-first model: a `SKILL.md` contract with progressive disclosure, plus optional `scripts/`, `references/`, and `assets/` directories.

> **Placement note:** For OpenAI Codex auto-discovery, store repository skills under `.agents/skills/` (or user-level `~/.codex/skills/`). A plain top-level `skills/` folder is a useful wrapper convention but is not auto-discovered by default without additional wiring.


### Canonical Layout

Example 4-1. `.agents/skills/code-review/`

```text
.agents/
  skills/
    code-review/
      SKILL.md
      manifest.json
      scripts/
        review.py
      references/
        rubric.md
      assets/
        example-diff.txt
```

Example 4-2. `.agents/skills/code-review/SKILL.md`

```markdown
---
name: code-review
description: Review pull requests for security, correctness, and clarity.
compatibility: Requires git and Python 3.11+
allowed-tools: Bash(git:*) Read
metadata:
  author: engineering-platform
  version: "1.2"
---

# Code Review Skill

## When to use
Use this skill when reviewing pull requests for correctness, security, and clarity.

## Workflow
1. Run `scripts/review.py --pr <number>`.
2. If policy checks fail, consult `references/rubric.md`.
3. Return findings grouped by severity and file.
```

> **Tip:** Keep `SKILL.md` concise and front-load decision-critical instructions. Put deep references in `references/` and executable logic in `scripts/` so agents load content only when needed.

### Conformance Notes: Agent Skills vs. JSON-RPC Runtime Specs

The main discrepancy you will see across docs in the wild is **where standardization happens**:

- **Agent Skills** standardizes the **artifact format** (directory + `SKILL.md` schema + optional folders).
- Some alternative specs standardize a **remote runtime API** (often JSON-RPC-style methods such as `list`, `describe`, `execute`).

In production, the Agent Skills packaging approach currently has clearer multi-tool adoption because it works in both:

1. **Filesystem-based agents** (agent can `cat` and run local scripts).
2. **Tool-based agents** (host platform loads and mediates skill content).

JSON-RPC itself is battle-tested in other ecosystems (for example, Language Server Protocol, Ethereum node APIs, and MCP transport patterns), but there are still fewer public, concrete references to large-scale deployments of a dedicated JSON-RPC **skills runtime** than to plain `SKILL.md`-based workflows. For most teams, this makes Agent Skills the safest default and JSON-RPC skill runtimes an optional layering.

### Relationship to MCP

Use **Agent Skills** to define and distribute reusable capability packages. Use **MCP** (Model Context Protocol) to expose tools, data sources, or execution surfaces to models. In mature systems, these combine naturally: Agent Skills provide the instructions and assets that tell agents how to accomplish tasks, while MCP provides controlled runtime tool access that actually executes operations. The two standards complement each other rather than competing.

## Skill Development

### Skill Architecture

```python
from typing import List, Dict, Any
from abc import ABC, abstractmethod

class Skill(ABC):
    """Base class for agent skills"""
    
    def __init__(self, name: str, tools: List[Tool]):
        self.name = name
        self.tools = {tool.name: tool for tool in tools}
    
    @abstractmethod
    async def execute(self, task: Dict[str, Any]) -> Dict[str, Any]:
        """Execute the skill"""
        pass
    
    def get_tool(self, name: str) -> Tool:
        """Get a tool by name"""
        return self.tools[name]
    
    def has_tool(self, name: str) -> bool:
        """Check if skill has a tool"""
        return name in self.tools
```

### Example: Code Review Skill

```python
class CodeReviewSkill(Skill):
    """Skill for reviewing code changes"""
    
    def __init__(self, llm, tools: List[Tool]):
        super().__init__("code_review", tools)
        self.llm = llm
    
    async def execute(self, task: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute code review.
        
        Task should contain:
            - pr_number: Pull request number
            - focus_areas: List of areas to focus on (optional)
        """
        pr_number = task['pr_number']
        focus_areas = task.get('focus_areas', ['bugs', 'security', 'performance'])
        
        # Step 1: Get code changes
        git_diff = self.get_tool('git_diff')
        diff_result = git_diff.execute(pr_number=pr_number)
        
        if not diff_result['success']:
            return {'success': False, 'error': 'Failed to get diff'}
        
        # Step 2: Run static analysis
        analyzer = self.get_tool('static_analyzer')
        analysis_result = analyzer.execute(
            diff=diff_result['diff'],
            focus=focus_areas
        )
        
        # Step 3: Run tests
        test_runner = self.get_tool('test_runner')
        test_result = test_runner.execute()
        
        # Step 4: Generate review using LLM
        review = await self._generate_review(
            diff_result['diff'],
            analysis_result['issues'],
            test_result
        )
        
        return {
            'success': True,
            'review': review,
            'static_analysis': analysis_result,
            'test_results': test_result
        }
    
    async def _generate_review(self, diff, issues, tests):
        """Generate review using LLM"""
        prompt = f"""
        Review the following code changes:
        
        {diff}
        
        Static analysis found these issues:
        {json.dumps(issues, indent=2)}
        
        Test results:
        {json.dumps(tests, indent=2)}
        
        Provide a comprehensive code review.
        """
        
        return await self.llm.generate(prompt)
```

## Importing and Using Skills

### Skill Registry

```python
class SkillRegistry:
    """Central registry for skills"""
    
    def __init__(self):
        self._skills = {}
    
    def register(self, skill: Skill):
        """Register a skill"""
        self._skills[skill.name] = skill
    
    def get(self, name: str) -> Skill:
        """Get a skill by name"""
        if name not in self._skills:
            raise ValueError(f"Skill '{name}' not found")
        return self._skills[name]
    
    def list_skills(self) -> List[str]:
        """List all registered skills"""
        return list(self._skills.keys())
    
    def import_skill(self, module_path: str, skill_class: str):
        """Dynamically import and register a skill"""
        import importlib
        
        module = importlib.import_module(module_path)
        SkillClass = getattr(module, skill_class)
        
        # Instantiate and register
        skill = SkillClass()
        self.register(skill)

# Usage
registry = SkillRegistry()

# Register built-in skills
registry.register(CodeReviewSkill(llm, tools))
registry.register(DocumentationSkill(llm, tools))

# Import external skill
registry.import_skill('external_skills.testing', 'TestGenerationSkill')

# Use a skill
code_review = registry.get('code_review')
result = await code_review.execute({'pr_number': 123})
```

### Skill Composition

```python
class CompositeSkill(Skill):
    """Skill composed of multiple sub-skills"""
    
    def __init__(self, name: str, skills: List[Skill]):
        self.name = name
        self.skills = {skill.name: skill for skill in skills}
        
        # Aggregate tools from all skills
        all_tools = []
        for skill in skills:
            all_tools.extend(skill.tools.values())
        
        super().__init__(name, list(set(all_tools)))
    
    async def execute(self, task: Dict[str, Any]) -> Dict[str, Any]:
        """Execute composed skill"""
        results = {}
        
        for skill_name, skill in self.skills.items():
            result = await skill.execute(task)
            results[skill_name] = result
        
        return {
            'success': all(r.get('success', False) for r in results.values()),
            'results': results
        }

# Create composite skill
full_review = CompositeSkill('full_review', [
    CodeReviewSkill(llm, tools),
    SecurityAuditSkill(llm, tools),
    PerformanceAnalysisSkill(llm, tools)
])
```

## Tool Discovery and Documentation

### Self-Documenting Tools

```python
class DocumentedTool:
    """Tool with built-in documentation"""
    
    def __init__(self):
        self.name = "example_tool"
        self.description = "Example tool with documentation"
        self.parameters = {
            'required': ['param1'],
            'optional': ['param2', 'param3'],
            'schema': {
                'param1': {'type': 'string', 'description': 'Required parameter'},
                'param2': {'type': 'int', 'description': 'Optional parameter'},
                'param3': {'type': 'bool', 'description': 'Flag parameter'}
            }
        }
        self.examples = [
            {
                'input': {'param1': 'value'},
                'output': {'success': True, 'result': 'output'}
            }
        ]
    
    def get_documentation(self) -> str:
        """Generate documentation for this tool"""
        doc = f"# {self.name}\n\n"
        doc += f"{self.description}\n\n"
        doc += "## Parameters\n\n"
        
        for param, schema in self.parameters['schema'].items():
            required = "Required" if param in self.parameters['required'] else "Optional"
            doc += f"- `{param}` ({schema['type']}, {required}): {schema['description']}\n"
        
        doc += "\n## Examples\n\n"
        for i, example in enumerate(self.examples, 1):
            doc += f"### Example {i}\n\n"
            doc += f"Input: `{json.dumps(example['input'])}`\n\n"
            doc += f"Output: `{json.dumps(example['output'])}`\n\n"
        
        return doc
```

## Integrations: Connecting Tools to Real-World Surfaces

**Integrations** sit above tools and skills. They represent packaged connectors to real systems (chat apps, device surfaces, data sources, or automation backends) that deliver a coherent user experience. Think of them as the **distribution layer** for tools and skills: they bundle auth, event routing, permissions, and UX entry points.

**How integrations relate to tools and skills:**

- **Tools** are atomic actions (send a message, fetch a calendar event, post to Slack).
- **Skills** orchestrate tools to solve tasks (triage inbox, compile meeting notes, run a daily report).
- **Integrations** wrap tools + skills into deployable connectors with lifecycle management (pairing, secrets, rate limits, onboarding, and UI hooks).

In practice, a single integration might expose multiple tools and enable multiple skills. The integration is the bridge between agent capabilities and the messy realities of authentication, permissions, and channel-specific constraints.

## Case Study: OpenClaw and pi-mono

**OpenClaw** (<https://openclaw.ai/>, <https://github.com/openclaw/openclaw>) is an open-source, local-first personal AI assistant that runs a gateway control plane and connects to over 50 chat providers and device surfaces. Originally published in November 2025 as Clawdbot by Austrian software engineer Peter Steinberger, the project was renamed to OpenClaw in January 2026. With over 183,000 GitHub stars, 3,000+ community-built skills, and 100,000+ active installations, it has become one of the most popular open-source AI projects. OpenClaw emphasizes multi-channel inboxes ("one brain, many channels"), tool access, and skill management inside a user-owned runtime. The v2026.2.6 release (February 2026) added support for Opus 4.6 and GPT-5.3-Codex models, plus a code safety scanner addressing growing security concerns in the skills ecosystem.

OpenClaw is built on the **pi-mono** ecosystem (<https://github.com/badlogic/pi-mono>). The pi-mono monorepo provides an agent runtime, tool calling infrastructure, and multi-provider LLM APIs that OpenClaw leverages to keep the assistant portable across models and deployments.

### OpenClaw Architecture in Detail

OpenClaw's architecture consists of several interconnected components:

```text
                                         +---------------------+
       +------------+                    |      Control UI     |
       | WhatsApp   |---(Gateway WS)---> |      (Dashboard)    |
       | Telegram   |                    +---------+-----------+
       | Discord    |---(API/WS/RPC)                  |
       | iMessage   |                          +------v------+
       +------------+                          |   Gateway   |
                                                   |
                                                   |
                                         +----Agent Runtime---+
                                         |   (pi-mono core)   |
                                         +--------------------+
                                           |     |     |    ...
                                       [Skills/Tools] [Plugins/Other Agents]
```

**1. Gateway Control Plane**
- Central hub orchestrating all user input/output and messaging channels
- Exposes a WebSocket server (default: `ws://127.0.0.1:18789`)
- Handles session state, permissions, and authentication
- Supports local and mesh/LAN deployment via Tailscale (<https://tailscale.com/>) or similar

**2. Pi Agent Runtime (pi-mono)**
- Core single-agent execution environment
- Maintains long-lived agent state, memory, skills, and tool access
- Handles multi-turn conversation, contextual memory, and tool/plugin invocation
- Orchestrates external API/model calls (OpenAI, Anthropic, local models via Ollama <https://ollama.com/>)
- Persistent storage (SQLite, Postgres, Redis) for memory and context

**3. Multi-Agent Framework**
- Support for swarms of specialized agents ("nodes") handling domain-specific automations
- Agents coordinate via shared memory and routing protocols managed by the Gateway
- Each agent can be sandboxed (Docker/isolation) for security
- Developers build custom agents via TypeScript/YAML plugins

**4. Extensible Skills/Plugin Ecosystem**
- Skills expand the agent's abilities: file automation, web scraping, email, calendar
- Plugins are hot-reloadable and built in TypeScript
- Community skill marketplace with 3,000+ skills

### Key Design Principles

1. **Privacy-First**: All state and memory default to local storage—data never leaves the device unless explicitly configured
2. **BYOM (Bring Your Own Model)**: Seamlessly supports cloud LLMs (Claude Opus 4.5 recommended) and local inference via Ollama
3. **Proactive Behavior**: "Heartbeat" feature enables autonomous wake-up and environment monitoring
4. **Persistent Memory**: Learns and adapts over long-term interactions
5. **One Brain, Many Channels**: A single AI assistant maintains shared context across all 50+ messaging channels simultaneously—message from WhatsApp on your phone, switch to Telegram on your laptop, and the same assistant remembers everything

> **Warning:** Security researchers have flagged local-first AI assistants as a serious attack surface. In February 2026, the situation escalated rapidly. VirusTotal identified **341 malicious ClawHub skills** in a campaign codenamed **ClawHavoc**: 335 skills used fake prerequisites to install Atomic Stealer (AMOS), a macOS/Windows infostealer, while others deployed backdoors and remote access tools. A single user ("hightower6eu") was responsible for 314 of these malicious skills. Bitdefender found 17% of skills analysed in early February were malicious. Snyk scanned 3,984 skills and found 283 with critical credential-exposure flaws (7.1% mishandling secrets via LLM context windows). Censys reported over 30,000 exposed OpenClaw instances accessible over the internet. Gartner characterised OpenClaw as "an unacceptable cybersecurity liability" and recommended enterprises block it immediately. OpenClaw responded with a VirusTotal partnership for automated scanning (using Gemini 3 Flash for security analysis), the code safety scanner in v2026.2.6, and plans for a comprehensive threat model and public security roadmap. These incidents make OpenClaw's skills ecosystem the first major case study in agent supply-chain security at scale.

Key takeaways for skills/tools architecture:

- **Gateway + runtime separation** keeps tools and skills consistent while integrations change: the gateway handles channels and routing, while pi-mono-style runtimes handle tool execution.
- **Integration catalogs** (like OpenClaw’s integrations list and skill registry) are a user-facing map of capability. They surface what tools can do and what skills are available without forcing users to understand low-level APIs.
- **Skills become reusable assets** once tied to integrations: a “Slack triage” skill can target different workspaces without changing the underlying tools, as long as the integration provides the same tool contracts.

### The Personal AI Ecosystem Beyond OpenClaw

OpenClaw is the largest project in a rapidly growing personal AI assistant category. Several related frameworks share its local-first philosophy while making different architectural trade-offs.

**Letta** (<https://www.letta.com/>, formerly MemGPT) is a platform for building stateful agents with advanced memory that can learn and self-improve over time. In January 2026, Letta shipped a Conversations API for agents with shared memory across parallel user experiences, and its **Letta Code** agent ranked #1 on Terminal-Bench among model-agnostic open-source agents. In February 2026, Letta introduced **Context Repositories**, a feature that gives agents structured, revisable long-term knowledge bases—moving beyond conversational memory toward persistent project-scoped context. Letta's architecture emphasises programmable memory management—where OpenClaw focuses on channel integration and skills, Letta focuses on making agents that remember and adapt intelligently. The **LettaBot** project (<https://github.com/letta-ai/lettabot>) brings Letta's memory capabilities to a multi-channel personal assistant supporting Telegram, Slack, Discord, WhatsApp, and Signal.

**Langroid** (<https://langroid.github.io/langroid/>) is a Python multi-agent framework from CMU and UW-Madison researchers that emphasises simplicity and composability. Langroid has enhanced MCP support with persistent connections, Portkey integration for unified access to 200+ LLMs, and declarative task termination patterns. Its architecture treats agents, tasks, and tools as lightweight composable objects, making it well-suited for teams that want multi-agent orchestration without heavy infrastructure.

**Open Interpreter** (<https://github.com/openinterpreter/open-interpreter>) provides a natural language interface for controlling computers. Its "New Computer Update" (late 2024) was a complete rewrite supporting a standard interface between language models and computer operations. While less focused on multi-channel messaging than OpenClaw, Open Interpreter fills a complementary niche: using an LLM to drive local computer actions (file management, browser automation, system administration) through plain language.

**Leon** (<https://getleon.ai/>) is an open-source personal assistant built in JavaScript with natural speech recognition, task management, and extendable skills. It is installable via npm on Linux, Mac, or Windows, and appeals to developers who want a lightweight, self-hosted assistant without the full complexity of OpenClaw's multi-channel architecture.

These projects collectively represent a broad trend: users increasingly expect AI assistants that run locally, remember context across sessions and channels, and respect data privacy by default. The architectural patterns that OpenClaw popularised—gateway/runtime separation, plugin-based skills, model-agnostic backends—are now standard across the category.

## Related Architectures and Frameworks

Several other frameworks share architectural patterns with OpenClaw:

### LangChain and LangGraph

LangChain (<https://docs.langchain.com>) provides composable building blocks for LLM applications. LangChain and LangGraph have both reached v1.0 milestones.

> **Snippet status:** Runnable example pattern (validated against LangChain v1 docs, Feb 2026; `create_agent` builds a graph-based agent runtime using LangGraph under the hood).

```python
from langchain.agents import create_agent
from langchain_core.tools import tool

@tool
def search_documentation(query: str) -> str:
    """Search project documentation for relevant information."""
    # Implementation
    return "..."

agent = create_agent(
    model="gpt-4o-mini",
    tools=[search_documentation],
    system_prompt="Use tools when needed, then summarize clearly.",
)
result = agent.invoke({"messages": [{"role": "user", "content": "Find testing docs"}]})
```

**Shared patterns with OpenClaw**: Tool registration, agent composition, memory management.

LangGraph (<https://langchain-ai.github.io/langgraph/>) extends LangChain with graph-based agent orchestration.

### CrewAI

CrewAI (<https://docs.crewai.com/>) focuses on multi-agent collaboration with role-based specialization:

```python
from crewai import Agent, Task, Crew

researcher = Agent(
    role='Senior Researcher',
    goal='Discover new insights',
    backstory='Expert in finding and analyzing information',
    tools=[search_tool, analysis_tool]
)

writer = Agent(
    role='Technical Writer',
    goal='Create clear documentation',
    backstory='Skilled at explaining complex topics',
    tools=[writing_tool]
)

crew = Crew(
    agents=[researcher, writer],
    tasks=[research_task, writing_task],
    process=Process.sequential
)
```

**Shared patterns with OpenClaw**: Role-based agents, sequential and parallel execution, tool assignment per agent.

Version 1.8.0 (February 2026) added native A2A protocol support, enabling CrewAI agents to interoperate with agents built on other frameworks through standardised task delegation. CrewAI also added built-in MCP client support, so crews can connect to any MCP server as a tool source.

### Microsoft Semantic Kernel

Semantic Kernel (<https://learn.microsoft.com/semantic-kernel/>) emphasizes enterprise integration and plugin architecture. Semantic Kernel is converging with AutoGen into the **Microsoft Agent Framework** (see AutoGen section below):

```csharp
var kernel = Kernel.CreateBuilder()
    .AddOpenAIChatCompletion("gpt-4", apiKey)
    .Build();

// Import plugins
kernel.ImportPluginFromType<TimePlugin>();
kernel.ImportPluginFromType<FileIOPlugin>();

// Create agent with plugins
var agent = new ChatCompletionAgent {
    Kernel = kernel,
    Name = "ProjectAssistant",
    Instructions = "Help manage project tasks and documentation"
};
```

**Shared patterns with OpenClaw**: Plugin system, kernel/runtime separation, enterprise-ready design.

### AutoGen / Microsoft Agent Framework

AutoGen (<https://microsoft.github.io/autogen/stable/>) was rewritten from the ground up as v0.4 in January 2025, adopting an asynchronous, event-driven architecture. In October 2025, Microsoft announced the convergence of AutoGen and Semantic Kernel into a unified **Microsoft Agent Framework**, with general availability scheduled for Q1 2026. AutoGen v0.4 continues to receive critical fixes, but significant new features target the unified framework.

> **Snippet status:** Runnable example pattern (AutoGen v0.4 API, Feb 2026).

```python
import asyncio
from autogen_agentchat.agents import AssistantAgent
from autogen_ext.models.openai import OpenAIChatCompletionClient

async def main() -> None:
    agent = AssistantAgent(
        "coding_assistant",
        OpenAIChatCompletionClient(model="gpt-4o"),
    )
    result = await agent.run(task="Create a Python web scraper")
    print(result)

asyncio.run(main())
```

> **Note:** The v0.2 API (`from autogen import AssistantAgent`) is deprecated. Migrate to `autogen_agentchat` and `autogen_ext` packages. See the migration guide at <https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/migration-guide.html>.

**Shared patterns with OpenClaw**: Agent-to-agent communication, code execution environments, conversation-driven workflows.

### Comparing Architecture Patterns

| Feature | OpenClaw | LangChain | CrewAI | MS Agent Framework† |
|---------|----------|-----------|--------|---------------------|
| **Primary Focus** | Personal assistant | LLM app building | Team collaboration | Enterprise agents |
| **Runtime** | Local-first | Flexible | Python process | .NET/Python |
| **Multi-Agent** | Via swarms | Via LangGraph | Built-in | Built-in |
| **Tool System** | Plugin-based | Tool decorators | Tool assignment | Plugin imports |
| **Memory** | Persistent local | Configurable | Per-agent | Configurable |
| **Best For** | Personal automation | Prototyping | Complex workflows | Enterprise apps |

† Microsoft Agent Framework is the convergence of Semantic Kernel and AutoGen, announced October 2025.

### OpenAI Agents SDK

The OpenAI Agents SDK (<https://openai.github.io/openai-agents-python/>) is the production-ready successor to the experimental Swarm project, launched March 2025. It provides easily configurable agents with instructions and built-in tools, agent handoffs for intelligent control transfer, built-in guardrails, and tracing for debugging. Available in both Python and TypeScript.

**Shared patterns with OpenClaw**: Agent handoffs, tool registration, guardrails, conversation-driven workflows.

### Google Agent Development Kit (ADK)

Google ADK (<https://google.github.io/adk-docs/>) is an open-source framework introduced at Cloud NEXT 2025 for developing multi-agent systems. It is model-agnostic (optimised for Gemini but compatible with other providers) and supports the Agent-to-Agent (A2A) protocol for inter-agent communication. Primary SDK is Python; TypeScript and Go SDKs are in active development.

**Shared patterns with OpenClaw**: Multi-agent orchestration, model-agnostic design, tool registration.

## MCP: Modern Tooling and Adoption

The **Model Context Protocol (MCP)** (<https://modelcontextprotocol.io/>) has become a practical standard for connecting agents to tools and data sources. In December 2025, Anthropic donated MCP governance to the **Agentic AI Foundation (AAIF)** under the Linux Foundation, signalling its transition from a single-vendor project to a true industry standard. The ecosystem reports over 97 million monthly SDK downloads and more than 10,000 active MCP servers. **MCP Apps** launched as the first official extension, enabling interactive UIs (charts, forms, dashboards) to render directly inside MCP clients. Today, MCP is less about novel capability and more about **reliable interoperability**: the same tool server can be used by multiple agent clients with consistent schemas, permissions, and response formats.

### What MCP Brings to Tools

- **Portable tool definitions**: JSON schemas and well-known server metadata make tools discoverable across clients.
- **Safer tool execution**: capability-scoped permissions, explicit parameters, and auditable tool calls.
- **Composable context**: servers can enrich model context with structured resources (files, APIs, or databases) without bespoke glue code.

Recent MCP revisions also strengthen production readiness: streamable HTTP transport, standardized OAuth 2.1-based authorization discovery, and clearer user-input elicitation flows. These changes matter because they reduce client/server edge-case handling and make policy enforcement more uniform across implementations.

### Common Usage Patterns

1. **Server-based tool catalogs**
   - Teams deploy MCP servers per domain (e.g., "repo-tools", "ops-tools", "research-tools").
   - Clients discover available tools at runtime and choose based on metadata, not hardcoded lists.

2. **Context stitching**
   - Agents gather context from multiple servers (docs, tickets, metrics) and assemble it into a task-specific prompt.
   - The server provides structured resources so the client can keep the prompt lean.

3. **Permission-first workflows**
   - Tool calls are scoped by project, environment, or role.
   - Audit logs track who called what tool with which inputs.

4. **Fallback-first reliability**
   - Clients maintain fallbacks when a server is down (cached data, read-only mirrors, or alternative tool servers).

5. **Registry-backed discovery**
   - Teams publish approved servers to an internal or public registry for discoverability.
   - Activation still happens through local policy, so discovery does not imply execution permission.

### Acceptance Across Major Clients

MCP is broadly accepted as a **tooling interoperability layer**. The specifics vary by vendor, but the pattern is consistent: MCP servers expose the tools and resources, while clients orchestrate tool calls and manage safety policies.

- **Codex (GPT-5.3-Codex)** (<https://openai.com/index/introducing-codex/>)
  Codex clients commonly use MCP servers to standardize tool access (repo browsing, test execution, task automation). Codex also supports skills packaged with `SKILL.md` and progressive disclosure (see <https://developers.openai.com/codex>). The main adoption pattern is organization-level MCP servers that provide consistent tools across multiple repos.

- **GitHub Copilot** (<https://docs.github.com/en/copilot>)  
  Copilot deployments increasingly treat MCP as a bridge between editor experiences and organization tooling. This typically means MCP servers that expose repo-aware tools (search, CI status, documentation retrieval) so the assistant can operate with consistent, policy-driven access.

- **Claude** (<https://code.claude.com/docs>)  
  Claude integrations often use MCP to provide structured context sources (knowledge bases, issue trackers, dashboards). The MCP server becomes the policy boundary, while the client focuses on prompt composition and response quality.

### Practical Guidance for Authors and Teams

- **Document your MCP servers** like any other tool: include schemas, permissions, and usage examples.
- **Version tool contracts** so clients can adopt changes incrementally.
- **Prefer narrow, composable tools** over large monolithic endpoints.
- **Treat MCP as infrastructure**: invest in uptime, monitoring, and security reviews.

## Best Practices

### Version Tools and Skills
```python
class VersionedTool:
    def __init__(self, version: str):
        self.version = version
        self.name = f"{self.__class__.__name__}_v{version}"
```

### Test Independently
```python
# test_tools.py
import pytest

def test_markdown_validator():
    tool = MarkdownValidatorTool()
    
    # Test valid markdown
    valid_md = "# Header\n\nContent"
    result = tool.execute(valid_md)
    assert result['valid']
    
    # Test invalid markdown
    invalid_md = "```python\ncode without closing"
    result = tool.execute(invalid_md)
    assert not result['valid']
    assert any(i['type'] == 'unclosed_code_block' for i in result['issues'])
```

### Provide Fallbacks
```python
class ResilientTool:
    def __init__(self, primary_impl, fallback_impl):
        self.primary = primary_impl
        self.fallback = fallback_impl
    
    def execute(self, **kwargs):
        try:
            return self.primary.execute(**kwargs)
        except Exception as e:
            logger.warning(f"Primary implementation failed: {e}")
            return self.fallback.execute(**kwargs)
```

### Monitor Usage
```python
class MonitoredTool:
    def __init__(self, tool, metrics_collector):
        self.tool = tool
        self.metrics = metrics_collector
    
    def execute(self, **kwargs):
        start = time.time()
        try:
            result = self.tool.execute(**kwargs)
            self.metrics.record_success(self.tool.name, time.time() - start)
            return result
        except Exception as e:
            self.metrics.record_failure(self.tool.name, str(e))
            raise
```

## Emerging Standards: AGENTS.md

This chapter is the canonical AGENTS.md reference for the book. Other chapters should link here rather than duplicating full templates.

### The AGENTS.md Pseudo-Standard

**AGENTS.md** has emerged as an open pseudo-standard for providing AI coding agents with project-specific instructions. Think of it as a "README for agents"—offering structured, machine-readable guidance that helps agents understand how to work within a codebase.

#### Purpose and Benefits

- **Consistent Instructions**: All agents receive the same project-specific guidance
- **Rapid Onboarding**: New agent sessions understand the project immediately
- **Safety Boundaries**: Clear boundaries prevent accidental damage to protected files
- **Maintainability**: Single source of truth for agent behavior in a project

#### Structure and Placement

AGENTS.md files can be placed hierarchically in a project:

```text
project/
|-- AGENTS.md           # Root-level instructions (project-wide)
|-- src/
|   `-- AGENTS.md       # Module-specific instructions
|-- tests/
|   `-- AGENTS.md       # Testing conventions
`-- docs/
    `-- AGENTS.md       # Documentation guidelines
```

Agents use the nearest AGENTS.md file, enabling scoped configuration for monorepos or complex projects.

#### Example AGENTS.md

```markdown
# AGENTS.md

## Project Overview
This is a TypeScript web application using Express.js and React.

## Setup Instructions
npm install
npm run dev

## Coding Conventions
- Language: TypeScript 5.x
- Style guide: Airbnb
- Formatting: Prettier with provided config
- Test framework: Jest

## Build and Deploy
- Build: `npm run build`
- Test: `npm test`
- Deploy: CI/CD via GitHub Actions

## Agent-Specific Notes
- Always run `npm run lint` before committing
- Never modify files in `vendor/` or `.github/workflows/`
- Secrets are in environment variables, never hardcoded
- All API endpoints require authentication middleware
```

### Related Standards: Skills and Capabilities

While AGENTS.md has achieved broad adoption as the standard for project-level agent instructions, the space continues to evolve. Several related concepts are under discussion in the community:

**Skills Documentation**

There is no formal `skills.md` standard, but skill documentation patterns are emerging:

- **Skill catalogs** listing available agent capabilities
- **Capability declarations** specifying what an agent can do
- **Dependency manifests** defining tool and skill requirements

**Personality and Values**

Some frameworks experiment with "soul" or personality configuration. Note that "soul" is a metaphorical term used in some AI agent frameworks to describe an agent's core personality, values, and behavioral guidelines—it's industry jargon rather than a formal technical specification:

- **System prompts** defining agent persona and communication style
- **Value alignment** specifying ethical guidelines and constraints
- **Behavioral constraints** limiting what agents should and shouldn't do

Currently, these are implemented in vendor-specific formats rather than open standards. The community continues to discuss whether formalization is needed.

## How Agents Become Aware of Imports

One of the most practical challenges in agentic development is helping agents understand a codebase's import structure and dependencies. When an agent modifies code, it must know what modules are available, where they come from, and how to properly reference them.

### The Import Awareness Problem

When agents generate or modify code, they face several import-related challenges:

1. **Missing imports**: Adding code that uses undefined symbols
2. **Incorrect import paths**: Using wrong relative or absolute paths
3. **Circular dependencies**: Creating imports that cause circular reference errors
4. **Unused imports**: Leaving orphan imports after code changes
5. **Conflicting names**: Importing symbols that shadow existing names

### Mechanisms for Import Discovery

Modern coding agents use multiple strategies to understand imports:

#### Static Analysis Tools

Agents leverage language servers and static analyzers to understand import structure:

```python
class ImportAnalyzer:
    """Analyze imports using static analysis"""
    
    def __init__(self, workspace_root: str):
        self.workspace = workspace_root
        self.import_graph = {}
    
    def analyze_file(self, filepath: str) -> dict:
        """Extract import information from a file"""
        with open(filepath) as f:
            content = f.read()
        
        # Parse AST to find imports
        tree = ast.parse(content)
        imports = []
        
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    imports.append({
                        'type': 'import',
                        'module': alias.name,
                        'alias': alias.asname
                    })
            elif isinstance(node, ast.ImportFrom):
                imports.append({
                    'type': 'from_import',
                    'module': node.module,
                    'names': [a.name for a in node.names],
                    'level': node.level  # relative import level
                })
        
        return {
            'file': filepath,
            'imports': imports,
            'defined_symbols': self._extract_definitions(tree)
        }
    
    def build_dependency_graph(self) -> dict:
        """Build a graph of all file dependencies"""
        for filepath in self._find_source_files():
            analysis = self.analyze_file(filepath)
            self.import_graph[filepath] = analysis
        return self.import_graph
```

#### Language Server Protocol (LSP)

Language servers provide real-time import information that agents can query:

```python
class LSPImportProvider:
    """Use LSP to discover available imports"""
    
    async def get_import_suggestions(self, symbol: str, context_file: str) -> list:
        """Get import suggestions for an undefined symbol"""
        
        # Query language server for symbol locations
        response = await self.lsp_client.request('textDocument/codeAction', {
            'textDocument': {'uri': context_file},
            'context': {
                'diagnostics': [{
                    'message': f"Cannot find name '{symbol}'"
                }]
            }
        })
        
        # Extract import suggestions from code actions
        suggestions = []
        for action in response:
            if 'import' in action.get('title', '').lower():
                suggestions.append({
                    'import_statement': action['edit']['changes'],
                    'source': action.get('title')
                })
        
        return suggestions
    
    async def get_exported_symbols(self, module_path: str) -> list:
        """Get all exported symbols from a module"""
        
        # Use workspace/symbol to find exports
        symbols = await self.lsp_client.request('workspace/symbol', {
            'query': '',
            'uri': module_path
        })
        
        return [s['name'] for s in symbols if s.get('kind') in EXPORTABLE_KINDS]
```

#### Project Configuration Files

Agents read configuration files to understand module resolution:

```python
class ProjectConfigReader:
    """Read project configs to understand import paths"""
    
    def get_import_config(self, project_root: str) -> dict:
        """Extract import configuration from project files"""
        
        config = {
            'base_paths': [],
            'aliases': {},
            'external_packages': []
        }
        
        # TypeScript/JavaScript: tsconfig.json, jsconfig.json
        tsconfig_path = os.path.join(project_root, 'tsconfig.json')
        if os.path.exists(tsconfig_path):
            with open(tsconfig_path) as f:
                tsconfig = json.load(f)
            
            compiler_opts = tsconfig.get('compilerOptions', {})
            config['base_paths'].append(compiler_opts.get('baseUrl', '.'))
            config['aliases'] = compiler_opts.get('paths', {})
        
        # Python: pyproject.toml, setup.py
        pyproject_path = os.path.join(project_root, 'pyproject.toml')
        if os.path.exists(pyproject_path):
            with open(pyproject_path) as f:
                pyproject = toml.load(f)
            
            # Extract package paths from tool.setuptools or poetry config
            if 'tool' in pyproject:
                if 'setuptools' in pyproject['tool']:
                    config['base_paths'].extend(
                        pyproject['tool']['setuptools'].get('package-dir', {}).values()
                    )
        
        return config
```

#### Package Manifest Analysis

Agents check package manifests to know what's available:

```python
class PackageManifestReader:
    """Read package manifests to understand available dependencies"""
    
    def get_available_packages(self, project_root: str) -> dict:
        """Get list of available packages from manifest"""
        
        packages = {'direct': [], 'transitive': []}
        
        # Node.js: package.json
        package_json = os.path.join(project_root, 'package.json')
        if os.path.exists(package_json):
            with open(package_json) as f:
                pkg = json.load(f)
            packages['direct'].extend(pkg.get('dependencies', {}).keys())
            packages['direct'].extend(pkg.get('devDependencies', {}).keys())
        
        # Python: requirements.txt, Pipfile, pyproject.toml
        requirements = os.path.join(project_root, 'requirements.txt')
        if os.path.exists(requirements):
            with open(requirements) as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#'):
                        # Extract package name (before version specifier)
                        pkg_name = re.split(r'[<>=!]', line)[0].strip()
                        packages['direct'].append(pkg_name)
        
        return packages
```

### Best Practices for Import-Aware Agents

#### Document Import Conventions in AGENTS.md

For standardized terminology (artefact, discovery, import, install, activate) and trust boundaries, see [Discovery and Imports](050-discovery-imports.md). In this section we apply those concepts to codebase-level import resolution.

Include import guidance in your project's AGENTS.md:

```markdown
## Import Conventions

### Path Resolution
- Use absolute imports from `src/` as the base
- Prefer named exports over default exports
- Group imports: stdlib, external packages, local modules

### Example Import Order
```python
# Standard library
import os
import sys
from typing import Dict, List

# Third-party packages
import requests
from pydantic import BaseModel

# Local modules
from src.utils import helpers
from src.models import User
```

### Alias Conventions
- `@/` maps to `src/`
- `@components/` maps to `src/components/`
```text

#### Use Import Auto-Fix Tools

Configure agents to use automatic import fixers:

```python
class ImportAutoFixer:
    """Automatically fix import issues in agent-generated code"""
    
    def __init__(self, tools: List[Tool]):
        self.isort = tools.get('isort')  # Python import sorting
        self.eslint = tools.get('eslint')  # JS/TS import fixing
    
    async def fix_imports(self, filepath: str) -> dict:
        """Fix and organize imports in a file"""
        
        results = {'fixed': [], 'errors': []}
        
        if filepath.endswith('.py'):
            # Run isort for Python
            result = await self.isort.execute(filepath)
            if result['success']:
                results['fixed'].append('isort: organized imports')
            
            # Run autoflake to remove unused imports
            result = await self.autoflake.execute(
                filepath, 
                remove_unused_imports=True
            )
            if result['success']:
                results['fixed'].append('autoflake: removed unused')
        
        elif filepath.endswith(('.ts', '.tsx', '.js', '.jsx')):
            # Run eslint with import rules
            result = await self.eslint.execute(
                filepath,
                fix=True,
                rules=['import/order', 'unused-imports/no-unused-imports']
            )
            if result['success']:
                results['fixed'].append('eslint: fixed imports')
        
        return results
```

#### Validate Imports Before Committing

Add import validation to agent workflows:

```yaml
# .github/workflows/validate-imports.yml
name: Validate Imports
on: [pull_request]

jobs:
  check-imports:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      
      - name: Check Python imports
        run: |
          pip install isort autoflake
          isort --check-only --diff .
          autoflake --check --remove-all-unused-imports -r .
      
      - name: Check TypeScript imports
        run: |
          npm ci
          npx eslint --rule 'import/no-unresolved: error' .
```

### Import Awareness in Multi-Agent Systems

When multiple agents collaborate, maintaining consistent import awareness requires coordination:

```python
class SharedImportContext:
    """Shared import context for multi-agent systems"""
    
    def __init__(self):
        self.import_cache = {}
        self.pending_additions = []
    
    def register_new_export(self, module: str, symbol: str, agent_id: str):
        """Register a new export created by an agent"""
        if module not in self.import_cache:
            self.import_cache[module] = []
        
        self.import_cache[module].append({
            'symbol': symbol,
            'added_by': agent_id,
            'timestamp': datetime.now()
        })
    
    def query_available_imports(self, symbol: str) -> List[dict]:
        """Query where a symbol can be imported from"""
        results = []
        for module, exports in self.import_cache.items():
            for export in exports:
                if export['symbol'] == symbol:
                    results.append({
                        'module': module,
                        'symbol': symbol,
                        'import_statement': f"from {module} import {symbol}"
                    })
        return results
```

Understanding how agents discover and manage imports is essential for building reliable agentic coding systems. The combination of static analysis, language servers, project configuration, and clear documentation ensures agents can write code that integrates correctly with existing codebases.

## Key Takeaways

Tools are atomic capabilities that perform single operations, while skills are composed behaviours that orchestrate multiple tools to accomplish complex tasks. When designing tools, follow single responsibility principles and provide clear interfaces that agents can use reliably. Skills orchestrate multiple tools to accomplish complex tasks, and they can themselves be composed to create more powerful capabilities.

Use registries for discovery and management, allowing agents to find available tools and skills at runtime. Always document, test, and version your tools and skills so that changes are traceable and consumers know what to expect. Monitor usage to identify issues and optimisation opportunities—without metrics, you cannot improve performance or reliability.

AGENTS.md is the emerging standard for project-level agent instructions, providing a single source of truth for how agents should work within a codebase. Skills Protocol defines how runtimes execute skills, while Agent Skills defines how skills are packaged for distribution. MCP standardises tool interoperability across clients and hosts, allowing the same tool server to work with multiple agent platforms.

Import awareness requires combining static analysis, Language Server Protocol (LSP) integration, and project configuration reading to ensure agents generate code with correct dependencies. OpenClaw, LangChain, CrewAI, and similar frameworks share common patterns for tool and skill management that you can learn from regardless of which platform you choose.

<!-- Edit notes:
Sections expanded: Chapter Preview, Understanding Skills vs. Tools (both subsections), Relationship to MCP, Key Takeaways
Lists preserved: Examples in code blocks (these are actual code/configuration examples that must remain as-is), file structure layouts (must remain enumerable for clarity)
Ambiguous phrases left ambiguous: None identified
-->
