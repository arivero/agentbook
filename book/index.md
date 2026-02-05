---
layout: default
title: "Agentic Workflows: A Practical Guide"
book_continuous: true
---

# Agentic Workflows: A Practical Guide

[Download PDF](https://github.com/arivero/agentbook/raw/main/book/agentic-workflows-book.pdf)

## Full Book

{% assign chapter_pages = site.pages | where_exp: "page", "page.path contains 'book/chapters/'" | where_exp: "page", "page.order" | sort: "order" %}

{% for chapter in chapter_pages %}
{% if chapter.order > 0 %}
<article id="chapter-{{ chapter.order }}" class="book-chapter">
{{ chapter.content }}
<hr />
</article>
{% endif %}
{% endfor %}
