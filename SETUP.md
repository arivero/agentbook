# Setup Instructions

This document explains how to enable the self-maintaining features of this book.

If you need the operator runbook pointer, start with `content.md`.

## GitHub Pages Setup

1. Go to your repository Settings
2. Navigate to "Pages" section
3. Under "Source", select:
   - Source: GitHub Actions
4. The site will be available at: `https://<username>.github.io/<repository>`

## Required Secrets and Permissions

### Repository Permissions

Ensure the following permissions are enabled in Settings → Actions → General:

- **Workflow permissions**: 
  - ✅ Read and write permissions
  - ✅ Allow GitHub Actions to create and approve pull requests

### Coding-Agent Availability (Required for Phase-3 Handoff)

In addition to tokens and workflow permissions, coding agents must be available to this repository as assignable actors.

Minimum requirement:
- `copilot-swe-agent` is available (required for assignment-based PR handoff).

Optional additional agents:
- `openai-code-agent`
- `anthropic-code-agent`

Verify from the repository root with GitHub CLI:

```bash
gh api graphql \
  -F owner='<owner>' \
  -F repo='<repo>' \
  -f query='query($owner:String!, $repo:String!) { repository(owner:$owner, name:$repo) { suggestedActors(capabilities: [CAN_BE_ASSIGNED], first: 100) { nodes { __typename ... on Bot { login } } } } }' \
  --jq '.data.repository.suggestedActors.nodes[] | select(.__typename == "Bot") | .login'
```

If the expected bots are missing, complete the GitHub coding-agent integration setup and repository access grants before testing phase dispatch handoffs.

### Branch Protection (Optional but Recommended)

For the `main` branch:
- Require pull request reviews before merging
- Require status checks to pass before merging

## Workflows Overview

### 1. Deploy to GitHub Pages (`pages.yml`)
- **Trigger**: Push to `main` branch, manual dispatch
- **Purpose**: Builds and deploys the book to GitHub Pages
- **Requires**: Pages enabled in repository settings

### 2. Build PDF (`build-pdf.yml`)
- **Trigger**: Changes to `book/**/*.md`, manual dispatch
- **Purpose**: Generates PDF version of the book
- **Output**: Artifact available in Actions tab
- **Note**: On tagged releases, PDF is attached to the release

### 3. Process Issue Suggestions (GH-AW workflows)
- **Trigger**:
  - `issues.opened` for standard intake ACK
  - `workflow_dispatch` for agentic routing
  - `issues.labeled` for downstream GH-AW stages
- **Purpose**: Agentic issue processing using GH-AW compiled workflows
- **Features**:
  - Standard acknowledgment plus agentic routing
  - Research synthesis and recommendations
  - Fast-track path for small changes
  - Human review checkpoints before merge

### 4. Daily Research Updates (`daily-research-updates.lock.yml`)
- **Trigger**: Daily schedule, manual dispatch
- **Purpose**: Scans seed feeds (Hacker News, Reddit RSS, arXiv RSS) plus broader web/social announcement sources for book-relevant updates
- **Output**: Opens up to 2 high-signal GitHub issues per run when meaningful new items are found, after checking open issues and issues closed in the last 7 days

### Required Secret for Label-Triggered Handoffs

Set `GH_AW_GITHUB_TOKEN` in repository secrets.
This token is used by safe-outputs writes so label-based stage triggers can launch downstream workflows.

Recommended:
- Fine-grained PAT restricted to this repository only
- Repository permissions:
  - `Issues`: `Read and write`
  - `Pull requests`: `Read and write`
  - `Contents`: `Read and write`
  - `Actions`: `Read and write` (only if you use PAT-based workflow dispatch fallback)

Classic PAT fallback:
- `repo` scope (only if fine-grained PAT cannot be used)

### Optional Secret for Web Research

Set `TAVILY_API_KEY` to enable the Tavily MCP server for external web discovery in research workflows.
If this secret is not set, research still runs with GitHub search plus Playwright-based retrieval.

### Optional Secrets for Multi-Engine Slow-Track Phases

Set these if you want phase dispatch workflows to select Codex or Claude before falling back to Copilot:
- `OPENAI_API_KEY` for Codex engine runs
- `ANTHROPIC_API_KEY` for Claude engine runs

If either key is missing or invalid at runtime, dispatch falls through to the next engine in the configured order.
Each phase dispatcher posts a token-health comment on the issue so operators can verify which credentials are still valid.

### Web Research Behavior

The research workflow can use external research tools by default:
- Prefer Playwright MCP for direct retrieval of known URLs to keep API costs low.
- If available in the runtime, `curl` may be used for simple retrieval on allowed domains.
- Use Tavily MCP (when `TAVILY_API_KEY` is configured) for broad web discovery when direct retrieval is not enough.
- Always pair external sources with GitHub-native context when writing recommendations.

### How to Create `GH_AW_GITHUB_TOKEN` (Fine-Grained PAT)

1. In GitHub, open:
   - Profile menu (top-right) -> `Settings`
   - `Developer settings` -> `Personal access tokens` -> `Fine-grained tokens`
   - Click `Generate new token`
2. Configure the token:
   - Resource owner: your user/account
   - Repository access: `Only select repositories` -> select `arivero/agentbook`
   - Repository permissions:
     - `Issues`: `Read and write`
     - `Pull requests`: `Read and write`
     - `Contents`: `Read and write`
3. Generate the token and copy it once.
4. In the repository, open:
   - `Settings` -> `Secrets and variables` -> `Actions` -> `New repository secret`
   - Name: `GH_AW_GITHUB_TOKEN`
   - Value: paste the PAT

### How to Create `OPENAI_API_KEY`

1. Open OpenAI API keys page: <https://platform.openai.com/api-keys>
2. Create a new secret key in your OpenAI account.
3. In the repository, open:
   - `Settings` -> `Secrets and variables` -> `Actions` -> `New repository secret`
   - Name: `OPENAI_API_KEY`
   - Value: paste the key

### How to Create `ANTHROPIC_API_KEY`

1. Open Anthropic Console keys page: <https://console.anthropic.com/settings/keys>
2. Create a new API key in your Anthropic account.
3. In the repository, open:
   - `Settings` -> `Secrets and variables` -> `Actions` -> `New repository secret`
   - Name: `ANTHROPIC_API_KEY`
   - Value: paste the key

## Labels

The following labels are used by the automated workflows:

- `acknowledged`
- `blog-track` (optional: notable non-core items; assessment auto-routes to fast-track)
- `triaged-fast-track`
- `triaged-for-research`
- `researched-waiting-opinions`
- `phase-1-complete`
- `phase-2-complete`
- `assigned`
- `rejected`

## Optional Model Configuration

GH-AW compiled workflows support repository variables for model selection:
- `GH_AW_MODEL_AGENT_COPILOT`: model override for main agent runs
- `GH_AW_MODEL_DETECTION_COPILOT`: model override for threat-detection runs

If these variables are unset, workflows use GH-AW defaults.

## Testing the Setup

### Test GitHub Pages Deployment

1. Make a change to any markdown file
2. Commit and push to `main` branch
3. Check the "Actions" tab for workflow progress
4. Visit your GitHub Pages URL after deployment

### Test PDF Generation

1. Make a change to any file in `book/chapters/`
2. Commit and push to `main` branch
3. Check the "Actions" tab
4. Download the PDF artifact from the workflow run

### Test Issue Processing

1. Create a new issue with content related to agentic workflows
2. Intake should automatically:
   - Post an acknowledgment comment
   - Add `acknowledged`
   - Dispatch the routing workflow
3. Check the issue for automated responses

## Manual Workflow Triggers

All workflows support manual triggering:

1. Go to "Actions" tab
2. Select the workflow
3. Click "Run workflow"
4. Choose the branch (usually `main`)
5. Click "Run workflow" button

## Local Development

### Prerequisites

- Ruby (2.7 or higher)
- Bundler

### Setup

```bash
# Install dependencies
bundle install

# Serve locally
bundle exec jekyll serve

# View at http://localhost:4000
```

### Building PDF Locally

Requires Pandoc and LaTeX:

```bash
# Install dependencies (Ubuntu/Debian)
sudo apt-get install pandoc texlive-latex-base texlive-fonts-recommended texlive-latex-extra

# Generate PDF
cat book/README.md book/chapters/*.md > combined.md
pandoc combined.md -o book.pdf --pdf-engine=xelatex --toc --number-sections
```

## Troubleshooting

### Pages not deploying

- Check workflow runs in Actions tab
- Verify Pages is enabled in Settings
- Ensure workflow has necessary permissions

### PDF generation failing

- Check if Docker image is accessible
- Verify markdown syntax is valid
- Check workflow logs for specific errors

### Issue processing not working

- Verify workflow permissions include `issues: write`
- Check if labels exist in the repository
- Review workflow logs for errors

## Further Customization

### Adding New Sections

1. Create a markdown file in `book/chapters/`
2. Update `book/index.md` table of contents
3. Update the PDF build workflow to include the new section

### Modifying Issue Templates

Edit `.github/ISSUE_TEMPLATE/suggestion.yml` to customize the suggestion form.

### Customizing Jekyll Theme

Modify `_config.yml` and `_layouts/` to change the appearance.

## Support

For issues or questions:
- Open an issue in the repository
- Check the [README contributing section](README.md#contributing)
- Review GitHub Actions documentation
