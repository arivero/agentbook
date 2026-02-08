---
title: "Discovery and Imports"
order: 5
---

# Discovery and Imports

## Chapter Preview

This chapter standardises language that often gets overloaded in agentic systems. We define what an artefact is, what discovery means in practice, and how import, install, and activate are separate operations with different safety controls.

The chapter builds a taxonomy for what gets discovered—tools, skills, agents, and workflow fragments—providing clear definitions that prevent confusion as systems grow more complex. It compares discovery mechanisms including local scans, registries, domain conventions, and explicit configuration, explaining the trade-offs of each approach. Finally, it disambiguates the operations of import, install, and activate, mapping each step to appropriate trust and supply-chain controls.

## Terminology Baseline for the Rest of the Book

To keep later chapters precise, this chapter uses five core terms consistently.

An **artefact** is any reusable unit a workflow can reference, including tool endpoint metadata, a skill bundle, an agent definition, or a workflow fragment. **Discovery** is the process of finding candidate artefacts that might be useful for a given task. **Import** means bringing a discovered artefact into the current resolution or evaluation context so it can be referenced. **Install** means fetching and persisting an artefact (typically pinned to a specific version), along with integrity metadata such as checksums or signatures. **Activate** means making an installed or imported artefact callable by an agent in a specific run context.

> **Standardisation rule:** Use these verbs literally. Do not use "import" when you mean "install," and do not use "install" when you mean "activate." Precise terminology prevents misunderstandings about what security controls apply at each stage.

## A Taxonomy That Disambiguates What We Are Discovering

### 1) Tool artefacts

A **tool** is an executable capability exposed via a protocol or command surface. A tool's **identity** is its endpoint identity, such as an MCP server URL combined with an authentication context. A tool's **interface** consists of the enumerated callable operations it exposes, including their names, schemas, and permission requirements.

Discovery usually finds endpoints first; tool enumeration happens after connection, when the client can query what operations the tool server supports.

### 2) Skill artefacts

A **skill** is a packaged reusable bundle of instructions, templates, and optional scripts. A skill's **identity** is its bundle source, which may be a repository path, a registry coordinate, or a version and digest combination. A skill's **interface** comprises its documented entrypoints, expected inputs and outputs, and policy constraints that govern how it may be used.

### 3) Agent artefacts

An **agent** artefact is a role and configuration definition that specifies a persona, constraints, and operating policy. An agent's **identity** is a named definition file and version. An agent's **interface** includes its responsibilities, boundaries, and the set of capabilities it is allowed to use.

### 4) Workflow-fragment artefacts

A **workflow fragment** is a reusable partial workflow, such as a GH-AW component that can be imported into other workflows. A workflow fragment's **identity** is its source file path or import address. A workflow fragment's **interface** includes its parameters, the context it expects, and the outputs it emits.

### Confusing cases to stop using

Several common conflations cause confusion and should be avoided. A **tool is not the same as a skill**: tools execute capabilities, while skills package guidance and assets that tell agents how to use tools effectively. A **skill is not the same as an agent**: skills are reusable bundles of instructions, while agents are operating roles that may use skills. An **agent is not the same as a workflow fragment**: an agent is an actor that performs work, while a fragment is orchestration structure that defines how work flows between actors.

When this book says "discover capabilities," read it as "discover artefacts, then import, install, or activate according to type."

## Discovery Mechanisms

Discovery is how runtimes gather candidate artefacts before selection. Different mechanisms suit different contexts.

### Local scan

Local scanning examines repository paths and conventions (for example, `.github/workflows/`, `skills/`, `agents/`) to find artefacts available within the codebase. The advantages are low latency, high transparency, and easy review in code—everything is visible in the repository. The disadvantages are limited scope and convention drift in large monorepos, where different teams may adopt inconsistent conventions.

### Registry discovery

Registry discovery queries a curated index or marketplace for artefacts. The advantages include centralised metadata, version visibility, and governance hooks that can enforce organisational policy. The disadvantages are that trust shifts to registry policy (the registry becomes a critical dependency), and namespace collisions are possible when multiple teams use similar names.

### Domain-convention discovery

Domain-convention discovery resolves artefacts via domain naming conventions, such as `.well-known`-style descriptors that expose capability metadata at predictable URLs. The advantage is interoperable discovery across organisational boundaries—you can discover capabilities from external partners using a standard protocol. The disadvantage is that conventions may be ecosystem-specific and are not always standardised across vendors.

### Explicit configuration

Explicit configuration uses a pinned manifest that enumerates allowed sources and versions. The advantages are strongest reproducibility and auditability—you know exactly what artefacts will be used. The disadvantages are less flexibility and the need for deliberate updates whenever artefacts change.

**Decision rule:** If provenance cannot be authenticated, prefer explicit configuration over dynamic discovery. Security concerns outweigh convenience when you cannot verify where an artefact came from.

### Agent-native discovery

Agent-native discovery platforms act like social networks for agents: agents register themselves, publish activity, and use reputation signals to find peers. **Moltbook** (launched January 2026) is an early example where agents create profiles, join topic communities ("submolts"), and exchange tasks through A2A-style handshakes. Registration and visibility are driven by agent participation rather than human curation, and integration points already include an MCP server and a public REST API ([moltbook/api](https://github.com/moltbook/api)).

| Traditional registry | Agent social network |
| --- | --- |
| Human or vendor curation decides what is listed | Agent voting and participation drive visibility |
| Static metadata (README, version tags) | Activity streams plus karma/reputation signals |
| Discovery happens out of band from execution | Discovery and coordination share the same surface |
| Import is an explicit pull | Agents proactively advertise capabilities and availability |

**When to use:** distributed ecosystems where peer agents must find each other dynamically, cases where fresh activity and reputation matter more than static version numbers, and research environments exploring emergent coordination patterns.  
**When to avoid:** compliance-bound workflows that require pinned, auditable artefacts; latency-sensitive paths where an external social graph would add variability; or any case where provenance must be cryptographically verifiable (prefer explicit configuration above).

The space is nascent and likely to evolve. Track updates in the ecosystem catalog at [awesome-moltbook](https://github.com/clawddar/awesome-moltbook), and treat agent-native discovery as a complement to (not a replacement for) explicit configuration when safety or provenance is critical.

## Import, Install, Activate: Three Different Operations

### Import

Import brings an artefact into the current resolution context. In language and module terms, this looks like `from src.utils import helpers`. In GH-AW terms, this looks like `imports: [shared/common-tools.md]`. Import makes the artefact available for reference but does not necessarily make it callable.

### Install

Install fetches and persists artefacts for repeatable use. For example, you might store `skill-x@1.4.2` with checksum and signature metadata to ensure integrity. Another example is locking a workflow component revision to a commit digest so that future runs use the exact same version.

### Activate

Activate makes an artefact callable under policy. For example, you might expose only `bash` and `edit` tools to a CI agent, withholding more dangerous capabilities. Another example is enabling a skill only after an approval gate passes, ensuring human oversight for high-impact operations.

A practical sequence is often: **discover → select → import/install → activate → execute**.

## Trust Boundaries and Supply Chain (Compact Model)

Each stage has distinct risks and controls.

**Integrity** addresses whether an artefact was tampered with, and the controls are checksums and signatures. **Authenticity** addresses who published the artefact, and the controls are identity verification and trusted publisher lists. **Provenance** addresses how an artefact was built, and the controls are attestations, software bills of materials (SBOM), and reproducible build metadata. **Capability safety** addresses what an artefact can do, and the controls are least privilege, sandboxing, and constrained outputs.

The control mapping by stage is as follows. **Discovery controls** include allowlists of domains and registries. **Import and install controls** include pinning plus checksum and signature verification. **Activation controls** include permission gates, scoped credentials, and sandbox profiles. **Runtime controls** include audit logs, safe outputs, and policy evaluation traces.

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

In this example, `shared/common-tools.md` is a **workflow-fragment artefact**. The `imports` directive is the **import** operation. A separate policy decides whether imported tools are **activated** at runtime.

### Example B: AGENTS.md import conventions as resolution policy

```markdown
## Import Conventions
- Prefer absolute imports from `src/`
- Group imports: stdlib, third-party, local
- Use `@/` alias for `src/`
```

This example does **not** install dependencies. It standardises **import resolution behaviour** so agents generate consistent code. Activation still depends on tool and runtime permissions.

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

In this example, discovery scope is constrained first by the allowed domains and registries. Import and install are pinned and integrity-checked via the pinned versions and checksums. High-impact capabilities require explicit activation approval through the activation gates.

## Key Takeaways

Treat **artefact**, **discovery**, **import**, **install**, and **activate** as distinct terms with precise meanings. Discovering a tool endpoint is not the same as activating its capabilities—each stage requires different security controls. Use taxonomy-first language: tool, skill, agent, and workflow fragment are different artefact types with different identity and interface properties.

Prefer explicit, pinned configuration when provenance or authenticity is uncertain; the convenience of dynamic discovery is not worth the security risk. Apply controls by stage: allowlist at discovery, verify at import and install, and enforce least privilege at activation and runtime.

For tool and skill design conventions, see [Skills and Tools Management](040-skills-tools.md). For GH-AW composition syntax, see [GitHub Agentic Workflows (GH-AW)](060-gh-agentic-workflows.md).

<!-- Edit notes:
Sections expanded: Chapter Preview, Terminology Baseline for the Rest of the Book, all four artefact type subsections (Tool, Skill, Agent, Workflow-fragment), Confusing cases to stop using, all four Discovery Mechanisms subsections (Local scan, Registry, Domain-convention, Explicit configuration), Import/Install/Activate (all three subsections), Trust Boundaries and Supply Chain, all three Worked Examples interpretations, Key Takeaways
Lists preserved: Worked Examples code blocks (must remain as-is for clarity)
Ambiguous phrases left ambiguous: None identified
-->
