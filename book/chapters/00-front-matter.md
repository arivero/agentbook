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

Copyright © 2026 Agentbook Contributors. All rights reserved.

This is an open-source manuscript distributed for educational purposes. No part of this work may be reproduced in any form or by any means without the prior written permission of the contributors, except for brief quotations in reviews.

# Preface {-}

This book is for engineering leaders, platform teams, and practitioners who want to build reliable agentic workflows in real software systems. We focus on practical architecture, safe operations, and buildable examples rather than hype or speculative design.

You should be comfortable with Git, GitHub Actions, and basic software engineering practices. We assume familiarity with automation tools and CI/CD concepts.

# Conventions Used in This Book {-}

- **Inline code** is shown in a monospaced font.
- **File names** appear above code blocks (Example 4-2, etc.).
- **Commands** use fenced code blocks with a language tag.
- **Code samples** include a snippet-status label when version drift is likely:
  - **Runnable**: intended to run with minor adaptation, usually with a version/date note.
  - **Illustrative pseudocode**: architecture pattern, not copy/paste ready.
  - **Simplified**: runnable shape, but omits production details (auth, retries, error handling).
- **Tip**, **Note**, and **Warning** callouts highlight critical guidance.

> **Tip:** Prefer pinned action SHAs in CI workflows that handle secrets.

> **Warning:** Always review agent-generated changes before merge, especially when credentials or production systems are involved.
