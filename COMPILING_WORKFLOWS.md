# Compiling GitHub Agentic Workflows

This document explains how to compile GitHub Agentic Workflow (GH-AW) markdown source files into executable lock files.

## Overview

GitHub Agentic Workflows use a **source-to-lock** compilation model:
- **Source files**: `.github/workflows/*.md` - Human-editable workflow definitions
- **Lock files**: `.github/workflows/*.lock.yml` - Generated executable workflows

The lock files are generated using the `gh aw compile` command from the [gh-aw extension](https://github.com/github/gh-aw).

## Running `gh aw compile` via MCP Server

**YES**, the `gh aw compile` command **CAN** be executed via the MCP server using the **bash tool**. The bash tool provides direct command-line access, which is exactly what's needed to run `gh` extension commands.

### Prerequisites

1. **GitHub CLI (`gh`)** must be installed (already available in GitHub Codespaces and GitHub Actions)
2. **gh-aw extension** must be installed
3. **GitHub token** with appropriate permissions must be available

### Installation

Install the gh-aw extension using the bash tool:

```bash
# Set GitHub token (required for extension installation)
export GH_TOKEN=<your-github-token>

# Install the gh-aw extension
gh extension install github/gh-aw
```

### Compilation Commands

Once the extension is installed, you can use the bash tool to run compilation commands:

#### Compile all workflows
```bash
cd /path/to/repository
gh aw compile
```

#### Compile a specific workflow
```bash
cd /path/to/repository
gh aw compile .github/workflows/issue-intake-triage.md
```

#### Verify compilation
```bash
# Check that lock files are up to date
git diff --quiet -- .github/workflows/*.lock.yml
if [ $? -ne 0 ]; then
  echo "Lock files are out of date"
  git diff -- .github/workflows/*.lock.yml
fi
```

## Example: Using bash tool via MCP

Here's how an AI agent with MCP access can compile workflows:

```python
# Example: Agent using bash tool via MCP to compile workflows

# 1. Install gh-aw extension (one-time setup)
bash_tool.execute({
    "command": "GH_TOKEN=${GITHUB_TOKEN} gh extension install github/gh-aw",
    "description": "Install gh-aw extension"
})

# 2. Compile workflows
bash_tool.execute({
    "command": "cd /home/runner/work/agentbook/agentbook && gh aw compile",
    "description": "Compile all GH-AW workflows"
})

# 3. Verify results
bash_tool.execute({
    "command": "cd /home/runner/work/agentbook/agentbook && git status",
    "description": "Check which lock files were updated"
})
```

For a complete step-by-step example with error handling, see [scripts/MCP_COMPILE_EXAMPLE.md](scripts/MCP_COMPILE_EXAMPLE.md).

## Workflow Editing Best Practices

### DO:
- ✅ Edit `.md` source files for workflow changes
- ✅ Run `gh aw compile` after editing source files
- ✅ Commit both `.md` and `.lock.yml` files together
- ✅ Verify lock files are up to date before merging

### DON'T:
- ❌ **NEVER** edit `.lock.yml` files directly by hand
- ❌ Don't commit source changes without recompiling
- ❌ Don't commit lock files that don't match their sources

## Automated Compilation

The repository includes a GitHub Actions workflow that automatically verifies lock files are up to date:

**`.github/workflows/compile-workflows.yml`**:
```yaml
- name: Install gh-aw extension
  run: gh extension install github/gh-aw
  env:
    GH_TOKEN: ${{ github.token }}

- name: Compile agentic workflows
  run: gh aw compile
  env:
    GH_TOKEN: ${{ github.token }}

- name: Verify lock files are up to date
  run: |
    if ! git diff --quiet -- .github/workflows/*.lock.yml; then
      echo "::error::Lock files are out of date. Run 'gh aw compile' locally and commit the results."
      git diff -- .github/workflows/*.lock.yml
      exit 1
    fi
```

## Troubleshooting

### Error: "unknown command 'aw' for 'gh'"
**Solution**: Install the gh-aw extension:
```bash
gh extension install github/gh-aw
```

### Error: "HTTP 403: 403 Forbidden"
**Solution**: Ensure your GitHub token is set:
```bash
export GH_TOKEN=your_github_token_here
gh extension install github/gh-aw
```

### Error: "Lock files are out of date"
**Solution**: Run `gh aw compile` and commit the updated lock files:
```bash
gh aw compile
git add .github/workflows/*.lock.yml
git commit -m "Update workflow lock files"
```

## Integration with Development Workflow

### Local Development
```bash
# 1. Make changes to workflow source
vim .github/workflows/issue-intake-triage.md

# 2. Compile to generate lock file
gh aw compile

# 3. Review changes
git diff .github/workflows/issue-intake-triage.lock.yml

# 4. Commit both files
git add .github/workflows/issue-intake-triage.md
git add .github/workflows/issue-intake-triage.lock.yml
git commit -m "Update issue intake triage workflow"

# 5. Push
git push
```

### Using AI Agents via MCP
AI agents with bash tool access can perform all these operations:
1. Read workflow source files
2. Make edits to workflow markdown
3. Run `gh aw compile` to generate lock files
4. Verify compilation results
5. Commit changes (via appropriate tools)

## Key Behaviors

Understanding these behaviors is essential when working with GH-AW:

1. **Frontmatter edits require recompile**
   - Changes to `on:`, `permissions:`, `tools:`, or `engine:` require running `gh aw compile`
   
2. **Markdown instruction updates**
   - The markdown body (instructions) can sometimes be edited directly
   - The runtime loads markdown at execution time
   - Structural changes still require recompilation

3. **Shared components**
   - Markdown files without `on:` trigger are imported, not compiled
   - Allows reuse without duplication

## References

- **gh-aw CLI**: https://github.com/github/gh-aw
- **Workflow Playbook**: [WORKFLOW_PLAYBOOK.md](WORKFLOW_PLAYBOOK.md)
- **Setup Guide**: [SETUP.md](SETUP.md)
- **Book Chapter**: [060-gh-agentic-workflows.md](book/chapters/060-gh-agentic-workflows.md)

## Summary

**The `gh aw compile` command CAN be executed via the MCP server** using the bash tool. This enables AI agents to:
- Install the gh-aw extension
- Compile workflow source files
- Verify compilation results
- Integrate workflow maintenance into automated processes

The bash tool provides full command-line access, making all `gh` CLI operations available to AI agents through the MCP protocol.
