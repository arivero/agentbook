# Scripts Directory

This directory contains utility scripts for the Agentbook project.

## Available Scripts

### check-env.sh

**Purpose**: Verify GitHub environment setup

**Usage**:
```bash
bash scripts/check-env.sh
```

**What it checks**:
- Presence of `GH_TOKEN` environment variable
- Presence of `GITHUB_TOKEN` environment variable
- GitHub CLI (gh) installation and version
- GitHub CLI authentication status

**When to use**:
- Before starting local development
- When troubleshooting GitHub API or CLI issues
- To verify CI/CD environment setup

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
