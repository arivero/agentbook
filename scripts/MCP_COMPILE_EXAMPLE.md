# Example: Using MCP Server to Compile GH-AW Workflows

This document provides a concrete example of how to use the MCP server's bash tool to compile GitHub Agentic Workflows.

## Scenario

An AI agent needs to:
1. Check if workflows need compilation
2. Install the gh-aw extension if needed
3. Compile workflow markdown files to lock files
4. Verify the compilation was successful

## Step-by-Step MCP Interaction

### Step 1: Check Current Status

**Tool**: bash  
**Command**: 
```bash
cd /home/runner/work/agentbook/agentbook && \
ls -1 .github/workflows/*.md && \
echo "---" && \
ls -1 .github/workflows/*.lock.yml
```

**Purpose**: List all source (.md) and compiled (.lock.yml) workflow files

### Step 2: Check for Uncommitted Changes

**Tool**: bash  
**Command**: 
```bash
cd /home/runner/work/agentbook/agentbook && \
git diff --quiet -- .github/workflows/*.lock.yml && \
echo "✓ Lock files are up to date" || \
echo "⚠ Lock files need recompilation"
```

**Purpose**: Determine if lock files are out of sync with sources

### Step 3: Install gh-aw Extension

**Tool**: bash  
**Command**: 
```bash
export GH_TOKEN=${GITHUB_TOKEN} && \
gh extension install github/gh-aw
```

**Purpose**: Install the gh-aw extension (one-time setup)  
**Note**: Requires valid GitHub token with appropriate permissions

### Step 4: Compile All Workflows

**Tool**: bash  
**Command**: 
```bash
cd /home/runner/work/agentbook/agentbook && \
gh aw compile
```

**Purpose**: Compile all .md workflow files to .lock.yml files

**Expected Output**:
```
Compiling .github/workflows/issue-intake-triage.md...
Compiling .github/workflows/issue-fast-track-close.md...
Compiling .github/workflows/issue-research-pass.md...
...
Done! Compiled 6 workflows.
```

### Step 5: Verify Compilation Results

**Tool**: bash  
**Command**: 
```bash
cd /home/runner/work/agentbook/agentbook && \
git status --short -- .github/workflows/*.lock.yml
```

**Purpose**: Check which lock files were modified by compilation

**Expected Output**:
```
M .github/workflows/issue-intake-triage.lock.yml
M .github/workflows/issue-fast-track-close.lock.yml
```

### Step 6: Review Changes (Optional)

**Tool**: bash  
**Command**: 
```bash
cd /home/runner/work/agentbook/agentbook && \
git diff .github/workflows/issue-intake-triage.lock.yml | head -50
```

**Purpose**: Review what changed in a specific lock file

## Complete Workflow Example

Here's a complete Python-style example showing how an AI agent would use the MCP bash tool:

```python
# Pseudo-code for AI agent using MCP bash tool

# 1. Check if gh-aw is installed
result = bash_tool.execute({
    "command": "gh extension list | grep gh-aw || echo 'NOT_INSTALLED'",
    "description": "Check if gh-aw extension is installed"
})

# 2. Install if needed
if "NOT_INSTALLED" in result.output:
    bash_tool.execute({
        "command": "GH_TOKEN=${GITHUB_TOKEN} gh extension install github/gh-aw",
        "description": "Install gh-aw extension"
    })

# 3. Compile workflows
result = bash_tool.execute({
    "command": "cd /home/runner/work/agentbook/agentbook && gh aw compile",
    "description": "Compile all GH-AW workflow sources"
})

# 4. Check for changes
result = bash_tool.execute({
    "command": "cd /home/runner/work/agentbook/agentbook && git status --short -- .github/workflows/*.lock.yml",
    "description": "Check which lock files changed"
})

# 5. Commit if changes exist
if result.output.strip():
    bash_tool.execute({
        "command": """cd /home/runner/work/agentbook/agentbook && \
            git add .github/workflows/*.lock.yml && \
            git commit -m 'Update workflow lock files'""",
        "description": "Commit updated lock files"
    })
```

## Error Handling

### Error: "unknown command 'aw' for 'gh'"

**Cause**: gh-aw extension not installed  
**Solution**: Run installation command (Step 3)

### Error: "HTTP 403: 403 Forbidden"

**Cause**: Missing or invalid GitHub token  
**Solution**: 
```bash
export GH_TOKEN=<valid-token>
gh extension install github/gh-aw
```

### Error: "Lock files are out of date"

**Cause**: Source files changed but compilation wasn't run  
**Solution**: Run `gh aw compile` and commit the updated lock files

## Key Takeaways

1. **MCP bash tool has full command-line access** - It can run any command, including `gh aw compile`

2. **No special MCP server configuration needed** - The bash tool is a standard MCP tool that works with all commands

3. **AI agents can automate the entire workflow** - From checking status to compiling to committing changes

4. **Same commands work everywhere** - Local development, CI/CD, GitHub Codespaces, or via MCP

## See Also

- [COMPILING_WORKFLOWS.md](../COMPILING_WORKFLOWS.md) - Comprehensive guide
- [WORKFLOW_PLAYBOOK.md](../WORKFLOW_PLAYBOOK.md) - Workflow lifecycle
- [SETUP.md](../SETUP.md) - Setup instructions
