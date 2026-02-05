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
