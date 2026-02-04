---
layout: book
title: "Agentic Workflows: A Practical Guide"
---

{% assign chapters = site.data.book.chapters | sort: "order" %}
{% for chapter in chapters %}
  {% capture chapter_content %}{% include_relative chapter.path %}{% endcapture %}
  {% assign chapter_parts = chapter_content | split: '---' %}
  {% if chapter_parts.size > 2 %}
    {% assign chapter_body = chapter_parts | slice: 2, chapter_parts.size | join: '---' %}
    {{ chapter_body | strip }}
  {% else %}
    {{ chapter_content | strip }}
  {% endif %}
  {% unless forloop.last %}
---
  {% endunless %}
{% endfor %}
