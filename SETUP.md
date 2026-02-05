# Setup Instructions

This document explains how to enable the self-maintaining features of this book.

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
- **Trigger**: New issues opened or labeled
- **Purpose**: Agentic issue processing using GH-AW compiled workflows
- **Features**:
  - Automated triage and acknowledgment
  - Research synthesis and recommendations
  - Fast-track path for small changes
  - Human review checkpoints before merge

## Labels

The following labels are used by the automated workflows:

- `suggestion`: Applied to all new issues by default
- `needs-review`: Applied to issues awaiting review
- `relevant`: Applied when suggestion matches book topics
- `ready-for-agent`: Marks issues ready for AI processing
- `out-of-scope`: Applied to irrelevant suggestions

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
2. The workflow should automatically:
   - Add labels
   - Post a welcome comment
   - Determine relevance
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
- Check the [CONTRIBUTING.md](CONTRIBUTING.md) guide
- Review GitHub Actions documentation
