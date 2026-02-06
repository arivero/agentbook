---
title: "Agents for Coding"
order: 8
---

# Agents for Coding

## Chapter Preview

This chapter compares coding-agent architectures and team patterns, helping you choose the right approach for your project's complexity and scale. It shows the correct way to configure GitHub Copilot coding agent, with working examples you can adapt. Finally, it provides buildable examples with clear labels distinguishing runnable code from pseudocode.

## Introduction

Coding agents represent the most mature category of AI agents in software development. They have evolved from simple autocomplete tools to autonomous entities capable of planning, writing, testing, debugging, and even scaffolding entire software architectures with minimal human input. This chapter explores the specialized architectures, scaffolding patterns, and best practices for deploying agents in coding workflows.

## The Evolution of Coding Agents

### From Autocomplete to Autonomy

The progression of coding agents follows a clear trajectory through four phases.

**Code Completion (2020–2022)** introduced basic pattern matching and next-token prediction, offering suggestions for the next few tokens based on immediate context.

**Context-Aware Assistance (2022–2024)** added understanding of project structure and intent, allowing agents to make suggestions that fit the broader codebase.

**Task-Oriented Agents (2024–present)** can complete multi-step tasks independently, taking a high-level instruction and executing a series of operations to fulfil it.

**Autonomous Development (emerging)** represents the frontier, with agents capable of full feature implementation, testing, and deployment with minimal human intervention.

### Current Capabilities

Modern coding agents can perform a range of sophisticated tasks.

**Understand requirements.** Agents can parse natural language specifications and translate them to code, bridging the gap between human intent and machine-executable instructions.

**Plan solutions.** Agents can break down complex features into implementable steps, creating a roadmap for development.

**Generate code.** Agents can write production-quality code across multiple files, handling everything from utility functions to full modules.

**Test and debug.** Agents can create tests, identify bugs, and fix issues, shortening the feedback loop between writing code and validating it.

**Scaffold projects.** Agents can initialise projects with appropriate structure and configuration, setting up the foundation for further development.

**Review and refactor.** Agents can analyse code quality and suggest improvements, helping maintain code health over time.

## Specialized Architectures

### Single-Agent Architectures

The simplest architecture involves one agent with access to all necessary tools.

Example 7-2. Single-agent architecture (pseudocode)

```python
class CodingAgent:
    """Single-agent architecture for coding tasks"""
    
    def __init__(self, llm, tools):
        self.llm = llm
        self.tools = {
            'file_read': FileReadTool(),
            'file_write': FileWriteTool(),
            'terminal': TerminalTool(),
            'search': CodeSearchTool(),
            'test_runner': TestRunnerTool()
        }
        self.context = AgentContext()
    
    async def execute(self, task: str) -> dict:
        """Execute a coding task end-to-end"""
        # 1. Understand the task
        plan = await self.plan_task(task)
        
        # 2. Execute each step
        results = []
        for step in plan.steps:
            result = await self.execute_step(step)
            results.append(result)
            
            # Adapt based on results
            if not result.success:
                plan = await self.replan(plan, result)
        
        return {'success': True, 'results': results}
```

**Best for**: Simple tasks, small codebases, single-developer workflows.

### Multi-Agent Architectures

Complex projects benefit from specialized agents working together.

Example 7-3. Multi-agent architecture (pseudocode)

```python
class CodingAgentTeam:
    """Multi-agent architecture mirroring a development team"""
    
    def __init__(self):
        self.architect = ArchitectAgent()
        self.implementer = ImplementerAgent()
        self.tester = TesterAgent()
        self.reviewer = ReviewerAgent()
        self.coordinator = CoordinatorAgent()
    
    async def execute_feature(self, specification: str):
        """Execute a feature request using the agent team"""
        
        # 1. Architecture phase
        design = await self.architect.design(specification)
        
        # 2. Implementation phase (can be parallelized)
        implementations = await asyncio.gather(*[
            self.implementer.implement(component)
            for component in design.components
        ])
        
        # 3. Testing phase
        test_results = await self.tester.test(implementations)
        
        # 4. Review phase
        review = await self.reviewer.review(implementations)
        
        # 5. Iteration if needed
        if not review.approved:
            return await self.handle_review_feedback(review)
        
        return {'success': True, 'implementation': implementations}
```

**Best for**: Large projects, team environments, complex features.

### Subagent and Swarms Mode

Modern frameworks like Claude Code support dynamic subagent spawning:

```python
class SwarmCoordinator:
    """Coordinate a swarm of specialized subagents"""
    
    def __init__(self, max_agents=10):
        self.max_agents = max_agents
        self.active_agents = {}
    
    async def spawn_subagent(self, task_type: str, context: dict):
        """Spawn a specialized subagent for a specific task"""
        
        agent_configs = {
            'frontend': FrontendAgentConfig(),
            'backend': BackendAgentConfig(),
            'devops': DevOpsAgentConfig(),
            'security': SecurityAgentConfig(),
            'documentation': DocsAgentConfig()
        }
        
        config = agent_configs.get(task_type)
        agent = await self.create_agent(config, context)
        
        self.active_agents[agent.id] = agent
        return agent
    
    async def execute_parallel(self, tasks: list):
        """Execute multiple tasks in parallel using subagents"""
        
        agents = [
            await self.spawn_subagent(task.type, task.context)
            for task in tasks
        ]
        
        results = await asyncio.gather(*[
            agent.execute(task)
            for agent, task in zip(agents, tasks)
        ])
        
        return self.aggregate_results(results)
```

## Scaffolding for Coding Agents

### Project Initialization

Coding agents need scaffolding that helps them understand and work with projects:

```yaml
# .github/agents/coding-agent.yml
name: coding-agent
description: Scaffolding for coding agent operations

workspace:
  root: ./
  source_dirs: [src/, lib/]
  test_dirs: [tests/, spec/]
  config_files: [package.json, tsconfig.json, .eslintrc]

conventions:
  language: typescript
  framework: express
  testing: jest
  style: prettier + eslint

tools:
  enabled:
    - file_operations
    - terminal
    - git
    - package_manager
  restricted:
    - network_access
    - system_commands

safety:
  max_file_changes: 20
  protected_paths:
    - .github/workflows/
    - .env*
    - secrets/
  require_tests: true
  require_review: true
```

### The AGENTS.md Standard

For canonical AGENTS.md structure and rationale, see [Skills and Tools Management](040-skills-tools.md). For import/install/activate terminology and trust boundaries, see [Discovery and Imports](050-discovery-imports.md). In this chapter we focus on coding-agent execution patterns and platform behavior.

### Context Management

Coding agents need effective context management to work across large codebases:

```python
class CodingContext:
    """Manage context for coding agents"""
    
    def __init__(self, workspace_root: str):
        self.workspace_root = workspace_root
        self.file_index = FileIndex(workspace_root)
        self.symbol_table = SymbolTable()
        self.active_files = LRUCache(max_size=50)
    
    def get_relevant_context(self, task: str) -> dict:
        """Get context relevant to the current task"""
        
        # 1. Parse task to identify relevant files/symbols
        entities = self.extract_entities(task)
        
        # 2. Retrieve relevant files
        files = self.file_index.search(entities)
        
        # 3. Get symbol definitions
        symbols = self.symbol_table.lookup(entities)
        
        # 4. Include recent changes
        recent = self.get_recent_changes()
        
        return {
            'files': files,
            'symbols': symbols,
            'recent_changes': recent,
            'workspace_config': self.get_config()
        }
    
    def update_context(self, changes: list):
        """Update context after agent makes changes"""
        for change in changes:
            self.file_index.update(change.path)
            self.symbol_table.reindex(change.path)
            self.active_files.add(change.path)
```

### Tool Registries

Coding agents need well-organized tool access:

```python
class CodingToolRegistry:
    """Registry of tools available to coding agents"""
    
    def __init__(self):
        self._tools = {}
        self._register_default_tools()
    
    def _register_default_tools(self):
        """Register standard coding tools"""
        
        # File operations
        self.register('read_file', ReadFileTool())
        self.register('write_file', WriteFileTool())
        self.register('search_files', SearchFilesTool())
        
        # Code operations
        self.register('parse_ast', ParseASTTool())
        self.register('refactor', RefactorTool())
        self.register('format_code', FormatCodeTool())
        
        # Testing
        self.register('run_tests', RunTestsTool())
        self.register('coverage', CoverageTool())
        
        # Git operations
        self.register('git_status', GitStatusTool())
        self.register('git_diff', GitDiffTool())
        self.register('git_commit', GitCommitTool())
        
        # Package management
        self.register('npm_install', NpmInstallTool())
        self.register('pip_install', PipInstallTool())
    
    def get_tools_for_task(self, task_type: str) -> list:
        """Get tools appropriate for a task type"""
        
        task_tool_map = {
            'implementation': ['read_file', 'write_file', 'search_files', 'format_code'],
            'testing': ['read_file', 'write_file', 'run_tests', 'coverage'],
            'debugging': ['read_file', 'parse_ast', 'run_tests', 'git_diff'],
            'refactoring': ['read_file', 'write_file', 'parse_ast', 'refactor', 'run_tests']
        }
        
        tool_names = task_tool_map.get(task_type, list(self._tools.keys()))
        return [self._tools[name] for name in tool_names if name in self._tools]
```

## Leading Coding Agent Platforms

### GitHub Copilot and Coding Agent

GitHub Copilot has evolved from an IDE autocomplete tool to a full coding agent. **Copilot Chat** provides natural language interaction about code, allowing developers to ask questions and request explanations. **Copilot Coding Agent** handles autonomous task completion and PR creation, working independently on assigned tasks. **Copilot Workspace** offers a full development environment with agent integration, bringing together editing, testing, and deployment.

Copilot coding agent is not invoked via a custom `uses:` action. Instead, you assign work through GitHub Issues, Pull Requests, the agents panel, or by mentioning `@copilot`, and you customise its environment with a dedicated workflow file. See the official docs at <https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent> and the environment setup guide at <https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/customize-the-agent-environment>.

Example 7-1. `.github/workflows/copilot-setup-steps.yml`

```yaml
name: Copilot setup steps

on:
  push:
    paths:
      - .github/workflows/copilot-setup-steps.yml

jobs:
  # The job MUST be named copilot-setup-steps to be picked up by Copilot.
  copilot-setup-steps:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - name: Install dependencies
        run: |
          npm ci
```

### Claude Code

Claude Code (<https://code.claude.com/docs>) provides multi-agent orchestration for complex development tasks. As of February 2026, Claude is available as a GitHub engine in public preview alongside Copilot and Codex. Its **subagent architecture** allows you to spawn specialised agents for different concerns, each focused on a particular aspect of the problem. **Swarms mode** enables parallel execution of independent tasks, reducing total time to completion. **Extended context** handles large codebases through intelligent context management, summarising and prioritising information to fit within token limits. Claude Code can be used from the browser at `claude.ai/code` or from the terminal as a CLI tool.

### Cursor AI

Cursor (<https://www.cursor.com/>) is an AI-first code editor designed around agent workflows. It provides **project-wide understanding** by indexing the entire codebase for context, ensuring suggestions fit the project's patterns. **Multi-file generation** creates and modifies multiple files in one operation, handling cross-cutting changes that span components. **Framework integration** gives the editor deep understanding of popular frameworks, improving suggestion quality for framework-specific code.

### OpenAI Codex CLI

OpenAI Codex (<https://developers.openai.com/codex>) has evolved from an API-only model into a full coding agent platform available as a CLI, IDE extension, web interface, and macOS app. The latest model, GPT-5.3-Codex (released February 2026), is described as the most capable agentic coding model to date. Codex supports skills packaged with `SKILL.md` for progressive disclosure, and its CLI enables agentic workflows directly from the terminal. The macOS app serves as a command centre for managing multiple coding agents in parallel.

### Aider

Aider (<https://aider.chat/>) is an open-source, Git-first CLI coding agent for AI pair programming in the terminal. It works best with Claude 3.7 Sonnet, DeepSeek R1, and GPT-4o, but can connect to almost any LLM including local models. Aider makes coordinated changes across multiple files with automatic Git commits, builds a map of entire repositories for effective refactoring, and integrates automatic linting and testing. It represents the shift from suggestion-based assistance to truly agentic terminal workflows.

### Devin

Devin (<https://devin.ai/>) by Cognition is an autonomous coding agent designed to handle tasks equivalent to four to eight hours of junior engineer work. Cognition's valuation reached $10.2 billion following a $400M Series C in late 2025. In July 2025, Cognition acquired Windsurf, merging IDE and agent approaches. Devin excels at tasks with clear requirements and verifiable outcomes: migrations, vulnerability fixes, unit test generation, and small tickets. It is infinitely parallelisable and works asynchronously.

### Windsurf

Windsurf (<https://windsurf.com/>), formerly Codeium, is an AI-native IDE now owned by Cognition (acquired July 2025). It is a feature-rich fork of VS Code with seamless import of existing settings and extensions. Its **Cascade** feature is an agentic assistant that plans multi-step edits, calls tools, and uses deep repository context. Windsurf offers a permanently free individual plan with unlimited autocomplete and chat, making it accessible for individual developers.

### CodeGPT and Agent Marketplaces

CodeGPT (<https://codegpt.co/>) and marketplace-based approaches offer specialised agents. **Specialised agents** provide over 200 pre-built agents for specific tasks, from code review to documentation generation. **Custom agent creation** lets you build and share domain-specific agents tailored to your organisation's needs. **Multi-model support** combines different LLMs for different tasks, using each model's strengths where they apply best.

## Best Practices

### Clear Task Boundaries

Define clear boundaries for what agents can and cannot do:

```python
class TaskBoundary:
    """Define boundaries for agent tasks"""
    
    def __init__(self):
        self.max_files = 20
        self.max_lines_per_file = 500
        self.timeout_seconds = 600
        self.protected_patterns = [
            r'\.env.*',
            r'secrets/.*',
            r'\.github/workflows/.*'
        ]
    
    def validate_task(self, task: dict) -> bool:
        """Validate that a task is within boundaries"""
        if len(task.get('files', [])) > self.max_files:
            return False
        
        for file_path in task.get('files', []):
            if any(re.match(p, file_path) for p in self.protected_patterns):
                return False
        
        return True
```

### Incremental Changes

Prefer small, focused changes over large rewrites:

```python
class IncrementalChangeStrategy:
    """Strategy for making incremental changes"""
    
    def execute(self, large_change: Change) -> list:
        """Break large change into incremental steps"""
        
        # 1. Analyze the change
        components = self.decompose(large_change)
        
        # 2. Order by dependency
        ordered = self.topological_sort(components)
        
        # 3. Execute incrementally with validation
        results = []
        for component in ordered:
            result = self.apply_change(component)
            
            # Validate after each step
            if not self.validate(result):
                self.rollback(results)
                raise ChangeValidationError(result)
            
            results.append(result)
        
        return results
```

### Test-Driven Development

Integrate testing into agent workflows:

```python
class TDDAgent:
    """Agent that follows test-driven development"""
    
    async def implement_feature(self, specification: str):
        """Implement feature using TDD approach"""
        
        # 1. Write tests first
        tests = await self.generate_tests(specification)
        await self.write_tests(tests)
        
        # 2. Verify tests fail
        initial_results = await self.run_tests()
        assert not initial_results.all_passed
        
        # 3. Implement to pass tests
        implementation = await self.implement(specification, tests)
        
        # 4. Verify tests pass
        final_results = await self.run_tests()
        
        # 5. Refactor if needed
        if final_results.all_passed:
            await self.refactor_for_quality()
        
        return implementation
```

### Human Review Integration

Always include human checkpoints for significant changes:

Example 7-4. Human review workflow (pseudocode)

```yaml
# Workflow with human review
name: Agent Implementation with Review
on:
  issues:
    types: [labeled]

jobs:
  implement:
    if: contains(github.event.issue.labels.*.name, 'agent-task')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6 # pin to a full SHA in production
      
      - name: Agent Implementation
        id: implement
        uses: ./actions/coding-agent
        
      - name: Create PR for Review
        uses: peter-evans/create-pull-request@v8 # pin to a full SHA in production
        with:
          title: "Agent: ${{ github.event.issue.title }}"
          body: |
            ## Agent Implementation
            
            This PR was created by an AI agent based on issue #${{ github.event.issue.number }}.
            
            **Please review carefully before merging.**
          labels: needs-human-review
          draft: true
```

> **Note:** The `./actions/coding-agent` step is a placeholder for your organization’s internal agent runner. Replace it with your approved agent execution mechanism.

## Common Challenges

### Context Window Limitations

Large codebases exceed agent context windows:

**Solution**: Implement intelligent context retrieval and summarization.

```python
class ContextCompressor:
    """Compress context to fit within token limits"""
    
    def compress(self, files: list, max_tokens: int) -> str:
        """Compress file contents to fit token limit"""
        
        # Prioritize by relevance
        ranked = self.rank_by_relevance(files)
        
        # Include summaries for less relevant files
        context = []
        tokens_used = 0
        
        for file in ranked:
            if tokens_used + file.tokens <= max_tokens:
                context.append(file.content)
                tokens_used += file.tokens
            else:
                # Include summary instead
                summary = self.summarize(file)
                context.append(summary)
                tokens_used += len(summary.split())
        
        return '\n'.join(context)
```

### Hallucination and Accuracy

Agents may generate plausible but incorrect code:

**Solution**: Implement validation and testing at every step.

### Security Concerns

Agents with code access pose security risks:

**Solution**: Use sandboxing, permission scoping, and audit logging.

```python
class SecureCodingEnvironment:
    """Secure environment for coding agent execution"""
    
    def __init__(self):
        self.sandbox = DockerSandbox()
        self.audit_log = AuditLog()
    
    async def execute(self, agent, task):
        """Execute agent in secure sandbox"""
        
        # Log the task
        self.audit_log.log_task_start(agent.id, task)
        
        try:
            # Run in sandbox
            result = await self.sandbox.run(agent, task)
            
            # Validate output
            self.validate_output(result)
            
            # Log completion
            self.audit_log.log_task_complete(agent.id, result)
            
            return result
            
        except Exception as e:
            self.audit_log.log_task_error(agent.id, e)
            raise
```

## Key Takeaways

**Coding agents** have evolved from autocomplete to autonomous development assistants, progressing through phases of increasing capability and independence. The landscape now includes IDE-integrated assistants (Copilot, Cursor, Windsurf), CLI-based agents (Claude Code, Codex CLI, Aider), and fully autonomous agents (Devin).

**Multi-agent architectures** mirror development teams, with specialised agents for architecture, implementation, testing, and review, each contributing expertise to the overall workflow.

**AGENTS.md** is the emerging standard for providing agents with project-specific instructions, serving as a "README for agents" that helps them understand how to work within a codebase.

**Scaffolding** for coding agents includes context management to handle large codebases, tool registries to organise capabilities, and security boundaries to limit what agents can access.

**Human review** remains essential—agents create PRs for review, not direct commits. This ensures humans maintain oversight over changes that affect production systems.

**Incremental changes** with continuous validation are safer than large rewrites. Small, focused modifications are easier to review and less likely to introduce subtle bugs.

**Security** must be designed in from the start: sandboxing isolates agent execution, permissions scope what agents can access, and audit logging tracks what they do.

---

<!-- Edit notes:
Sections expanded: Chapter Preview, From Autocomplete to Autonomy (timeline), Current Capabilities, GitHub Copilot and Coding Agent, Claude Code, Cursor AI, CodeGPT and Agent Marketplaces, Key Takeaways
Lists preserved: Code blocks (must remain as-is), architecture tables (must remain tabular for comparison)
Ambiguous phrases left ambiguous: None identified
-->
