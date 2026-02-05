# Changelog

All notable changes to the Agentic Workflows Book will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Front matter section with title page, copyright, preface, and conventions
- Bibliography section with access dates for external references
- Link checker script and CI workflow for Markdown URLs
- LICENSE file (MIT License)
- CODE_OF_CONDUCT.md (Contributor Covenant 2.0)
- CHANGELOG.md to track changes
- WORKFLOWS.md - Comprehensive workflow documentation explaining GH-AW vs legacy approaches
- Documentation references in README for issue submission process
- Policy for rejected issues to move to GitHub Discussions
- Multi-agent platform compatibility coverage and agent configuration guidance

### Changed
- Reordered PDF build inputs and metadata to ensure correct title page and chapter order
- Removed duplicated “Chapter N” labels from headings and front matter titles
- Updated GH-AW examples to match compiled workflow structure and setup actions
- Updated GitHub Actions versions to current major releases (checkout v6, github-script v8, create-pull-request v8)
- Added chapter previews, clarified terminology, and inserted security callouts
- Standardized documentation structure following OSS best practices
- Clarified workflow approach: GH-AW workflows (.lock.yml) are canonical
- Updated CONTRIBUTING with workflow details and rejected issue policy
- Enhanced GitHub agents content with repository documentation references and agent configuration files section
- Updated copilot-instructions.md to include expanded structure guidance
- Updated PROJECT_SUMMARY.md to reflect the current manuscript structure

### Fixed
- Replaced fictional GitHub Actions references for Copilot and GH-AW with documented workflows
- build-pdf.yml includes the latest manuscript sources

### Known Issues
- Link checker skips <https://platform.openai.com/docs/guides/codex/skills> because the site returns HTTP 403 to unauthenticated requests; verify with authenticated access before release.

## [0.1.0] - 2026-02-04

### Added
- Initial release of the Agentic Workflows Book
- GitHub Pages deployment with Jekyll
- PDF generation workflow
- Multi-agent issue processing system
- Blog functionality
- Issue templates for content suggestions
- Complete documentation suite (README, CONTRIBUTING, SETUP, WORKFLOW_PLAYBOOK)

### Features
- Self-maintaining book concept
- Automated content processing via GitHub Actions
- Multi-stage agent workflow (ACK, Research, Discussion, Writing, Completion)
- GH-AW agent definitions for future integration

[Unreleased]: https://github.com/arivero/agentbook/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/arivero/agentbook/releases/tag/v0.1.0
