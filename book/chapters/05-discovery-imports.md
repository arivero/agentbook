---
title: "Discovery and Imports"
order: 5
---

# Discovery and Imports

## Chapter Preview

This chapter standardizes language that often gets overloaded in agentic systems. We define what an artefact is, what discovery means in practice, and how import, install, and activate are separate operations with different safety controls.

- Build a taxonomy for what gets discovered: tools, skills, agents, and workflow fragments.
- Compare discovery mechanisms: local scan, registry, domain convention, and explicit configuration.
- Disambiguate import/install/activate and map each step to trust and supply-chain controls.

## Terminology Baseline for the Rest of the Book

To keep later chapters precise, this chapter uses five core terms consistently:

- **artefact**: any reusable unit a workflow can reference (tool endpoint metadata, a skill bundle, an agent definition, or a workflow fragment).
- **discovery**: the process of finding candidate artefacts.
- **import**: bringing a discovered artefact into the current resolution/evaluation context.
- **install**: fetching and persisting an artefact (typically pinned), plus integrity metadata.
- **activate**: making an installed/imported artefact callable by an agent in a specific run context.

> **Standardization rule:** Use these verbs literally. Do not use “import” when you mean “install,” and do not use “install” when you mean “activate.”

## A Taxonomy That Disambiguates What We Are Discovering

### 1) Tool artefacts

A **tool** is an executable capability exposed via a protocol or command surface.

- **Identity**: endpoint identity (for example, an MCP server URL + auth context).
- **Interface**: enumerated callable tools (names, schemas, permissions).

Discovery usually finds endpoints first; tool enumeration happens after connection.

### 2) Skill artefacts

A **skill** is a packaged reusable bundle of instructions, templates, and optional scripts.

- **Identity**: bundle source (repo path, registry coordinate, version/digest).
- **Interface**: documented entrypoints, expected inputs/outputs, and policy constraints.

### 3) Agent artefacts

An **agent** artefact is a role/config definition (persona, constraints, and operating policy).

- **Identity**: a named definition file and version.
- **Interface**: responsibilities, boundaries, and allowed capability set.

### 4) Workflow-fragment artefacts

A **workflow fragment** is a reusable partial workflow (for example, a GH-AW component).

- **Identity**: source file path or import address.
- **Interface**: parameters, expected context, and emitted outputs.

### Confusing cases to stop using

- **tool != skill**: tools execute capabilities; skills package guidance/assets.
- **skill != agent**: skills are reusable bundles; agents are operating roles.
- **agent != workflow fragment**: an agent is an actor; a fragment is orchestration structure.

When this book says “discover capabilities,” read it as “discover artefacts, then import/install/activate according to type.”

## Discovery Mechanisms

Discovery is how runtimes gather candidate artefacts before selection.

### Local scan

Scan repository paths and conventions (for example, `.github/workflows/`, `skills/`, `agents/`).

- **Pros**: low latency, high transparency, easy review in code.
- **Cons**: limited scope, convention drift in large monorepos.

### Registry discovery

Query a curated index/marketplace for artefacts.

- **Pros**: centralized metadata, version visibility, governance hooks.
- **Cons**: trust shifts to registry policy; namespace collisions possible.

### Domain-convention discovery

Resolve artefacts via domain naming conventions (for example, `.well-known`-style descriptors).

- **Pros**: interoperable discovery across organizational boundaries.
- **Cons**: conventions may be ecosystem-specific, not always standardized.

### Explicit configuration

Use a pinned manifest that enumerates allowed sources and versions.

- **Pros**: strongest reproducibility and auditability.
- **Cons**: less flexible; requires deliberate updates.

**Decision rule:** if provenance cannot be authenticated, prefer explicit configuration over dynamic discovery.

## Import, Install, Activate: Three Different Operations

### Import

Import brings an artefact into the current resolution context.

- Language/module example: `from src.utils import helpers`
- GH-AW example: `imports: [shared/common-tools.md]`

### Install

Install fetches and persists artefacts for repeatable use.

- Example: store `skill-x@1.4.2` with checksum/signature metadata.
- Example: lock workflow component revision to a commit digest.

### Activate

Activate makes an artefact callable under policy.

- Example: expose only `bash` and `edit` tools to a CI agent.
- Example: enable a skill only after approval gate passes.

A practical sequence is often: **discover -> select -> import/install -> activate -> execute**.

## Trust Boundaries and Supply Chain (Compact Model)

Each stage has distinct risks and controls:

- **Integrity** (was artefact tampered with?): checksums, signatures.
- **Authenticity** (who published it?): identity verification, trusted publisher lists.
- **Provenance** (how was it built?): attestations/SBOM, reproducible build metadata.
- **Capability safety** (what can it do?): least privilege, sandboxing, constrained outputs.

Control mapping:

- **Discovery controls**: allowlists of domains/registries.
- **Import/install controls**: pinning + checksum/signature verification.
- **Activation controls**: permission gates, scoped credentials, sandbox profiles.
- **Runtime controls**: audit logs, safe outputs, and policy evaluation traces.

## Worked Examples

### Example A: GH-AW workflow-fragment import

```yaml
# .github/workflows/docs-refresh.md
name: Docs Refresh
on:
  workflow_dispatch:
imports:
  - shared/common-tools.md

permissions:
  contents: read
```

Interpretation:
- `shared/common-tools.md` is a **workflow-fragment artefact**.
- `imports` is the **import** operation.
- A separate policy decides whether imported tools are **activated**.

### Example B: AGENTS.md import conventions as resolution policy

```markdown
## Import Conventions
- Prefer absolute imports from `src/`
- Group imports: stdlib, third-party, local
- Use `@/` alias for `src/`
```

Interpretation:
- This does **not** install dependencies.
- It standardizes **import resolution behavior** so agents generate consistent code.
- Activation still depends on tool/runtime permissions.

### Example C: Capability discovery and activation policy

```yaml
# policies/capability-sources.yml
allowed_domains:
  - "skills.example.com"
allowed_registries:
  - "registry.internal/agent-skills"
pinned:
  "registry.internal/agent-skills/reviewer": "2.3.1"
checksums:
  "registry.internal/agent-skills/reviewer@2.3.1": "sha256:..."
activation_gates:
  require_human_approval_for:
    - "github.write"
    - "bash.exec"
```

Interpretation:
- Discovery scope is constrained first.
- Install/import are pinned and integrity-checked.
- High-impact capabilities require explicit activation approval.

## Key Takeaways

- Treat **artefact**, **discovery**, **import**, **install**, and **activate** as distinct terms.
- Discovering a tool endpoint is not the same as activating its capabilities.
- Use taxonomy-first language: tool, skill, agent, and workflow fragment are different artefact types.
- Prefer explicit, pinned configuration when provenance or authenticity is uncertain.
- Apply controls by stage: allowlist at discovery, verify at import/install, and least privilege at activation/runtime.
