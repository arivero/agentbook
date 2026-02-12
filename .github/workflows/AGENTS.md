# Workflow authoring notes

- Every agentic workflow source file (`*.md`) in this directory must be compiled into its executable lock workflow (`*.lock.yml`) using `gh aw` commands before merging.
- **DO NOT** edit `*.lock.yml` files by hand. They are generated artifacts produced by `gh aw` from the corresponding `*.md` source. Always edit the `.md` source and recompile.
- Keep source and compiled files in sync in the same PR.
- **Preferred installation** (does not require `GH_TOKEN` beyond repo scope):
  1. Install `gh` CLI if not present:
     ```bash
     curl -sL https://github.com/cli/cli/releases/download/v2.67.0/gh_2.67.0_linux_amd64.tar.gz -o /tmp/gh.tar.gz
     tar -xzf /tmp/gh.tar.gz -C /tmp
     cp /tmp/gh_*/bin/gh /usr/local/bin/gh
     ```
  2. Install `gh-aw` via the install script (no token needed):
     ```bash
     curl -sLO https://raw.githubusercontent.com/github/gh-aw/main/install-gh-aw.sh
     bash install-gh-aw.sh
     gh aw version
     ```
  3. Clean up the install script after use: `rm install-gh-aw.sh`
- If `gh extension install github/gh-aw` works in your environment, that is also fine, but it requires a valid `GH_TOKEN`.
- Debug compilation errors with focused commands:
  - `gh aw compile <workflow-id> --json` for specific error messages
  - `gh aw compile --verbose` to see which files are being compiled
  - `gh aw compile <workflow-id>` for one workflow at a time (avoid compiling `AGENTS.md`, which has no frontmatter)
  - If you see errors about write permissions, switch permissions to read-only and configure `safe-outputs` for labels/comments/PRs.
    - Reference: https://github.com/github/gh-aw/blob/main/.github/aw/github-agentic-workflows.md#safe-outputs
- Issue status labels must follow this lifecycle unless explicitly rejected/closed early:
  - `acknowledged`
  - `blog-track` (optional marker for notable non-core daily updates; routing auto-sends these to fast-track)
  - `triaged-fast-track` **or** `triaged-for-research`
  - `assigned`
- Any agent may reject at any stage by posting rationale, adding `rejected`, and closing the issue.
