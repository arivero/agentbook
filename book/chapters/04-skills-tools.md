---
title: "Skills and Tools Management"
order: 4
---

# Skills and Tools Management

## Chapter Preview

- Define tools, skills, and how they map to operational workflows.
- Compare packaging formats and protocols for distributing skills.
- Walk through safe patterns for skill development and lifecycle management.

## Understanding Skills vs. Tools

### Tools
**Tools** are atomic capabilities that agents can use to interact with their environment. They are the building blocks of agent functionality.

Examples:
- File system operations (read, write, delete)
- API calls (GET, POST, PUT, DELETE)
- Shell commands
- Database queries

### Skills
**Skills** are higher-level capabilities composed of multiple tools and logic. They represent complex behaviors that agents can learn and apply.

Examples:
- Code review (using git, static analysis, test execution)
- Documentation writing (using research, markdown editing, validation)
- Bug fixing (using debugging, testing, code editing)

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

## Skills Protocol and Agent Skills

The ecosystem now distinguishes between **runtime protocols** (how tools are exposed to agents) and **packaging formats** (how skills are stored and documented). Three complementary standards matter most:

- **Skills Protocol**: A runtime protocol for connecting agents to Skills and Blobs through a Skills Runtime, with sandboxed code execution and a consistent tool surface. Official docs live at <https://skillsprotocol.com/> and the implementation guide at <https://skillsprotocol.com/implementation-guide>.  
- **Agent Skills format**: A filesystem packaging spec centered on a `SKILL.md` file plus optional scripts, references, and assets. The canonical format is described at <https://skillsprotocol.com/skill-structure> and <https://skillsprotocol.com/skill-manifest>.
- **MCP (Model Context Protocol)**: A protocol for connecting models to external tools and data sources. See <https://modelcontextprotocol.io/>.

### Relationship to MCP

Use **Skills Protocol** when you need a runtime that can mount skills, execute code in a sandbox, and handle large artifacts (blobs). Use **MCP** when you need a standardized tool gateway across many models or environments. Use **Agent Skills** when you want a portable, repo-friendly way to package skills—regardless of whether you serve them via Skills Protocol or MCP.

### Skills Protocol: Minimal Tool Surface (Protocol Sketch)

The Skills Protocol specification defines a small, stable set of tool methods. A runtime exposes these tools to an agent via JSON-RPC over HTTP. The method names below match the official specification (see the docs cited above):

```json
{
  "jsonrpc": "2.0",
  "id": "request-1",
  "method": "list_skills",
  "params": {}
}
```

```json
{
  "jsonrpc": "2.0",
  "id": "request-2",
  "method": "describe_skill",
  "params": {
    "skill_id": "skill://code-review"
  }
}
```

```json
{
  "jsonrpc": "2.0",
  "id": "request-3",
  "method": "execute_skill",
  "params": {
    "skill_id": "skill://code-review",
    "inputs": {
      "pull_request": 128
    }
  }
}
```

> **Note:** These are protocol-level sketches for clarity. Refer to the Skills Protocol Implementation Guide for the full schema and error model.

### Agent Skills Format: Canonical Layout

Example 4-1. `skills/code-review/`

```text
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

Example 4-2. `skills/code-review/SKILL.md`

```markdown
---
name: code-review
description: Review pull requests for security, correctness, and clarity.
inputs:
  pull_request:
    type: integer
    description: Pull request number to review.
runtime:
  entrypoint: scripts/review.py
  language: python
permissions:
  network: false
  filesystem:
    read:
      - repo/*
---

# Code Review Skill

This skill reviews a pull request and produces a structured report.
```

> **Tip:** Keep `SKILL.md` concise and front-load the information the agent needs to act. Progressive disclosure means heavier details move to `references/` or `scripts/` so the agent loads them only when needed (see the Codex skills guide at <https://platform.openai.com/docs/guides/codex/skills>).

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

> **Note:** OpenClaw and pi-mono are hypothetical composite examples used to illustrate architecture patterns. They are not official products as of 2026-02.

**OpenClaw** is a personal, local-first AI assistant that runs a gateway control plane and connects to many chat providers and device surfaces. It emphasizes multi-channel inboxes, tool access, and skill management inside a user-owned runtime.

OpenClaw is built on the **pi-mono** ecosystem. The pi-mono monorepo provides an agent runtime, tool calling infrastructure, and multi-provider LLM APIs that OpenClaw can leverage to keep the assistant portable across models and deployments.

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
- Community skill marketplace for sharing and discovery

### Key Design Principles

1. **Privacy-First**: All state and memory default to local storage—data never leaves the device unless explicitly configured
2. **BYOM (Bring Your Own Model)**: Seamlessly supports cloud LLMs and local inference
3. **Proactive Behavior**: "Heartbeat" feature enables autonomous wake-up and environment monitoring
4. **Persistent Memory**: Learns and adapts over long-term interactions

Key takeaways for skills/tools architecture:

- **Gateway + runtime separation** keeps tools and skills consistent while integrations change: the gateway handles channels and routing, while pi-mono-style runtimes handle tool execution.
- **Integration catalogs** (like OpenClaw’s integrations list and skill registry) are a user-facing map of capability. They surface what tools can do and what skills are available without forcing users to understand low-level APIs.
- **Skills become reusable assets** once tied to integrations: a “Slack triage” skill can target different workspaces without changing the underlying tools, as long as the integration provides the same tool contracts.

## Related Architectures and Frameworks

Several other frameworks share architectural patterns with OpenClaw:

### LangChain and LangGraph

LangChain (<https://python.langchain.com/>) provides composable building blocks for LLM applications:

```python
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.tools import tool

@tool
def search_documentation(query: str) -> str:
    """Search project documentation for relevant information."""
    # Implementation
    pass

# Create agent with tools
agent = create_tool_calling_agent(llm, tools=[search_documentation], prompt=prompt)
executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
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

### Microsoft Semantic Kernel

Semantic Kernel (<https://learn.microsoft.com/semantic-kernel/>) emphasizes enterprise integration and plugin architecture:

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

### AutoGen

AutoGen (<https://microsoft.github.io/autogen/>) specializes in conversational multi-agent systems:

```python
from autogen import AssistantAgent, UserProxyAgent

assistant = AssistantAgent(
    name="coding_assistant",
    llm_config={"model": "gpt-4"},
    system_message="You are a helpful coding assistant."
)

user_proxy = UserProxyAgent(
    name="user",
    human_input_mode="NEVER",
    code_execution_config={"work_dir": "coding"}
)

# Agents collaborate through conversation
user_proxy.initiate_chat(assistant, message="Create a Python web scraper")
```

**Shared patterns with OpenClaw**: Agent-to-agent communication, code execution environments, conversation-driven workflows.

### Comparing Architecture Patterns

| Feature | OpenClaw | LangChain | CrewAI | Semantic Kernel | AutoGen |
|---------|----------|-----------|--------|-----------------|---------|
| **Primary Focus** | Personal assistant | LLM app building | Team collaboration | Enterprise plugins | Multi-agent chat |
| **Runtime** | Local-first | Flexible | Python process | .NET/Python | Python process |
| **Multi-Agent** | Via swarms | Via LangGraph | Built-in | Via agents | Built-in |
| **Tool System** | Plugin-based | Tool decorators | Tool assignment | Plugin imports | Tool decorators |
| **Memory** | Persistent local | Configurable | Per-agent | Session-based | Conversation |
| **Best For** | Personal automation | Prototyping | Complex workflows | Enterprise apps | Research/experimentation |

## MCP: Modern Tooling and Adoption

The **Model Context Protocol (MCP)** (<https://modelcontextprotocol.io/>) has become a practical standard for connecting agents to tools and data sources. Today, MCP is less about novel capability and more about **reliable interoperability**: the same tool server can be used by multiple agent clients with consistent schemas, permissions, and response formats.

### What MCP Brings to Tools

- **Portable tool definitions**: JSON schemas and well-known server metadata make tools discoverable across clients.
- **Safer tool execution**: capability-scoped permissions, explicit parameters, and auditable tool calls.
- **Composable context**: servers can enrich model context with structured resources (files, APIs, or databases) without bespoke glue code.

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

### Acceptance Across Major Clients

MCP is broadly accepted as a **tooling interoperability layer**. The specifics vary by vendor, but the pattern is consistent: MCP servers expose the tools and resources, while clients orchestrate tool calls and manage safety policies.

- **Codex (GPT-5.2-Codex)** (<https://openai.com/index/introducing-codex/>)  
  Codex clients commonly use MCP servers to standardize tool access (repo browsing, test execution, task automation). Codex also supports skills packaged with `SKILL.md` and progressive disclosure (see <https://platform.openai.com/docs/guides/codex/skills>). The main adoption pattern is organization-level MCP servers that provide consistent tools across multiple repos.

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

- Tools are atomic capabilities; skills are composed behaviors
- Design tools with single responsibility and clear interfaces
- Skills orchestrate multiple tools to accomplish complex tasks
- Use registries for discovery and management
- Skills can be composed to create more powerful capabilities
- Always document, test, and version your tools and skills
- Monitor usage to identify issues and optimization opportunities
- AGENTS.md is the emerging standard for project-level agent instructions
- Skills Protocol defines how runtimes execute skills; Agent Skills defines how they are packaged
- MCP standardizes tool interoperability across clients and hosts
- Import awareness requires combining static analysis, LSP, and project configuration
- OpenClaw, LangChain, CrewAI, and similar frameworks share common patterns for tool and skill management
