---
layout: post
title: "Progress into Issue Automation"
date: 2026-02-06
---

We just shipped a round of fixes to the **agentic workflow pipeline** that processes community suggestions filed as GitHub issues. These changes make the system significantly cheaper, more correct, and better equipped to research topics.

## What Changed

- **Label-filtered activation** — Every `issues.labeled` workflow now declares the specific label(s) it cares about via the gh-aw `names:` frontmatter key. Previously, all five labeled workflows fired on *every* label event, burning ~25 wasted workflow runs per issue through the full agent infrastructure just to have the LLM check a label and exit. Now each workflow short-circuits at the GitHub Actions level before spinning up any containers.

- **Consistent lifecycle labels** — The fast-track path now adds the `assigned` label before closing, matching the slow-track lifecycle. Queries filtering by `assigned` will correctly find all completed issues regardless of which path they took.

- **Real web access for the research agent** — The research-pass workflow previously declared `web-search` and `web-fetch` tools that the Copilot engine doesn't support. It now has **Playwright** (headless browser, no secrets needed), the **GitHub search toolset** (code/repo/issue search via the existing token), and an optional **Tavily MCP server** (AI-optimized web search for when you add the API key).

## Why It Matters

The issue pipeline is central to how this book maintains itself. Every wasted workflow run is real compute, and a research agent that can't actually search the web isn't really researching. These fixes bring the pipeline closer to what it was always meant to be: a lean, self-correcting system where each agent fires only when needed and has the tools to do its job well.

## What's Next

A few lower-severity items remain on the radar: pinning CI action references to commit SHAs, locking the Pandoc container tag, and reviewing the PDF auto-merge policy. These are incremental hardening steps that don't affect the core workflow logic.

---

*This update was itself identified, researched, and implemented through the kind of agentic review loop the book describes — fitting, for a book that practices what it teaches.*
