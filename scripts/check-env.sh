#!/usr/bin/env bash
# Environment Check Script for GitHub CLI
# This script verifies gh CLI installation (tokens are optional)
#
# Note: This project uses github-mcp-server for GitHub API access in automated
# workflows, which handles authentication internally. GH_TOKEN/GITHUB_TOKEN are
# only needed if you want to use the gh CLI directly for manual operations.

set -e

echo "============================================"
echo "GitHub Environment Check"
echo "============================================"
echo ""

# Check for GH_TOKEN (optional)
echo "1. Checking for GH_TOKEN environment variable (optional)..."
if [ -n "$GH_TOKEN" ]; then
    echo "   ✓ GH_TOKEN is set (length: ${#GH_TOKEN} characters)"
else
    echo "   ℹ GH_TOKEN is not set (optional - only needed for direct gh CLI usage)"
fi
echo ""

# Check for GITHUB_TOKEN (optional)
echo "2. Checking for GITHUB_TOKEN environment variable (optional)..."
if [ -n "$GITHUB_TOKEN" ]; then
    echo "   ✓ GITHUB_TOKEN is set (length: ${#GITHUB_TOKEN} characters)"
else
    echo "   ℹ GITHUB_TOKEN is not set (optional - only needed for direct gh CLI usage)"
fi
echo ""

# Check if gh is installed
echo "3. Checking for GitHub CLI (gh)..."
if command -v gh &> /dev/null; then
    echo "   ✓ gh is installed at: $(which gh)"
    echo "   Version: $(gh --version | head -n 1)"
else
    echo "   ✗ gh is NOT installed"
    echo "   To install gh, visit: https://cli.github.com/"
    exit 1
fi
echo ""

# Check gh authentication status (optional)
echo "4. Checking gh authentication status (optional for direct CLI usage)..."
if gh auth status &> /dev/null; then
    echo "   ✓ gh is authenticated"
    gh auth status 2>&1 | head -n 3
else
    echo "   ℹ gh is not authenticated"
    echo "   Note: Authentication only needed if using gh CLI directly"
    echo "   To authenticate, run: gh auth login"
fi
echo ""

# Summary
echo "============================================"
echo "Summary"
echo "============================================"
echo ""
echo "ℹ️  Important Note:"
echo "This project uses github-mcp-server for GitHub API access, which"
echo "handles authentication internally. GH_TOKEN/GITHUB_TOKEN and gh CLI"
echo "authentication are only needed for direct manual gh CLI operations."
echo ""

GH_INSTALLED=false
if command -v gh &> /dev/null; then
    GH_INSTALLED=true
fi

if [ "$GH_INSTALLED" = true ]; then
    echo "Status: ✓ Environment is ready"
    echo ""
    echo "gh CLI is installed and available for manual operations if needed."
    exit 0
else
    echo "Status: ⚠ gh CLI not found"
    echo ""
    echo "gh CLI is optional but recommended for manual GitHub operations."
    echo "To install, visit: https://cli.github.com/"
    exit 0
fi
