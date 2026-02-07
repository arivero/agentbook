# Agentic Workflows Book

A **living, self-maintaining book** about agentic workflows, agent orchestration, and agentic scaffolding.

[![Deploy to GitHub Pages](https://github.com/arivero/agentbook/actions/workflows/pages.yml/badge.svg)](https://github.com/arivero/agentbook/actions/workflows/pages.yml)
[![Build PDF](https://github.com/arivero/agentbook/actions/workflows/build-pdf.yml/badge.svg)](https://github.com/arivero/agentbook/actions/workflows/build-pdf.yml)

## 🤖 What Makes This Book Special?

This book doesn't just teach about agentic workflows—it **uses them**! The book automatically:
- 📝 Processes community suggestions from GitHub issues
- ✍️ Updates content using AI agents
- 📚 Maintains markdown sources and generates a PDF build
- 🌐 Publishes to GitHub Pages
- 📰 Creates blog posts for larger curated updates

## 📖 Read the Book

- **Online**: [https://arivero.github.io/agentbook](https://arivero.github.io/agentbook) (GitHub Pages)
- **PDF**: Download from [GitHub Actions artifacts](https://github.com/arivero/agentbook/actions/workflows/build-pdf.yml) or the [repo PDF](https://github.com/arivero/agentbook/raw/main/book/agentic-workflows-book.pdf)
- **Source**: Browse the [book directory](book)

## 🎯 What You'll Learn

The book covers practical patterns for agentic workflows, safe orchestration, skills and tooling, and real-world automation in GitHub and beyond. Browse the source in the `book/` directory or read it online for the full flow.

## 🚀 How It Works

1. **Community Input**: Open an issue with a suggestion
2. **Automated Intake**: A standard workflow posts an acknowledgment and applies `acknowledged`
3. **Agentic Routing**: A GH-AW routing workflow classifies the suggestion
4. **Agent Processing**:
   - **`triaged-fast-track`** for small low-risk fixes
   - **`triaged-for-research`** then **`researched-waiting-opinions`** for larger/ambiguous updates
5. **Automatic Build**: PDF build and site deployment workflows run
6. **Publishing**: Changes deploy to GitHub Pages

## 🤝 Contributing

We welcome contributions! Here's how:

### Suggest Improvements via Issues

The primary way to contribute is by **opening an issue** with your suggestion:

1. **[Open an issue](https://github.com/arivero/agentbook/issues/new/choose)** using our Content Suggestion template
2. **Automated Processing**: Our GitHub Agentic Workflows (GH-AW) will analyze your suggestion
3. **Follow Updates**: The issue moves through labels: `acknowledged` → `triaged-fast-track` or `triaged-for-research` → `researched-waiting-opinions` → (`opinion-copilot-strategy-posted` + `opinion-copilot-delivery-posted`) → `assigned`

**What happens to suggestions:**
- ✅ **Accepted (fast-track)**: Routed with `triaged-fast-track`, implemented by Copilot, PR opened, and issue closed
- ✅ **Accepted (research lane)**: Routed with `triaged-for-research`, researched, receives two suggestions, marked `assigned`, then closed
- ❌ **Rejected/Out of Scope**: Any agent can reject with rationale and close at any stage

All suggestions related to agentic workflows, orchestration, scaffolding, skills/tools, or GitHub agents are welcome.

## 🛠️ Local Development

To run the book locally:

```bash
# Clone the repository
git clone https://github.com/arivero/agentbook.git
cd agentbook

# Serve with Jekyll (requires Ruby)
bundle install
bundle exec jekyll serve

# Or use GitHub Pages locally
gem install github-pages
github-pages serve
```

## 📋 Project Structure

```
agentbook/
├── book/                    # Book content
│   ├── README.md           # Book introduction
│   └── chapters/           # Manuscript sources
├── blog/                   # Blog posts
├── _layouts/               # Jekyll layouts
├── _posts/                 # Blog post files
├── .github/
│   ├── workflows/          # GitHub Actions
│   └── ISSUE_TEMPLATE/     # Issue templates
├── _config.yml            # Jekyll configuration
└── index.md               # Homepage
```

## 🔧 Workflows

Our repository uses **GitHub Agentic Workflows (GH-AW)** as the canonical approach to automate content processing.

### Core publishing workflows
- **`pages.yml`**: Deploys to GitHub Pages
- **`build-pdf.yml`**: Generates PDF version

### Validation workflows (quality gates)
These are code/content validation checks in practice:
- **`check-links.yml`**: Offline-safe internal link validation
- **`check-external-links.yml`**: Internet-enabled external link validation

`check-external-links.yml` can open issues for broken links and is always considered **fast-track scope** when those issues are handled.

### Issue processing workflows
- `issue-intake-ack.yml`: Standard intake ACK workflow (`issues.opened`) that adds `acknowledged` and dispatches routing
- `issue-routing-decision.lock.yml`: Agentic routing decision workflow (`workflow_dispatch`) that applies `triaged-fast-track` or `triaged-for-research`
- `issue-fast-track-close.lock.yml`: Fast-track implementation + PR + issue closure
- `issue-research-pass.lock.yml`: Researches `triaged-for-research` issues and applies `researched-waiting-opinions`
- `issue-opinion-copilot-strategy.lock.yml`: Posts the Copilot strategy-model slow-track opinion and applies `opinion-copilot-strategy-posted`
- `issue-opinion-copilot-delivery.lock.yml`: Posts the Copilot delivery-model slow-track opinion and applies `opinion-copilot-delivery-posted`
- `issue-assignment-close.lock.yml`: Adds `assigned` and closes when both opinion labels are present

For label-triggered stage handoffs, configure `GH_AW_GITHUB_TOKEN` so safe-outputs writes are attributed to a user token (not the default workflow token), which allows downstream workflows to trigger.

Recommended token setup:
- Use a **fine-grained PAT** restricted to this repository only.
- Repository permissions:
  - `Issues`: `Read and write`
  - `Pull requests`: `Read and write`
  - `Contents`: `Read and write` (needed for fast-track PR creation)
- Do not grant org-wide or all-repository access.

Classic PAT fallback (if needed): use `repo` scope and restrict token usage to this repo in your secret-management policy.

See [WORKFLOW_PLAYBOOK.md](WORKFLOW_PLAYBOOK.md) for the canonical lifecycle and label matrix.

## 📜 License

This work is licensed under the [MIT License](LICENSE) and available for educational purposes.

## 📚 Documentation

- **[README](README.md)** - Project overview and workflow summary
- **[SETUP](SETUP.md)** - Installation and configuration guide
- **[WORKFLOW_PLAYBOOK](WORKFLOW_PLAYBOOK.md)** - Fast-track and full-playbook maintenance process
- **[LICENSE](LICENSE)** - MIT License

## 🌟 Acknowledgments

This project demonstrates the power of agentic workflows by being a living example of the concepts it teaches.

---

**Note**: This is an experimental project exploring self-maintaining documentation through agentic workflows.
