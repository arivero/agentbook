---
layout: post
title: "No-Man's-Land Failures in Agent Pipelines"
date: 2026-02-08
---

Today we hit a class of failures that are easy to misdiagnose: not prompt bugs, not repository logic bugs, and not deterministic workflow bugs. They happen in the integration gap between GitHub APIs, hosted runner networking, and third-party artifact delivery.

## What Happened

We observed two concrete patterns:

- **Dispatch returned HTTP 500 but still started downstream.**  
  An intake workflow failed on `gh workflow run ...` with a server error, yet the routing workflow actually started and completed. The upstream run looked failed while the pipeline still moved forward.

- **Phase execution failed during tool install with HTTP 502.**  
  A phase run failed while installing GitHub Copilot CLI because the release asset download returned `502`. A rerun succeeded without workflow changes.

These are classic "no-man's-land" failures: infrastructure or platform edge conditions where control-plane state and CLI/API responses can briefly disagree.

## Why This Matters

If you treat every failure as deterministic logic failure, you waste time debugging the wrong layer. In multi-stage agent pipelines, transient infra errors can also block the next phase even when issue state is otherwise correct.

## Practical Response

- Treat `5xx` in dispatch/install steps as potentially transient.
- Keep dispatchers idempotent so reruns are safe.
- Verify downstream run creation separately before assuming dispatch really failed.
- Leave clear issue comments with run links so humans can quickly distinguish logic failures from platform flakiness.

## Hardening to Avoid Heavy Deploy Paths

Transient failures are unavoidable, but expensive execution can be reduced with better workflow boundaries.

- Put **label/state eligibility gates first**, before token checks, model checks, CLI installs, or container startup.
- Treat comment-triggered workflows as **untrusted entry points** and short-circuit early unless lifecycle labels and issue state are valid.
- Keep heavy agent phases behind explicit dispatch from validated dispatcher jobs, not directly from broad events.
- Record gating decisions in lightweight comments so operators can tell "blocked by policy" from "failed during execution."

Agentic systems are only as reliable as their orchestration edges. "No-man's-land" failures are normal in production; what matters is designing the workflow so they are recoverable.
