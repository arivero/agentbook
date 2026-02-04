# Contributing to Agentic Workflows Book

Thank you for your interest in contributing to this self-maintaining book! 🤖

## How This Book Works

This book is **self-maintaining** through automated workflows. When you contribute, you're not just adding to a static document—you're feeding into a living system that:

1. Analyzes your contribution
2. Processes it through AI agents
3. Updates the book automatically
4. Publishes changes to the web
5. Announces updates via blog posts

For maintainers and agents, see the [Agentic Workflow Playbook](WORKFLOW_PLAYBOOK.md) for the research → plan → assign loop and required artifacts per update.

## Ways to Contribute

### 1. Suggest Content (Recommended)

The easiest and most effective way to contribute is to **open an issue** with your suggestion:

1. Go to [Issues](https://github.com/arivero/agentbook/issues)
2. Click "New Issue"
3. Select "Content Suggestion"
4. Fill out the template with your suggestion

**What happens next:**
- ✅ Your issue is automatically labeled
- 🤖 Workflows analyze if it's relevant to the book
- 📝 If approved, agents process your suggestion
- 📚 Content is updated automatically
- 🌐 Changes are published to GitHub Pages
- 📰 A blog post announces the update

### 2. Direct Pull Requests

You can also submit pull requests directly:

1. Fork the repository
2. Create a branch (`git checkout -b feature/your-suggestion`)
3. Make your changes to the markdown files in `book/chapters/`
4. Commit your changes (`git commit -m 'Add content about X'`)
5. Push to your branch (`git push origin feature/your-suggestion`)
6. Open a Pull Request

**Guidelines for PRs:**
- Keep changes focused and atomic
- Follow the existing writing style and tone
- Include code examples where appropriate
- Test markdown rendering locally if possible
- Explain the rationale for your changes

### 3. Report Issues

Found a typo, broken link, or error? Open an issue:

1. Go to [Issues](https://github.com/arivero/agentbook/issues/new)
2. Describe the problem clearly
3. Include the chapter and section if applicable
4. Suggest a fix if you have one

## Content Guidelines

### Topics We Cover

The book focuses on:
- **Agentic Workflows**: AI-powered task automation
- **Agent Orchestration**: Coordinating multiple agents
- **Agentic Scaffolding**: Infrastructure for agent systems
- **Skills and Tools**: Creating and managing agent capabilities

### Topics Out of Scope

Please don't submit suggestions about:
- General AI/ML topics not related to agents
- Programming languages or frameworks (unless directly related to agents)
- General software development practices
- Marketing or promotional content

### Writing Style

- **Clear and Concise**: Use simple language
- **Practical**: Include examples and code snippets
- **Educational**: Explain concepts thoroughly
- **Code Examples**: Use Python for examples (with TypeScript as secondary)
- **Professional**: Maintain a professional but friendly tone

### Code Examples

When including code:

```python
# Good: Clear, commented, complete
class Agent:
    """A simple agent that performs tasks."""
    
    def __init__(self, name):
        self.name = name
    
    def execute(self, task):
        """Execute a task and return result."""
        return f"{self.name} completed {task}"
```

Avoid:
- Incomplete snippets without context
- Code without comments
- Overly complex examples

## The Review Process

### For Issues (Suggestions)

1. **Automatic Labeling**: Issues are auto-labeled on creation
2. **Relevance Check**: Workflows check if the topic is in scope
3. **Agent Assignment**: Relevant issues are tagged for agent processing
4. **Content Update**: Agents update the book based on the suggestion
5. **Publication**: Changes are automatically published
6. **Notification**: You'll be notified when your suggestion is incorporated

### For Pull Requests

1. **Manual Review**: PRs are reviewed by maintainers
2. **Testing**: Workflows test building and publishing
3. **Feedback**: You may receive feedback for revisions
4. **Merge**: Once approved, changes are merged
5. **Publication**: Merged changes trigger automatic publication

## Development Setup

To work on the book locally:

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/agentbook.git
cd agentbook

# Install Jekyll (for testing GitHub Pages locally)
gem install bundler jekyll
bundle install

# Serve locally
bundle exec jekyll serve

# View at http://localhost:4000
```

### Testing Locally

Before submitting:

1. **Check Markdown**: Ensure proper formatting
2. **Test Links**: Verify all links work
3. **Review Locally**: Serve with Jekyll and review
4. **Check Code**: Test any code examples

## Communication

- **Questions**: Open an issue with the "question" label
- **Discussions**: Use GitHub Discussions (if enabled)
- **Urgent Issues**: Tag with "urgent" label

## Code of Conduct

- Be respectful and constructive
- Focus on improving the book
- Help create a welcoming environment
- Follow GitHub's Community Guidelines

## Recognition

Contributors are recognized through:
- GitHub's contribution tracking
- Mentions in blog posts about updates
- The book's acknowledgments section

## Questions?

If you have questions about contributing, open an issue with the "question" label, and we'll help guide you!

---

Thank you for helping make this book better! Together, we're building something unique: a book that demonstrates agentic workflows by using them to maintain itself. 🚀
