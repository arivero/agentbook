#!/bin/bash
# Demonstration: Using bash tool (MCP) to compile GH-AW workflows
# This script shows how AI agents can use the bash tool to run gh aw compile

set -e

echo "=========================================="
echo "GH-AW Compilation via MCP Server Demo"
echo "=========================================="
echo ""

# Step 1: Check environment
echo "Step 1: Checking environment..."
echo "  - Repository: $(pwd)"
echo "  - GitHub CLI: $(which gh)"
echo "  - gh version: $(gh --version | head -1)"
echo ""

# Step 2: Check if gh-aw is installed
echo "Step 2: Checking gh-aw extension..."
if gh extension list 2>&1 | grep -q "gh-aw"; then
    echo "  ✓ gh-aw extension is installed"
else
    echo "  ✗ gh-aw extension is NOT installed"
    echo "  → To install: GH_TOKEN=<token> gh extension install github/gh-aw"
fi
echo ""

# Step 3: List workflow source files
echo "Step 3: Listing workflow source files (.md)..."
ls -1 .github/workflows/*.md 2>/dev/null | while read -r file; do
    echo "  - $file"
done
echo ""

# Step 4: List compiled lock files
echo "Step 4: Listing compiled lock files (.lock.yml)..."
ls -1 .github/workflows/*.lock.yml 2>/dev/null | while read -r file; do
    echo "  - $file"
done
echo ""

# Step 5: Check if lock files are up to date
echo "Step 5: Checking if lock files are up to date..."
if git diff --quiet -- .github/workflows/*.lock.yml 2>/dev/null; then
    echo "  ✓ All lock files are up to date"
else
    echo "  ⚠ Lock files have uncommitted changes:"
    git diff --stat -- .github/workflows/*.lock.yml
fi
echo ""

# Step 6: Show how to compile (without actually compiling unless gh-aw is installed)
echo "Step 6: How to compile workflows..."
if gh extension list 2>&1 | grep -q "gh-aw"; then
    echo "  To compile all workflows:"
    echo "    gh aw compile"
    echo ""
    echo "  To compile a specific workflow:"
    echo "    gh aw compile .github/workflows/issue-intake-triage.md"
    echo ""
    echo "  Would you like to run compilation now? (Comment out the exit to run)"
    # Uncomment the next line to actually run compilation:
    # gh aw compile
else
    echo "  ⚠ Cannot compile - gh-aw extension not installed"
    echo ""
    echo "  To install and compile:"
    echo "    export GH_TOKEN=<your-github-token>"
    echo "    gh extension install github/gh-aw"
    echo "    gh aw compile"
fi
echo ""

echo "=========================================="
echo "Demo complete!"
echo "=========================================="
echo ""
echo "Key takeaways:"
echo "  1. The bash tool (via MCP) provides full command-line access"
echo "  2. AI agents can run 'gh aw compile' through the bash tool"
echo "  3. This enables automated workflow compilation"
echo "  4. Both installation and compilation can be done via MCP"
echo ""
echo "For more details, see COMPILING_WORKFLOWS.md"
