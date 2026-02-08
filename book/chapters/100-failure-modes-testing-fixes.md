---
title: "Common Failure Modes, Testing, and Fixes"
order: 10
---

# Common Failure Modes, Testing, and Fixes

## Chapter Goals

By the end of this chapter, you should be able to recognise the most common ways agentic workflows fail in production, understanding the symptoms and root causes of each failure mode. You should be able to design a test strategy that catches failures before deployment, combining static checks, deterministic tests, and adversarial evaluations. You should be able to apply practical mitigation and recovery patterns that reduce mean time to recovery when failures occur. And you should be able to turn incidents into durable process and architecture improvements that prevent recurrence.

## Why Failures Are Different in Agentic Systems

Traditional software failures are often deterministic and reproducible. Agent failures can also include additional dimensions of complexity.

**Nondeterminism** arises from model sampling and external context, meaning the same input may produce different outputs across runs.

**Tool and API variance** occurs across environments and versions, where a tool that works in testing may behave differently in production.

**Instruction ambiguity** emerges when prompts, policy files, or skills conflict, leading agents to interpret guidance inconsistently.

**Long-horizon drift** describes behaviour that degrades over many steps, where small errors compound into significant deviations from intended outcomes.

This means reliability work must combine classic software testing with scenario-based evaluation and operational controls.

## Failure Taxonomy

Use this taxonomy to classify incidents quickly and choose the right fix path.

### 1) Planning and Reasoning Failures

**Symptoms.** The agent picks the wrong sub-goal, pursuing an objective that does not advance the overall task. It repeats work or loops without convergence, wasting resources on redundant operations. It produces plausible but invalid conclusions, generating output that sounds correct but fails validation.

**Typical causes.** Missing constraints in system instructions leave the agent without guidance on what to avoid. Overly broad tasks with no decomposition guardrails allow the agent to wander. No termination criteria means the agent does not know when to stop.

**Fast fixes.** Add explicit success criteria and stop conditions so the agent knows when it has succeeded. Break tasks into bounded steps that can be validated individually. Require intermediate checks before irreversible actions to catch errors early.

### 2) Tooling and Integration Failures

**Symptoms.** Tool calls fail intermittently, succeeding sometimes and failing others without obvious cause. Wrong parameters are passed to tools, causing unexpected behaviour. Tool output is parsed incorrectly, leading to downstream errors.

**Typical causes.** Schema drift or undocumented API changes mean the agent's assumptions no longer match reality. Weak input validation allows malformed requests to reach tools. Inconsistent retry and backoff handling causes cascading failures under load.

**Fast fixes.** Validate tool contracts at runtime to catch mismatches early. Add strict argument schemas that reject invalid inputs. Standardise retries with idempotency keys so repeated attempts are safe.

### 3) Context and Memory Failures

**Symptoms.** The agent forgets prior constraints, violating rules it was given earlier in the conversation. Important instructions are dropped when context grows, as the agent summarises away critical guidance. Stale memories override fresh data, causing the agent to act on outdated information.

**Typical causes.** Context window pressure forces the agent to discard information. Poor memory ranking and retrieval surfaces irrelevant content while burying important details. Missing recency and source-quality weighting treats all information as equally valid.

**Fast fixes.** Introduce context budgets and summarisation checkpoints that preserve critical information. Add citation requirements for retrieved facts so sources are traceable. Expire or down-rank stale memory entries so fresh information takes precedence.

### 4) Safety and Policy Failures

**Symptoms.** Sensitive files are modified unexpectedly, violating protected path policies. Security constraints are bypassed through tool chains, where combining multiple tools achieves an outcome that individual tools would block. Unsafe suggestions appear in generated code, introducing vulnerabilities.

**Typical causes.** Weak policy enforcement boundaries do not cover all attack surfaces. No pre-merge policy gates allow unsafe changes to reach the main branch. Implicit trust in generated output assumes agent output is safe without verification.

**Fast fixes.** Enforce allow and deny lists at the tool gateway level to prevent prohibited operations. Require policy checks in CI so violations are caught before merge. Route high-risk actions through human approval to ensure oversight.

### 5) Collaboration and Workflow Failures

**Symptoms.** Multiple agents make conflicting changes, overwriting each other's work. PRs churn with contradictory edits as agents undo each other's modifications. Work stalls due to unclear ownership, with no agent taking responsibility.

**Typical causes.** Missing orchestration contracts leave agents without coordination rules. No lock or lease model for shared resources allows concurrent modification. Role overlap without clear handoff rules creates ambiguity about who should act.

**Fast fixes.** Add ownership rules per path or component so responsibilities are clear. Use optimistic locking with conflict resolution policy to handle concurrent access. Define role-specific done criteria so agents know when to stop.

## Testing Strategy for Agentic Workflows

A robust strategy uses multiple test layers. No single test type is sufficient.

## 1. Static and Structural Checks

Use static and structural checks to fail fast before expensive model execution. These include markdown and schema validation for instruction files, ensuring they are well-formed before agents try to parse them. Prompt template linting catches common errors in prompt construction. Tool interface compatibility checks verify that agents can call the tools they expect. Dependency and version constraint checks ensure the environment matches expectations.

## 2. Deterministic Unit Tests (Without LLM Calls)

Test orchestration logic, parsers, and guards deterministically without involving language models. Cover state transitions to ensure the workflow moves through stages correctly. Test retry and timeout behaviour to verify failure handling works as expected. Verify permission checks to ensure access controls are enforced. Test conflict resolution rules to confirm agents handle concurrent access correctly.

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

Capture representative interactions and replay them against newer builds. Record tool inputs and outputs to create a reproducible baseline. Freeze external dependencies where possible to eliminate variance. Compare final artefacts and decision traces to detect changes in behaviour.

Use these to detect drift in behaviour after prompt, tool, or model changes.

## 4. Scenario and Adversarial Evaluations

Design "challenge suites" for known weak spots. These should include ambiguous requirements that could be interpreted multiple ways, contradictory documentation that forces the agent to choose, missing dependencies that test error handling, and partial outages and degraded APIs that test resilience. Include prompt-injection attempts in retrieved content to test security boundaries.

Pass criteria should include not just correctness, but also policy compliance, cost and latency ceilings, and evidence quality including citations and rationale.

## 5. Production Guardrail Tests

Before enabling autonomous writes and merges in production, validate that guardrails work correctly. Protected-path enforcement should block modifications to sensitive files. Secret scanning and licence checks should catch policy violations. Human approval routing should engage for high-impact actions. Rollback paths should work on failed deployments.

## Practical Fix Patterns

When incidents happen, reusable fix patterns reduce MTTR (mean time to recovery).

### Pattern A: Contract Hardening

Add strict schemas between planner and tool runner to ensure they communicate correctly. Reject malformed or out-of-policy requests early, before they can cause harm. Version contracts (`v1`, `v2`) and support migrations so changes can be rolled out incrementally.

### Pattern B: Progressive Autonomy

Start in "suggest-only" mode where agents propose changes but do not execute them. Move to "execute with review" mode once confidence builds. Graduate to autonomous mode only after SLO compliance demonstrates the agent is reliable.

### Pattern C: Two-Phase Execution

In the **plan phase**, generate proposed actions and expected effects without executing anything. In the **apply phase**, execute only after policy and validation checks pass. This reduces irreversible mistakes and improves auditability.

### Pattern D: Fallback and Circuit Breakers

If tool failure rate spikes, disable affected paths automatically to prevent cascading failures. Fall back to a safer baseline workflow that may be less capable but more reliable. Alert operators with incident context so they can investigate and resolve the underlying issue.

### Pattern E: Human-in-the-Loop Escalation

Define explicit escalation triggers that route work to humans. Repeated retries without progress indicate the agent is stuck. Any request touching protected paths should require approval. Low-confidence output in high-risk domains warrants human review.

## Incident Response Runbook (Template)

Use a lightweight runbook so teams respond consistently. The sequence proceeds through eight steps.

**Detect.** Receive an alert from CI, runtime monitor, or user report indicating something has gone wrong.

**Classify.** Map the incident to a taxonomy category so you can apply the appropriate response playbook.

**Contain.** Stop autonomous actions if the blast radius is unclear, preventing further damage while you investigate.

**Diagnose.** Reproduce the issue with a trace and configuration snapshot to understand what happened.

**Mitigate.** Apply short-term guardrails or fallbacks to restore service while you work on a permanent fix.

**Fix.** Implement a structural correction that addresses the root cause.

**Verify.** Re-run affected test suites and adversarial cases to confirm the fix works.

**Learn.** Add a regression test and update documentation to prevent recurrence.

## Uncertainty Quantification for Agent Reliability

Reliable agents must know when they don't know. Uncertainty quantification (UQ) provides a principled framework for agents to express confidence in their outputs and decisions, enabling safer deployment in high-stakes environments.

### Single-Turn vs. Multi-Turn Uncertainty

Traditional uncertainty quantification research focuses on single-turn question-answering scenarios, where an agent receives a query and produces an answer. In these settings, uncertainty accumulates: each reasoning step adds more uncertainty, and the final confidence is the compound of all intermediate uncertainties.

Interactive agents work differently. Through tool use, multi-turn dialogue, and environmental feedback, agents actively reduce uncertainty as they progress. A code-writing agent may start with high uncertainty about requirements, then clarify them through conversation. A data analysis agent may begin uncertain about data quality, then validate it through sanity checks. This is a *conditional uncertainty reduction process*, where uncertainty changes based on what the agent learns through interaction.

Oh et al. (2026) present the first general formulation of uncertainty quantification for interactive LLM agents, explicitly modeling how agents reduce uncertainty through action. Their framework shifts the focus from accumulation to reduction: `P(correct | history, action)` captures how each action changes the agent's epistemic state. This perspective is critical for realistic agentic workflows, where agents don't just answer questions—they explore, experiment, and adapt.

### Reducible and Irreducible Uncertainty

Not all uncertainty can be eliminated through interaction. Understanding the distinction between *reducible* and *irreducible* uncertainty helps agents decide when to act autonomously versus when to escalate.

**Reducible uncertainty** can be addressed through interaction:
- Missing data: An agent can call a retrieval tool or query an API to obtain the information
- Ambiguous requirements: The agent can ask clarifying questions to resolve ambiguity
- Unverified assumptions: The agent can run tests or simulations to validate hypotheses
- Environmental unknowns: The agent can probe the system state through observations

**Irreducible uncertainty** is fundamental to the problem domain:
- Inherent randomness in the environment (weather, user behaviour, network latency)
- Incomplete information that no tool can provide (future events, hidden state)
- Computational intractability (NP-hard problems without approximation guarantees)
- Model limitations (knowledge cutoff dates, training data gaps)

This distinction has practical implications for agent design. When facing reducible uncertainty, agents should actively seek information. When facing irreducible uncertainty, agents should express confidence bounds and consider escalation.

> **Snippet status:** Runnable shape (extends Chapter 90's UncertaintyAwareAgent pattern).

```python
class UQAgent:
    """Agent with uncertainty-aware decision gates"""
    
    def __init__(self, threshold_low=0.3, threshold_high=0.7):
        self.threshold_low = threshold_low    # Below this: definitely escalate
        self.threshold_high = threshold_high  # Above this: act autonomously
    
    async def execute_task(self, task, max_reduction_steps=3):
        confidence = await self.estimate_confidence(task)
        step = 0
        
        while confidence < self.threshold_high and step < max_reduction_steps:
            # Try to reduce uncertainty through interaction
            reducible = await self.identify_reducible_uncertainty(task)
            
            if not reducible:
                # Irreducible uncertainty remains
                break
            
            # Take action to reduce uncertainty
            await self.reduce_uncertainty(task, reducible)
            confidence = await self.estimate_confidence(task)
            step += 1
        
        # Decision gate based on final confidence
        if confidence >= self.threshold_high:
            return await self.execute_autonomously(task)
        elif confidence <= self.threshold_low:
            return await self.escalate_to_human(task, reason="low confidence")
        else:
            # Medium confidence: execute with review
            result = await self.execute_autonomously(task)
            return await self.request_human_review(result)
```

This pattern integrates uncertainty quantification directly into the agent's decision loop, making confidence thresholds explicit rather than implicit.

### Designing Safety Guardrails with UQ

Uncertainty quantification provides a principled foundation for the Human-in-the-Loop Escalation pattern (Pattern E above). Rather than relying on heuristics alone, UQ-based guardrails combine confidence metrics with task impact to determine when human oversight is required.

**Escalation triggers based on uncertainty:**
- **Low confidence + high impact**: Always escalate (e.g., deploying code to production with <50% confidence)
- **Low confidence + low impact**: Execute with logging (e.g., updating documentation with <50% confidence)
- **High confidence + high impact**: Execute with post-hoc review (e.g., deploying to production with >90% confidence, but flag for audit)
- **High confidence + low impact**: Fully autonomous (e.g., fixing typos with >90% confidence)

This approach extends the Progressive Autonomy pattern (Pattern B above). Agents start in "suggest-only" mode until they demonstrate reliable uncertainty estimates. Once calibrated—meaning their confidence scores match actual success rates—they can graduate to autonomous execution within defined confidence bounds.

**Integration with existing patterns:**
- **Contract Hardening (Pattern A)**: Include uncertainty bounds in tool schemas (`{"result": value, "confidence": 0.85}`)
- **Two-Phase Execution (Pattern C)**: In the plan phase, estimate uncertainty for each proposed action; in the apply phase, execute only actions above the confidence threshold
- **Fallback and Circuit Breakers (Pattern D)**: Trigger fallback workflows when average confidence drops below baseline

By making uncertainty explicit, teams can tune guardrails based on empirical evidence rather than intuition. Track the relationship between confidence scores and actual outcomes to calibrate thresholds over time.

## Metrics That Actually Matter

Track these metrics to evaluate reliability improvements over time.

**Task success rate** measures how often agents complete tasks correctly, with policy compliance as part of success. **Intervention rate** measures how often humans must correct the agent, indicating where automation falls short. **Escaped defect rate** measures failures discovered after merge or deploy, indicating gaps in pre-production testing. **Mean time to detect (MTTD)** and **mean time to recover (MTTR)** measure incident response effectiveness. **Cost per successful task** and **latency percentiles** measure efficiency.

Avoid vanity metrics (for example, "number of agent runs") without quality and safety context.

## Anti-Patterns to Avoid

Several anti-patterns undermine agentic system reliability.

**Treating prompt edits as sufficient reliability work** ignores the structural issues that cause failures. Prompts can only do so much; robust systems need architectural controls.

**Allowing autonomous writes without protected-path policies** exposes critical files to unintended modification. Every system needs explicit boundaries.

**Skipping regression suites after model or version upgrades** assumes backward compatibility that may not exist. Changes require validation.

**Relying on a single benchmark instead of diverse scenarios** creates blind spots. Real-world failures often occur in edge cases the benchmark does not cover.

**Ignoring ambiguous ownership in multi-agent flows** leads to gaps and conflicts. Every path and component should have a clear owner.

## A Minimal Reliability Checklist

Before enabling broad production use, confirm the following items are complete. Snippets and examples should be clearly labelled as runnable, pseudocode, or simplified. Tool contracts should be versioned and validated. CI should include policy, security, and regression checks. Failure injection scenarios should be part of routine testing. Rollback and escalation paths should be documented and exercised.

## Applying This to This Repository

For this repository, a minimal operational checklist is:

- Run `python3 scripts/check-links.py --root book --mode internal` for any `book/` content change.
- Keep `.github/workflows/*.md` and `.github/workflows/*.lock.yml` in sync when GH-AW source workflows change.
- Validate label lifecycle behavior against `WORKFLOW_PLAYBOOK.md` after workflow edits.
- Preserve least-privilege + `safe-outputs` patterns in GH-AW workflow frontmatter.
- Use a repository-scoped user token for safe-outputs writes when label events must trigger downstream workflows.
- Scope dispatch-workflow concurrency by issue identifier to prevent burst-trigger cancellations.
- Treat workflow-generated failure tracker issues as operations artifacts, not content suggestions.
- Validate lifecycle paths sequentially before burst/concurrency tests.
- Treat failed Pages/PDF runs as release blockers for documentation changes.

For orchestration context, see [Agent Orchestration](020-orchestration.md). For infrastructure boundaries, see [Agentic Scaffolding](030-scaffolding.md).

## Chapter Summary

Reliable agentic systems are built, not assumed. Teams that combine clear contracts, layered testing, progressive autonomy, strong policy gates, and incident-driven learning consistently outperform teams relying on prompt-only tuning.

In practice, your competitive advantage comes from how quickly you detect, contain, and permanently fix failures—not from avoiding them entirely.

<!-- Edit notes:
Sections expanded: Chapter Goals, Why Failures Are Different in Agentic Systems, all five failure taxonomy sections (Planning and Reasoning, Tooling and Integration, Context and Memory, Safety and Policy, Collaboration and Workflow), Static and Structural Checks, Deterministic Unit Tests, Recorded Integration Tests, Scenario and Adversarial Evaluations, Production Guardrail Tests, all five Pattern sections (Contract Hardening, Progressive Autonomy, Two-Phase Execution, Fallback and Circuit Breakers, Human-in-the-Loop Escalation), Incident Response Runbook, Metrics That Actually Matter, Anti-Patterns to Avoid, A Minimal Reliability Checklist, Chapter Summary
Lists preserved: Code block (must remain as-is for runnable example), checklist format for Minimal Reliability Checklist (intentionally kept as checklist for usability)
Ambiguous phrases left ambiguous: None identified
-->
