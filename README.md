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
- **PDF**: Download from [GitHub Actions artifacts](https://github.com/arivero/agentbook/actions/workflows/build-pdf.yml)
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

## 🚀 How It Works

1. **Community Input**: Open an issue with a suggestion
2. **Automated Analysis**: Workflows determine if the suggestion is relevant
3. **Agent Processing**: AI agents update the content
4. **Automatic Build**: Markdown and PDF versions are generated
5. **Publishing**: Changes deploy to GitHub Pages
6. **Blog Update**: A blog post announces the change

## 🤝 Contributing

We welcome contributions! Here's how:

1. **Suggest Content**: [Open an issue](https://github.com/arivero/agentbook/issues/new/choose) with your suggestion
2. **Wait for Processing**: Our automated workflows will analyze your suggestion
3. **Follow Updates**: Watch as the book updates itself!

All suggestions related to agentic workflows, orchestration, scaffolding, or skills/tools are welcome.

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

- **`pages.yml`**: Deploys to GitHub Pages
- **`build-pdf.yml`**: Generates PDF version
- **`process-suggestions.yml`**: Handles issue suggestions

## 📜 License

This work is open source and available for educational purposes.

## 🌟 Acknowledgments

This project demonstrates the power of agentic workflows by being a living example of the concepts it teaches.

---

**Note**: This is an experimental project exploring self-maintaining documentation through agentic workflows.
