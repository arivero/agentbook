---
layout: default
title: Table of Contents
order: 0
---

# Table of Contents

## [Book Home](../index.html) | [Website Home](../../index.html)

---

## Chapters

{% assign chapters = site.data.book.chapters | sort: "order" | where: "toc", true %}
{% for chapter in chapters %}
{{ forloop.index }}. **[{{ chapter.title }}]({{ chapter.path | replace: 'chapters/', '' | replace: '.md', '.html' }})**
   {% if chapter.sections %}
     {% for section in chapter.sections %}
   - {{ section.title }}
     {% endfor %}
   {% endif %}
{% endfor %}

---

[← Back to Book Home](../index.html)
