---
layout: default
title: Blog
---

# Blog

Latest updates and news about the Agentic Workflows Book.

{% for post in site.posts %}
  <article style="margin-bottom: 40px;">
    <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
    <p><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%B %d, %Y" }}</time></p>
    <p>{{ post.excerpt }}</p>
    <p><a href="{{ post.url | relative_url }}">Read more →</a></p>
  </article>
{% endfor %}

{% if site.posts.size == 0 %}
  <p>No blog posts yet. Check back soon!</p>
{% endif %}
