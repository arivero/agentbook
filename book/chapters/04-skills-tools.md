# Chapter 4: Skills and Tools Management

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

### 1. Single Responsibility
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

### 2. Clear Interfaces
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

### 3. Error Handling
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

### 4. Documentation
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

## MCP in 2026: Modern Tooling and Adoption

The **Model Context Protocol (MCP)** has become a practical standard for connecting agents to tools and data sources. In 2026, it is less about novel capability and more about **reliable interoperability**: the same tool server can be used by multiple agent clients with consistent schemas, permissions, and response formats.

### What MCP Brings to Tools

- **Portable tool definitions**: JSON schemas and well-known server metadata make tools discoverable across clients.
- **Safer tool execution**: capability-scoped permissions, explicit parameters, and auditable tool calls.
- **Composable context**: servers can enrich model context with structured resources (files, APIs, or databases) without bespoke glue code.

### Modern Usage Patterns (2026)

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

- **Codex**  
  Codex clients commonly use MCP servers to standardize tool access (repo browsing, test execution, task automation). MCP reduces per-project wiring by centralizing tool definitions and auth. The main adoption pattern is organization-level MCP servers that provide consistent tools across multiple repos.

- **GitHub Copilot**  
  Copilot deployments increasingly treat MCP as a bridge between editor experiences and organization tooling. This typically means MCP servers that expose repo-aware tools (search, CI status, documentation retrieval) so the assistant can operate with consistent, policy-driven access.

- **Claude**  
  Claude integrations often use MCP to provide structured context sources (knowledge bases, issue trackers, dashboards). The MCP server becomes the policy boundary, while the client focuses on prompt composition and response quality.

### Practical Guidance for Authors and Teams

- **Document your MCP servers** like any other tool: include schemas, permissions, and usage examples.
- **Version tool contracts** so clients can adopt changes incrementally.
- **Prefer narrow, composable tools** over large monolithic endpoints.
- **Treat MCP as infrastructure**: invest in uptime, monitoring, and security reviews.

## Best Practices

### 1. Version Tools and Skills
```python
class VersionedTool:
    def __init__(self, version: str):
        self.version = version
        self.name = f"{self.__class__.__name__}_v{version}"
```

### 2. Test Independently
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

### 3. Provide Fallbacks
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

### 4. Monitor Usage
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

## Key Takeaways

- Tools are atomic capabilities; skills are composed behaviors
- Design tools with single responsibility and clear interfaces
- Skills orchestrate multiple tools to accomplish complex tasks
- Use registries for discovery and management
- Skills can be composed to create more powerful capabilities
- Always document, test, and version your tools and skills
- Monitor usage to identify issues and optimization opportunities
