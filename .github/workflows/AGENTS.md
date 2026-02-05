# Workflow authoring notes

- Every agentic workflow source file (`*.md`) in this directory must be compiled into its executable lock workflow (`*.lock.yml`) using `gh aw` commands before merging.
- Keep source and compiled files in sync in the same PR.
- Issue status labels must follow this lifecycle unless explicitly rejected/closed early:
  - `acknowledged`
  - `triaged-fast-track` **or** `triaged-for-research`
  - `researched-waiting-opinions`
  - `opinion-copilot-strategy-posted` and `opinion-copilot-delivery-posted`
  - `assigned`
- Any agent may reject at any stage by posting rationale, adding `rejected`, and closing the issue.
