# Copilot Instructions for Agentic Workflows Book

## Project Overview

This repository implements a **living, self-maintaining book** about agentic workflows, agent orchestration, and agentic scaffolding. The book is unique because it demonstrates the very concepts it teaches by using automated workflows and AI agents to maintain itself.

**Key Characteristics:**
- Educational content about AI agentic systems
- Self-maintaining through GitHub Actions workflows
- Multi-agent orchestration system for processing community suggestions
- Dual publishing: GitHub Pages (web) and PDF

## Tech Stack

### Core Technologies
- **Static Site Generator**: Jekyll (GitHub Pages default)
- **Theme**: jekyll-theme-minimal
- **Markdown**: Kramdown with GitHub Flavored Markdown (GFM)
- **Syntax Highlighting**: Rouge
- **CI/CD**: GitHub Actions
- **PDF Generation**: Pandoc with LaTeX
- **Version Control**: Git/GitHub
- **Hosting**: GitHub Pages

### Languages
- **Primary**: Markdown (content)
- **Configuration**: YAML (workflows, Jekyll config, issue templates)
- **Code Examples**: Python (primary), TypeScript/JavaScript (secondary)
- **Templating**: Liquid (Jekyll)

## Repository Structure

```
agentbook/
├── .github/
│   ├── agents/                       # GH-AW agent definitions (DO NOT MODIFY)
│   │   ├── issue-ack.md              # Acknowledgment agent
│   │   ├── issue-research.md         # Research agent
│   │   ├── issue-discuss-claude.md   # Claude perspective
│   │   ├── issue-discuss-copilot.md  # Copilot perspective
│   │   ├── issue-writer.md           # Content writer
│   │   ├── issue-complete.md         # Completion agent
│   │   └── issue-workflow.md         # Orchestration workflow
│   ├── ISSUE_TEMPLATE/
│   │   └── suggestion.yml            # Content suggestion form
│   ├── workflows/
│   │   ├── pages.yml                 # Deploy to GitHub Pages
│   │   ├── build-pdf.yml             # Generate PDF
│   │   └── process-suggestions.yml   # Multi-agent processing
│   └── copilot-instructions.md       # This file
├── book/
│   ├── chapters/                     # Book chapters (numbered)
│   │   ├── 000-toc.md                # Table of contents
│   │   ├── 000-front-matter.md       # Front matter
│   │   ├── 010-introduction.md       # Introduction to Agentic Workflows
│   │   ├── 015-language-models.md    # Language Models
│   │   ├── 020-orchestration.md      # Agent Orchestration
│   │   ├── 030-scaffolding.md        # Agentic Scaffolding
│   │   ├── 040-skills-tools.md       # Skills and Tools Management
│   │   ├── 050-discovery-imports.md  # Discovery and Imports
│   │   ├── 060-gh-agentic-workflows.md # GitHub Agentic Workflows
│   │   ├── 070-github-agents.md      # GitHub Agents
│   │   ├── 080-agents-for-coding.md  # Agents for Coding
│   │   ├── 090-agents-for-math-physics.md # Agents for Mathematics and Physics
│   │   ├── 100-failure-modes-testing-fixes.md # Failure Modes, Testing and Fixes
│   │   └── 990-bibliography.md       # Bibliography
│   ├── README.md                     # Book introduction
│   └── index.md                      # Book homepage
├── blog/
│   └── index.md                      # Blog listing
├── _layouts/
│   ├── default.html                  # Main layout
│   └── post.html                     # Blog post layout
├── _posts/                           # Blog posts (YYYY-MM-DD-title.md)
├── _config.yml                       # Jekyll configuration
└── index.md                          # Site homepage
```

## Coding Guidelines

### Markdown Content
- Use GitHub Flavored Markdown (GFM)
- Include code fences with language specifiers (```python, ```yaml, etc.)
- Use proper heading hierarchy (# for chapter titles, ## for sections, ### for subsections)
- Keep paragraphs concise and readable
- Include practical examples and code snippets
- Use bullet points and numbered lists for clarity

### Code Examples
- **Primary language**: Python for agent and workflow examples
- **Secondary language**: TypeScript/JavaScript for GitHub integration examples
- Always include comments explaining the code
- Keep examples complete and runnable when possible
- Prefer clear, educational code over overly concise or complex patterns

**Example Structure:**
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

### YAML Configuration
- Use 2-space indentation (not tabs)
- Include comments for complex workflows
- Validate YAML syntax before committing
- Follow GitHub Actions best practices for workflows
- Set appropriate permissions (principle of least privilege)

### File Naming
- Book chapters: `NNN-descriptive-name.md` (000-toc.md, 010-introduction.md, 015-language-models.md, etc.)
- Blog posts: `YYYY-MM-DD-title.md` (2026-02-04-welcome.md)
- Agent files: `issue-{purpose}.md` (issue-ack.md, issue-research.md, etc.)
- Workflows: `descriptive-name.yml` (pages.yml, build-pdf.yml, etc.)

## Strict Rules

### NEVER
- **DO NOT** modify files in `.github/agents/` directory - these are agent definitions managed by workflows
- **DO NOT** remove or disable security features
- **DO NOT** commit secrets or credentials
- **DO NOT** add binary files to the repository (use releases for PDFs)
- **DO NOT** break the existing Jekyll build configuration
- **DO NOT** change chapter numbering without updating all references
- **DO NOT** add content outside the scope of agentic workflows, orchestration, and scaffolding

### ALWAYS
- Run `bundle exec jekyll build` to validate changes before committing
- Test markdown rendering locally when possible
- Include proper YAML frontmatter for blog posts
- Maintain the existing writing style and tone
- Keep changes focused and atomic
- Update table of contents (000-toc.md) when adding/modifying chapters
- Follow the established multi-agent workflow for content suggestions

## Special Context

### Self-Maintaining System
This book is itself an example of agentic workflows. When working on the codebase:
- The **process-suggestions.yml** workflow orchestrates multiple AI agents
- Agent definitions in `.github/agents/` implement the ResearchPlanAssign pattern
- The system demonstrates the concepts taught in the book

### Content Focus
All content should relate to:
1. **Agentic Workflows**: AI-powered task automation and adaptation
2. **Agent Orchestration**: Coordinating multiple agents effectively
3. **Agentic Scaffolding**: Infrastructure enabling agent operation
4. **Skills and Tools**: Creating and managing agent capabilities
5. **GitHub-specific implementations**: Copilot, Coding Agent, GH-AW

### Quality Standards
- Content must be educational and practical
- Include real-world examples and use cases
- Explain the "why" behind concepts, not just the "how"
- Maintain professional but accessible tone
- Code examples must be clear and well-commented

## Build and Test Process

### Local Development
```bash
# Install dependencies
bundle install

# Serve locally (view at http://localhost:4000)
bundle exec jekyll serve

# Build only (check for errors)
bundle exec jekyll build

# Clean build artifacts
bundle exec jekyll clean
```

### Automated Workflows
- **Pages deployment**: Triggers on push to main branch
- **PDF generation**: Triggers on changes to book/ directory
- **Issue processing**: Triggers on new issues and label changes

### Before Committing
1. Validate markdown syntax
2. Test Jekyll build locally: `bundle exec jekyll build`
3. Check for broken links
4. Ensure code examples are correct
5. Update documentation if needed

## Issue Processing Workflow

When community members submit suggestions:
1. **Acknowledgment**: Auto-response validates the suggestion
2. **Research**: Agent investigates novelty and value
3. **Discussion**: Multiple AI models provide perspectives
4. **Writing**: Content is drafted based on consensus (human approval required)
5. **Completion**: Changes are merged and issue closed

**Human Gates**: Maintainers must add `ready-for-writing` label before content generation.

## Contributing Context

### For Direct Edits
- Edit markdown files in `book/chapters/`
- Follow existing chapter structure and style
- Update `00-toc.md` if adding sections
- Test locally before submitting PR

### For Workflow Changes
- Modify YAML files in `.github/workflows/`
- Ensure proper permissions are set
- Test with manual workflow triggers if possible
- Document changes in commit messages

### For Agent Definitions
- Agent files use YAML frontmatter
- Follow GH-AW specification (see Chapter 5)
- Include clear agent descriptions and tool requirements
- Test through issue workflow if possible

## Compatibility Notes

- **Jekyll Version**: Uses GitHub Pages default (currently Jekyll 3.x)
- **Ruby**: Compatible with Ruby 2.7+ (GitHub Pages requirement)
- **Markdown Parser**: Kramdown (required by GitHub Pages)
- **Theme**: jekyll-theme-minimal (minimal dependencies)

## Security Considerations

- All workflows use minimal required permissions
- No secrets should be committed to the repository
- External actions pinned to specific commits where possible
- Issue processing workflow validates input format
- Agent operations are logged for transparency

## Documentation References

- **Setup Guide**: See `SETUP.md` for installation and troubleshooting
- **Contributing Guide**: See `CONTRIBUTING.md` for detailed contribution instructions
- **Workflow Playbook**: See `WORKFLOW_PLAYBOOK.md` for GH-AW maintenance patterns
- **Project Summary**: See `PROJECT_SUMMARY.md` for comprehensive project overview

## Success Criteria

Pull requests and changes should:
- ✅ Build successfully with Jekyll
- ✅ Maintain consistent formatting and style
- ✅ Stay within project scope (agentic workflows topics)
- ✅ Include appropriate documentation updates
- ✅ Pass any existing validation workflows
- ✅ Follow the established chapter structure
- ✅ Include practical, working code examples
- ✅ Enhance the educational value of the book

## AGENTS.md Convention

Before working in any directory, always read the `AGENTS.md` file located in that directory (if one exists) for directory-specific conventions and constraints. Key locations:

- `/AGENTS.md` – top-level contributor notes.
- `.github/workflows/AGENTS.md` – workflow authoring rules and label lifecycle.

---

**Remember**: This book teaches by example. The quality of the implementation reflects the quality of the concepts being taught. Write code and content as if you're demonstrating best practices to learners.
