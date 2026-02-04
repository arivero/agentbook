# Agentic Workflows Book

A **living, self-maintaining book** about agentic workflows, agent orchestration, and agentic scaffolding.

[![Deploy to GitHub Pages](https://github.com/arivero/agentbook/actions/workflows/pages.yml/badge.svg)](https://github.com/arivero/agentbook/actions/workflows/pages.yml)
[![Build PDF](https://github.com/arivero/agentbook/actions/workflows/build-pdf.yml/badge.svg)](https://github.com/arivero/agentbook/actions/workflows/build-pdf.yml)

## 🤖 What Makes This Book Special?

This book doesn't just teach about agentic workflows—it **uses them**! The book automatically:
- 📝 Processes community suggestions from GitHub issues
- ✍️ Updates content using AI agents
- 📚 Generates markdown and PDF versions
- 🌐 Publishes to GitHub Pages
- 📰 Creates blog posts about updates

## 📖 Read the Book

- **Online**: [https://arivero.github.io/agentbook](https://arivero.github.io/agentbook) (GitHub Pages)
- **PDF**: Download from [GitHub Actions artifacts](https://github.com/arivero/agentbook/actions/workflows/build-pdf.yml) or the [repo PDF](https://github.com/arivero/agentbook/raw/main/book/agentic-workflows-book.pdf)
- **Source**: Browse the [book directory](book)

## 🎯 What You'll Learn

### [Agentic Workflows](book/chapters/01-introduction.md)
Understanding how AI agents can automate complex tasks and adapt to changing requirements.

### [Agent Orchestration](book/chapters/02-orchestration.md)
Coordinating multiple agents to work together effectively toward common goals.

### [Agentic Scaffolding](book/chapters/03-scaffolding.md)
Building the infrastructure and frameworks that enable agents to operate effectively.

### [Skills and Tools Management](book/chapters/04-skills-tools.md)
How to create, import, and compose agent capabilities for maximum effectiveness.

### [GitHub Agentic Workflows (GH-AW)](book/chapters/05-gh-agentic-workflows.md)
How GH-AW turns markdown into secure, composable repository automation.

### [GitHub Agents](book/chapters/06-github-agents.md)
Deep dive into GitHub Copilot, Copilot Coding Agent, and multi-agent orchestration.

## 🚀 How It Works

1. **Community Input**: Open an issue with a suggestion
2. **Automated Analysis**: Workflows determine if the suggestion is relevant
3. **Agent Processing**: AI agents update the content
4. **Automatic Build**: Markdown and PDF versions are generated
5. **Publishing**: Changes deploy to GitHub Pages
6. **Blog Update**: A blog post announces the change

## 🤝 Contributing

We welcome contributions! Here's how:

### Suggest Improvements via Issues

The primary way to contribute is by **opening an issue** with your suggestion:

1. **[Open an issue](https://github.com/arivero/agentbook/issues/new/choose)** using our Content Suggestion template
2. **Automated Processing**: Our GitHub Agentic Workflows (GH-AW) will analyze your suggestion
3. **Multi-Agent Review**: Multiple AI agents will discuss and develop your idea
4. **Follow Updates**: Watch as agents comment and the book updates itself!

**What happens to suggestions:**
- ✅ **Accepted**: Processed through our multi-agent workflow and added to the book
- 🔄 **Needs Revision**: Agents will request clarifications or additional details
- ❌ **Rejected/Out of Scope**: Moved to [GitHub Discussions](https://github.com/arivero/agentbook/discussions) for community conversation

All suggestions related to agentic workflows, orchestration, scaffolding, skills/tools, or GitHub agents are welcome.

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

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
│   └── chapters/           # Book chapters
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

**Active Workflows:**
- **`pages.yml`**: Deploys to GitHub Pages
- **`build-pdf.yml`**: Generates PDF version
- **GH-AW Workflows** (`.lock.yml` files): Agentic issue processing
  - `issue-triage-lite.lock.yml`: Initial triage and acknowledgment
  - `issue-synthesis.lock.yml`: Research synthesis and recommendations
  - `issue-fast-track.lock.yml`: Fast-track small changes
- **`process-suggestions.yml`**: Legacy multi-stage workflow (maintained as fallback/example)

See [WORKFLOWS.md](WORKFLOWS.md) for detailed workflow documentation and the rationale for using GH-AW.

## 📜 License

This work is licensed under the [MIT License](LICENSE) and available for educational purposes.

## 📚 Documentation

- **[README](README.md)** - Project overview and quick start
- **[CONTRIBUTING](CONTRIBUTING.md)** - How to contribute content
- **[WORKFLOWS](WORKFLOWS.md)** - Detailed workflow guide (GH-AW vs legacy)
- **[SETUP](SETUP.md)** - Installation and configuration guide
- **[WORKFLOW_PLAYBOOK](WORKFLOW_PLAYBOOK.md)** - GH-AW maintenance process
- **[PROJECT_SUMMARY](PROJECT_SUMMARY.md)** - Comprehensive project overview
- **[SECURITY_SUMMARY](SECURITY_SUMMARY.md)** - Security scan results and practices
- **[CHANGELOG](CHANGELOG.md)** - Version history and changes
- **[CODE_OF_CONDUCT](CODE_OF_CONDUCT.md)** - Community guidelines
- **[LICENSE](LICENSE)** - MIT License

## 🌟 Acknowledgments

This project demonstrates the power of agentic workflows by being a living example of the concepts it teaches.

---

**Note**: This is an experimental project exploring self-maintaining documentation through agentic workflows.
