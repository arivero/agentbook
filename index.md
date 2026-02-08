---
layout: default
title: Agentic Workflows Book
---

# Agentic Workflows Book

[Read the book]({{ "/book/" | relative_url }}) (in development) | [PDF](https://github.com/arivero/agentbook/actions/workflows/build-pdf.yml) (available once content is published)

## Latest posts

{% if site.posts and site.posts.size > 0 %}
<ul>
  {% for post in site.posts limit:5 %}
  <li>
    <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
    <small>{{ post.date | date: "%b %-d, %Y" }}</small>
  </li>
  {% endfor %}
</ul>
<p><a href="{{ "/blog/" | relative_url }}">View all blog posts</a></p>
{% else %}
<p>No blog posts yet. <a href="{{ "/blog/" | relative_url }}">Visit the blog</a>.</p>
{% endif %}
