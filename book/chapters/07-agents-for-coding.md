---
title: "Chapter 7: Agents for Coding"
order: 7
---

# Chapter 7: Agents for Coding

## Introduction

Coding agents represent the most mature category of AI agents in software development. They have evolved from simple autocomplete tools to autonomous entities capable of planning, writing, testing, debugging, and even scaffolding entire software architectures with minimal human input. This chapter explores the specialized architectures, scaffolding patterns, and best practices for deploying agents in coding workflows.

## The Evolution of Coding Agents

### From Autocomplete to Autonomy

The progression of coding agents follows a clear trajectory:

1. **Code Completion (2020-2022)**: Basic pattern matching and next-token prediction
2. **Context-Aware Assistance (2022-2024)**: Understanding project structure and intent
3. **Task-Oriented Agents (2024-2025)**: Completing multi-step tasks independently
4. **Autonomous Development (2025-2026)**: Full feature implementation, testing, and deployment

### Current Capabilities

Modern coding agents can:

- **Understand Requirements**: Parse natural language specifications and translate them to code
- **Plan Solutions**: Break down complex features into implementable steps
- **Generate Code**: Write production-quality code across multiple files
- **Test and Debug**: Create tests, identify bugs, and fix issues
- **Scaffold Projects**: Initialize projects with appropriate structure and configuration
- **Review and Refactor**: Analyze code quality and suggest improvements

## Specialized Architectures

### Single-Agent Architectures

The simplest architecture involves one agent with access to all necessary tools.

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

The **AGENTS.md** file has emerged as the de facto standard for providing AI coding agents with project-specific instructions. It serves as a "README for agents," offering structured, machine-readable guidance.

#### Purpose and Placement

```
project/
├── AGENTS.md           # Root-level agent instructions
├── src/
│   └── AGENTS.md       # Module-specific instructions
├── tests/
│   └── AGENTS.md       # Testing conventions
└── docs/
    └── AGENTS.md       # Documentation guidelines
```

Agents use the nearest AGENTS.md file, enabling scoped configuration for monorepos or complex projects.

#### Standard Structure

```markdown
# AGENTS.md

## Project Overview
Brief description of the project and its purpose.

## Setup Instructions
How to install dependencies and configure the environment.

## Coding Conventions
- Language: TypeScript 5.x
- Style guide: Airbnb
- Formatting: Prettier with provided config

## Testing Requirements
- Framework: Jest
- Coverage threshold: 80%
- Required test types: unit, integration

## Build and Deploy
- Build command: `npm run build`
- Deploy process: CI/CD via GitHub Actions

## Agent-Specific Notes
- Always run linting before committing
- Never modify files in `vendor/`
- Secrets are in environment variables, never hardcoded
```

#### Benefits

1. **Consistency**: All agents receive the same instructions
2. **Onboarding**: New agents (or new agent sessions) understand the project immediately
3. **Safety**: Clear boundaries prevent accidental damage
4. **Maintainability**: Single source of truth for agent behavior

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

GitHub Copilot has evolved from an IDE autocomplete tool to a full coding agent:

- **Copilot Chat**: Natural language interaction about code
- **Copilot Coding Agent**: Autonomous task completion and PR creation
- **Copilot Workspace**: Full development environment with agent integration

```yaml
# Example: Using Copilot Coding Agent via GitHub Actions
name: Copilot Task
on:
  issues:
    types: [labeled]

jobs:
  copilot-task:
    if: contains(github.event.issue.labels.*.name, 'copilot')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Assign to Copilot
        uses: github/copilot-agent@v1
        with:
          issue: ${{ github.event.issue.number }}
          permissions: read-write
```

### Claude Code

Claude Code provides multi-agent orchestration for complex development tasks:

- **Subagent Architecture**: Spawn specialized agents for different concerns
- **Swarms Mode**: Parallel execution of independent tasks
- **Extended Context**: Handle large codebases through intelligent context management

### Cursor AI

Cursor is an AI-first code editor designed around agent workflows:

- **Project-Wide Understanding**: Indexes entire codebase for context
- **Multi-File Generation**: Creates and modifies multiple files in one operation
- **Framework Integration**: Deep understanding of popular frameworks

### CodeGPT and Agent Marketplaces

Marketplace-based approaches offer specialized agents:

- **Specialized Agents**: Over 200 pre-built agents for specific tasks
- **Custom Agent Creation**: Build and share domain-specific agents
- **Multi-Model Support**: Combine different LLMs for different tasks

## Best Practices

### 1. Clear Task Boundaries

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

### 2. Incremental Changes

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

### 3. Test-Driven Development

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

### 4. Human Review Integration

Always include human checkpoints for significant changes:

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
      - uses: actions/checkout@v4
      
      - name: Agent Implementation
        id: implement
        uses: ./actions/coding-agent
        
      - name: Create PR for Review
        uses: peter-evans/create-pull-request@v5
        with:
          title: "Agent: ${{ github.event.issue.title }}"
          body: |
            ## Agent Implementation
            
            This PR was created by an AI agent based on issue #${{ github.event.issue.number }}.
            
            **Please review carefully before merging.**
          labels: needs-human-review
          draft: true
```

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

1. **Coding agents** have evolved from autocomplete to autonomous development assistants.

2. **Multi-agent architectures** mirror development teams, with specialized agents for architecture, implementation, testing, and review.

3. **AGENTS.md** is the emerging standard for providing agents with project-specific instructions.

4. **Scaffolding** for coding agents includes context management, tool registries, and security boundaries.

5. **Human review** remains essential—agents create PRs for review, not direct commits.

6. **Incremental changes** with continuous validation are safer than large rewrites.

7. **Security** must be designed in from the start: sandboxing, permissions, and audit logging.

---
