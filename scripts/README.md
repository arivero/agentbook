# Scripts Directory

This directory contains utility scripts for the Agentbook project.

## Available Scripts

### check-env.sh

**Purpose**: Verify GitHub CLI installation

**Usage**:
```bash
bash scripts/check-env.sh
```

**What it checks**:
- GitHub CLI (gh) installation and version
- Presence of `GH_TOKEN` or `GITHUB_TOKEN` environment variables (optional)
- GitHub CLI authentication status (optional)

**Important Note**: This project uses `github-mcp-server` for GitHub API access,
which handles authentication internally. Tokens and gh authentication are only
needed if you want to use the gh CLI directly for manual operations.

**When to use**:
- Before starting local development
- To verify gh CLI is available for manual operations
- When troubleshooting gh CLI issues

### check-links.py

**Purpose**: Validate internal and external links in markdown files

**Usage**:
```bash
# Check internal links only (offline-safe)
python3 scripts/check-links.py --root book --mode internal

# Check external links (requires internet)
python3 scripts/check-links.py --root book --mode external
```

**When to use**:
- After making changes to book content
- Before committing changes to ensure link integrity
- In CI/CD to catch broken links

### build-combined-md.sh

**Purpose**: Combine all book chapters into a single markdown file

**Usage**:
```bash
bash scripts/build-combined-md.sh
```

**When to use**:
- When preparing content for PDF generation
- To create a single-file version of the book
- For external publishing or archival

## Contributing

When adding new scripts:
1. Use clear, descriptive names
2. Add appropriate shebang (`#!/usr/bin/env bash` or `#!/usr/bin/env python3`)
3. Make scripts executable: `chmod +x script-name.sh`
4. Update this README with usage instructions
5. Add inline documentation and comments
