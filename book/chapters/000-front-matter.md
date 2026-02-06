---
title: "Agentic Workflows"
subtitle: "A Practical Guide"
author: "Agentbook Contributors"
lang: "en-US"
order: 0
---

\newpage
\thispagestyle{empty}
\begin{center}
\vspace*{2in}
{\Huge Agentic Workflows}\\[0.5em]
{\Large A Practical Guide}
\end{center}
\newpage

\thispagestyle{empty}
\begin{center}
{\Huge Agentic Workflows}\\[0.5em]
{\Large A Practical Guide}\\[2em]
{\large Agentbook Contributors}\\[1em]
{\large February 2026}
\end{center}
\newpage

\tableofcontents
\newpage

# Copyright {-}

Copyright © 2026 Agentbook Contributors.

This manuscript is open source and licensed under the [MIT License](../../LICENSE). You may use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies, subject to the MIT license terms.

# Preface {-}

This book is for engineering leaders, platform teams, and practitioners who want to build reliable agentic workflows in real software systems. We focus on practical architecture, safe operations, and buildable examples rather than hype or speculative design.

You should be comfortable with Git, GitHub Actions, and basic software engineering practices. We assume familiarity with automation tools and CI/CD concepts.

# Conventions Used in This Book {-}

Throughout this book, **inline code** is shown in a monospaced font to distinguish code elements from surrounding prose. **File names** appear above code blocks with labels such as "Example 4-2" to help you locate specific snippets. All **commands** use fenced code blocks with a language tag (for example, `bash`, `python`, or `yaml`) so you can identify the appropriate interpreter.

**Code samples** include a snippet-status label when version drift is likely. A sample marked **Runnable** is intended to run with minor adaptation and usually includes a version or date note for context. A sample marked **Illustrative pseudocode** demonstrates an architecture pattern and is not copy/paste ready. A sample marked **Simplified** has a runnable shape but omits production details such as authentication, retries, and error handling.

**Tip**, **Note**, and **Warning** callouts highlight critical guidance that merits special attention.

> **Tip:** Prefer pinned action SHAs in CI workflows that handle secrets.

> **Warning:** Always review agent-generated changes before merge, especially when credentials or production systems are involved.

<!-- Edit notes:
Sections expanded: Conventions Used in This Book (converted bullet list to three explanatory paragraphs)
Lists preserved: None (the original bullets were shorthand conventions that read better as prose)
Ambiguous phrases left ambiguous: None identified
-->
