---
layout: default
title: "Agentic Workflows: A Practical Guide"
book_continuous: true
---

# Agentic Workflows: A Practical Guide

A living book about agentic workflows, agent orchestration, and agentic scaffolding.

[Download PDF](https://github.com/arivero/agentbook/raw/main/book/agentic-workflows-book.pdf)

## Chapters

{% assign chapter_pages = site.pages | where_exp: "page", "page.path contains 'book/chapters/'" | where_exp: "page", "page.order" | sort: "order" %}
{% for chapter in chapter_pages %}
{% if chapter.order > 0 %}
- [{{ chapter.title }}](#chapter-{{ chapter.order }})
{% endif %}
{% endfor %}

---

## Full Book

{% for chapter in chapter_pages %}
{% if chapter.order > 0 %}
<section id="chapter-{{ chapter.order }}" class="book-chapter">
{{ chapter.content }}
<hr />
</section>
{% endif %}
{% endfor %}

## About This Book

This book demonstrates modern AI-powered development practices by being self-maintaining - the book updates itself based on community suggestions and contributions through automated workflows.

### What You'll Learn

- **Agentic Workflows**: Understanding how AI agents can automate complex tasks
- **Agent Orchestration**: Coordinating multiple agents to work together effectively
- **Agentic Scaffolding**: Building the infrastructure for agent-driven development
- **Skills and Tools**: How to use, import, and compose agent capabilities
- **GitHub Agentic Workflows**: Practical implementation with GitHub Actions

### Contributing

This book welcomes contributions! Open an issue with suggestions, and our automated workflows will process and integrate valuable feedback.

### License

This work is open source and available for educational purposes.
