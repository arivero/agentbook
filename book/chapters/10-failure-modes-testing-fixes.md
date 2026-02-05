---
title: "Common Failure Modes, Testing, and Fixes"
order: 10
---

# Common Failure Modes, Testing, and Fixes

## Chapter Goals

By the end of this chapter, you should be able to:

- Recognize the most common ways agentic workflows fail in production.
- Design a test strategy that catches failures before deployment.
- Apply practical mitigation and recovery patterns.
- Turn incidents into durable process and architecture improvements.

## Why Failures Are Different in Agentic Systems

Traditional software failures are often deterministic and reproducible. Agent failures can also include:

- **Nondeterminism** from model sampling and external context.
- **Tool and API variance** across environments and versions.
- **Instruction ambiguity** when prompts, policy files, or skills conflict.
- **Long-horizon drift** where behavior degrades over many steps.

This means reliability work must combine classic software testing with scenario-based evaluation and operational controls.

## Failure Taxonomy

Use this taxonomy to classify incidents quickly and choose the right fix path.

### 1) Planning and Reasoning Failures

Symptoms:

- Agent picks the wrong sub-goal.
- Repeats work or loops without convergence.
- Produces plausible but invalid conclusions.

Typical causes:

- Missing constraints in system instructions.
- Overly broad tasks with no decomposition guardrails.
- No termination criteria.

Fast fixes:

- Add explicit success criteria and stop conditions.
- Break tasks into bounded steps.
- Require intermediate checks before irreversible actions.

### 2) Tooling and Integration Failures

Symptoms:

- Tool calls fail intermittently.
- Wrong parameters passed to tools.
- Tool output parsed incorrectly.

Typical causes:

- Schema drift or undocumented API changes.
- Weak input validation.
- Inconsistent retry/backoff handling.

Fast fixes:

- Validate tool contracts at runtime.
- Add strict argument schemas.
- Standardize retries with idempotency keys.

### 3) Context and Memory Failures

Symptoms:

- Agent forgets prior constraints.
- Important instructions are dropped when context grows.
- Stale memories override fresh data.

Typical causes:

- Context window pressure.
- Poor memory ranking/retrieval.
- Missing recency and source-quality weighting.

Fast fixes:

- Introduce context budgets and summarization checkpoints.
- Add citation requirements for retrieved facts.
- Expire or down-rank stale memory entries.

### 4) Safety and Policy Failures

Symptoms:

- Sensitive files modified unexpectedly.
- Security constraints bypassed through tool chains.
- Unsafe suggestions in generated code.

Typical causes:

- Weak policy enforcement boundaries.
- No pre-merge policy gates.
- Implicit trust in generated output.

Fast fixes:

- Enforce allow/deny lists at tool gateway level.
- Require policy checks in CI.
- Route high-risk actions through human approval.

### 5) Collaboration and Workflow Failures

Symptoms:

- Multiple agents make conflicting changes.
- PRs churn with contradictory edits.
- Work stalls due to unclear ownership.

Typical causes:

- Missing orchestration contracts.
- No lock/lease model for shared resources.
- Role overlap without clear handoff rules.

Fast fixes:

- Add ownership rules per path/component.
- Use optimistic locking with conflict resolution policy.
- Define role-specific done criteria.

## Testing Strategy for Agentic Workflows

A robust strategy uses multiple test layers. No single test type is sufficient.

## 1. Static and Structural Checks

Use these to fail fast before expensive model execution:

- Markdown/schema validation for instruction files.
- Prompt template linting.
- Tool interface compatibility checks.
- Dependency and version constraint checks.

## 2. Deterministic Unit Tests (Without LLM Calls)

Test orchestration logic, parsers, and guards deterministically:

- State transitions.
- Retry and timeout behavior.
- Permission checks.
- Conflict resolution rules.

> **Snippet status:** Runnable shape (simplified for clarity).

```python
from dataclasses import dataclass

@dataclass
class StepResult:
    ok: bool
    retryable: bool


def should_retry(result: StepResult, attempt: int, max_attempts: int = 3) -> bool:
    return (not result.ok) and result.retryable and attempt < max_attempts


def test_retry_policy():
    assert should_retry(StepResult(ok=False, retryable=True), attempt=1)
    assert not should_retry(StepResult(ok=False, retryable=False), attempt=1)
    assert not should_retry(StepResult(ok=False, retryable=True), attempt=3)
```

## 3. Recorded Integration Tests (Golden Traces)

Capture representative interactions and replay them against newer builds:

- Record tool inputs/outputs.
- Freeze external dependencies where possible.
- Compare final artifacts and decision traces.

Use these to detect drift in behavior after prompt/tool/model changes.

## 4. Scenario and Adversarial Evaluations

Design "challenge suites" for known weak spots:

- Ambiguous requirements.
- Contradictory documentation.
- Missing dependencies.
- Partial outages and degraded APIs.
- Prompt-injection attempts in retrieved content.

Pass criteria should include not just correctness, but also:

- Policy compliance.
- Cost/latency ceilings.
- Evidence quality (citations, rationale quality).

## 5. Production Guardrail Tests

Before enabling autonomous writes/merges in production, validate:

- Protected-path enforcement.
- Secret scanning and license checks.
- Human approval routing for high-impact actions.
- Rollback path on failed deployments.

## Practical Fix Patterns

When incidents happen, reusable fix patterns reduce MTTR (mean time to recovery).

### Pattern A: Contract Hardening

- Add strict schemas between planner and tool runner.
- Reject malformed or out-of-policy requests early.
- Version contracts (`v1`, `v2`) and support migrations.

### Pattern B: Progressive Autonomy

- Start in "suggest-only" mode.
- Move to "execute with review" mode.
- Graduate to autonomous mode only after SLO compliance.

### Pattern C: Two-Phase Execution

1. **Plan phase**: generate proposed actions and expected effects.
2. **Apply phase**: execute only after policy and validation checks pass.

This reduces irreversible mistakes and improves auditability.

### Pattern D: Fallback and Circuit Breakers

- If tool failure rate spikes, disable affected paths automatically.
- Fall back to a safer baseline workflow.
- Alert operators with incident context.

### Pattern E: Human-in-the-Loop Escalation

Define explicit escalation triggers:

- Repeated retries without progress.
- Any request touching protected paths.
- Low-confidence output in high-risk domains.

## Incident Response Runbook (Template)

Use a lightweight runbook so teams respond consistently:

1. **Detect**: Alert from CI, runtime monitor, or user report.
2. **Classify**: Map to taxonomy category.
3. **Contain**: Stop autonomous actions if blast radius is unclear.
4. **Diagnose**: Reproduce with trace + config snapshot.
5. **Mitigate**: Apply short-term guardrails/fallback.
6. **Fix**: Implement structural correction.
7. **Verify**: Re-run affected test suites + adversarial cases.
8. **Learn**: Add regression test and update docs.

## Metrics That Actually Matter

Track these to evaluate reliability improvements over time:

- **Task success rate** (with policy compliance as part of success).
- **Intervention rate** (how often humans must correct the agent).
- **Escaped defect rate** (failures discovered after merge/deploy).
- **Mean time to detect (MTTD)** and **mean time to recover (MTTR)**.
- **Cost per successful task** and **latency percentiles**.

Avoid vanity metrics (for example, "number of agent runs") without quality and safety context.

## Anti-Patterns to Avoid

- Treating prompt edits as sufficient reliability work.
- Allowing autonomous writes without protected-path policies.
- Skipping regression suites after model/version upgrades.
- Relying on a single benchmark instead of diverse scenarios.
- Ignoring ambiguous ownership in multi-agent flows.

## A Minimal Reliability Checklist

Before enabling broad production use, confirm:

- [ ] Snippets and examples are clearly labeled (runnable/pseudocode/simplified).
- [ ] Tool contracts are versioned and validated.
- [ ] CI includes policy, security, and regression checks.
- [ ] Failure injection scenarios are part of routine testing.
- [ ] Rollback and escalation paths are documented and exercised.

## Chapter Summary

Reliable agentic systems are built, not assumed. Teams that combine:

- clear contracts,
- layered testing,
- progressive autonomy,
- strong policy gates, and
- incident-driven learning

consistently outperform teams relying on prompt-only tuning.

In practice, your competitive advantage comes from how quickly you detect, contain, and permanently fix failures—not from avoiding them entirely.
