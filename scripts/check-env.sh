#!/usr/bin/env bash
# Environment Check Script for GitHub CLI and Tokens
# This script verifies the presence of GitHub tokens and gh CLI installation

set -e

echo "============================================"
echo "GitHub Environment Check"
echo "============================================"
echo ""

# Check for GH_TOKEN
echo "1. Checking for GH_TOKEN environment variable..."
if [ -n "$GH_TOKEN" ]; then
    echo "   ✓ GH_TOKEN is set (length: ${#GH_TOKEN} characters)"
else
    echo "   ✗ GH_TOKEN is NOT set"
fi
echo ""

# Check for GITHUB_TOKEN
echo "2. Checking for GITHUB_TOKEN environment variable..."
if [ -n "$GITHUB_TOKEN" ]; then
    echo "   ✓ GITHUB_TOKEN is set (length: ${#GITHUB_TOKEN} characters)"
else
    echo "   ✗ GITHUB_TOKEN is NOT set"
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

# Check gh authentication status
echo "4. Checking gh authentication status..."
if gh auth status &> /dev/null; then
    echo "   ✓ gh is authenticated"
    gh auth status 2>&1 | head -n 3
else
    echo "   ✗ gh is NOT authenticated"
    echo "   To authenticate, run: gh auth login"
    echo "   Or set GH_TOKEN or GITHUB_TOKEN environment variable"
fi
echo ""

# Summary
echo "============================================"
echo "Summary"
echo "============================================"

TOKEN_SET=false
if [ -n "$GH_TOKEN" ] || [ -n "$GITHUB_TOKEN" ]; then
    TOKEN_SET=true
fi

GH_INSTALLED=false
if command -v gh &> /dev/null; then
    GH_INSTALLED=true
fi

if [ "$TOKEN_SET" = true ] && [ "$GH_INSTALLED" = true ]; then
    echo "Status: ✓ Environment is properly configured"
    echo ""
    echo "GitHub token is available and gh CLI is installed."
    exit 0
elif [ "$GH_INSTALLED" = true ]; then
    echo "Status: ⚠ Partially configured"
    echo ""
    echo "gh CLI is installed but no GitHub token is set."
    echo "You may need to authenticate with: gh auth login"
    echo "Or set GH_TOKEN or GITHUB_TOKEN environment variable."
    exit 0
else
    echo "Status: ✗ Missing requirements"
    echo ""
    echo "Please install gh CLI from: https://cli.github.com/"
    exit 1
fi
