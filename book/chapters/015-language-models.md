---
title: "Language Models"
order: 1.5
---

# Language Models

## Chapter Preview

This chapter explains how to choose language models for agentic workflows using the same practical lens as the rest of the book. We focus on model classes that are actually used in the frameworks covered in later chapters, rather than trying to survey the whole market. We also discuss what control surfaces those frameworks expose, including runtime parameters, execution constraints, and where batch-style execution is realistic.

## Model Classes Used in This Book

In this book, it is useful to think about three deployment classes rather than vendor marketing categories. The first class is **private hosted models**, where inference runs on infrastructure operated by a provider and you access it through a managed API. The second is **open-source local models**, where weights are run inside your own environment, often through Ollama or another local serving layer. The third is **open-source networked models**, where open-weight models are still remote but hosted by an external endpoint you call over the network.

These three classes show up repeatedly in the frameworks discussed later: GH-AW engines such as Copilot, Codex (currently GPT-5.3-Codex, released February 2026), and Claude Code are provider-hosted; LangChain-style orchestration can target both hosted and self-hosted backends; and OpenClaw-style stacks explicitly support OpenAI, Anthropic, and local Ollama execution. Treat this chapter as the compatibility map that makes those later choices easier.

## Private Hosted Models

Private hosted models are the default path for most teams starting with agentic workflows. In the chapters that follow, this includes model families surfaced by engines like Copilot, Codex, and Claude Code in GitHub-centric automation, and the managed APIs commonly wired into LangChain, the Microsoft Agent Framework (the convergence of Semantic Kernel and AutoGen), and CrewAI examples.

The main advantage is operational simplicity. You usually get strong baseline reasoning performance, tool-calling support, streaming responses, and mature auth/rate-limit controls without running inference infrastructure yourself. This is why private hosted models tend to dominate early production rollouts in orchestration-heavy systems.

The tradeoff is that control is indirect. You can tune behavior through API parameters, but you cannot usually alter model internals or deployment topology. Data governance and region constraints also depend on provider features, which matters when workflows touch sensitive repositories or regulated domains.

## Open-Source Local Models

Open-source local models are central when teams need stricter data locality, predictable cost envelopes, or offline-capable development workflows. In this book's framework set, this mode appears most explicitly where local models are served through Ollama and then consumed by agent runtimes that abstract over providers.

Local execution gives you direct control over model versioning, hardware placement, and retention boundaries. That makes incident review and reproducibility easier: you can pin the exact model artifact and inference stack used by a workflow run. It also allows experimentation with task-specific tradeoffs, such as smaller fast models for routing and larger reasoning models for synthesis.

The main limitation is operational burden. You own capacity planning, latency tuning, model upgrades, and serving reliability. For orchestration systems, that means your agent architecture and your inference architecture become coupled, so rollout discipline matters more.

## Open-Source Networked Models

Open-source networked models sit between the previous two classes. The weights are open, but inference runs on remote infrastructure. This pattern is common when teams want model transparency and vendor optionality without operating local GPU capacity.

For the frameworks in later chapters, this mode is typically consumed through the same adapter layers used for private hosted APIs. In practice, that means your orchestration code can remain mostly stable while swapping endpoint providers, provided the framework supports the target protocol and tool-calling semantics you rely on.

The key risk is compatibility drift. Two providers may host nominally the same open model but differ in tokenizer revisions, tool-call formatting, context limits, or rate-limit behavior. In agentic systems with retries and delegation, those small differences can create large behavioural variance.

## Framework Boundaries and What They Actually Let You Control

Across the frameworks covered later in the book, control over LLM behavior is uneven and should be treated as part of framework selection, not an afterthought. GH-AW's markdown-first model is deliberately opinionated: you choose an engine and constrain permissions/tools, but low-level sampling controls are not always the central UX. This is a strength for reproducible repository automation, but it is less suitable when you need fine-grained prompt-time parameter sweeps.

General orchestration frameworks such as LangChain, the Microsoft Agent Framework (formerly Semantic Kernel and AutoGen, now converging), and CrewAI typically expose richer per-call controls. You can usually set model identity, temperature-like randomness controls, token ceilings, and sometimes provider-specific reasoning or tool-choice options. They are better suited for multi-stage pipelines where planner and executor agents need different inference profiles.

OpenClaw-like runtime designs (as described later) are useful when you need a multi-provider abstraction that can route between hosted APIs and local Ollama backends. In these setups, the practical control plane is often split: framework-level policy chooses which backend to call, while backend-specific adapters decide which parameters are truly supported.

## Parameters, Batch Mode, and Throughput Strategy

Most teams think first about temperature and max token settings, but in agentic workflows the higher-impact controls are often budget and scheduling controls: timeout ceilings, retry policies, concurrency limits, and explicit tool-use constraints. These controls usually reduce failure cost more than aggressive sampling tuning.

Batch mode exists in several forms and should be interpreted carefully. Some providers offer true asynchronous batch APIs for large offline workloads. Some frameworks provide logical batching by grouping prompts in one process even when requests are still executed as standard calls. And in GitHub workflow contexts, "batch" often means matrix or queue-based orchestration around many agent invocations rather than a single native LLM batch job.

The practical guidance for this book's framework set is straightforward: use provider-native batch only for high-volume, latency-insensitive jobs; use framework-level parallelism for repository-scale fan-out tasks; and keep online review/merge loops on low-latency interactive paths.

## Choosing a Model Class for Agentic Workflows

If your primary goal is fastest path to reliable automation, private hosted models are usually the best default for the frameworks in this book. If your primary constraint is data residency or fixed-cost operation, prefer open-source local models and design orchestration around resource awareness from day one. If your goal is flexibility and reduced lock-in with less infra ownership, open-source networked models are often the middle path.

In all three cases, pick models only after deciding orchestration pattern, tool boundaries, and validation strategy. Agent quality depends as much on execution design as on the base model itself, and later chapters show that failure handling and testing discipline often dominate raw model benchmark differences.
