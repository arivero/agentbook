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

Traditional uncertainty quantification (UQ) research has focused on single-turn question-answering scenarios, where an LLM produces one response and uncertainty is measured on that output alone. This approach treats uncertainty as static—something to be estimated after the fact. But agentic workflows operate fundamentally differently: agents interact with tools, query external systems, and engage in multi-turn dialogue where each action can reduce uncertainty by gathering new information.

### Single-Turn vs. Multi-Turn Uncertainty

In single-turn settings, uncertainty quantification measures how confident a model is in its answer to a standalone question. The model has access only to its training data and the immediate prompt context. Uncertainty accumulates from model limitations, ambiguous phrasing, and missing information.

Agentic workflows change this dynamic. When an agent encounters uncertainty, it can take action: call a search API to retrieve missing facts, invoke a calculator to verify a computation, or ask a clarifying question in a multi-turn conversation. Each interaction potentially reduces uncertainty by adding information the agent lacked before.

Recent work by Oh et al. (2026) introduces a framework that models this as **conditional uncertainty reduction** rather than accumulation. The key insight is that uncertainty in multi-turn settings is conditional on the agent's history of actions and observations. An agent facing an ambiguous requirement should have high uncertainty initially, but after asking a clarifying question and receiving a response, uncertainty should decrease for that specific aspect of the task.

This perspective shifts how we think about agent reliability: instead of asking "how certain is the model?" we ask "how much can the agent reduce uncertainty through interaction?" Systems designed with this view can route high-uncertainty tasks through additional verification steps while allowing low-uncertainty tasks to proceed autonomously.

### Reducible and Irreducible Uncertainty

Not all uncertainty can be resolved through interaction. Understanding the distinction between **reducible** and **irreducible** uncertainty is essential for designing reliable agent systems.

**Reducible uncertainty** can be addressed through agent actions:
- **Missing data**: An agent writing a bug report realizes it does not know the software version. It can call a tool to retrieve this information.
- **Ambiguous requirements**: An agent implementing a feature is unsure whether "fast" means sub-100ms or sub-1s latency. It can ask a clarifying question.
- **Incomplete context**: An agent reviewing code notices a function call but cannot find the function definition in the files provided. It can search the repository for the missing definition.

**Irreducible uncertainty** is fundamental to the problem domain:
- **Inherent randomness**: Predicting whether a specific user will click an ad involves genuine randomness in human behaviour that no amount of data can fully eliminate.
- **Unavailable information**: An agent asked to predict a merger outcome cannot access private board discussions or confidential financial data.
- **Computational intractability**: Some questions require solving NP-hard problems where even perfect information would not yield efficient exact solutions.

Mathematically, we can frame this distinction as comparing conditional probabilities: reducible uncertainty is the gap between P(correct | current\_information) and P(correct | optimal\_information), where "optimal" means all information the agent could acquire through tool use and interaction. Irreducible uncertainty is the remaining gap between P(correct | optimal\_information) and certainty.

For practical agent design, this distinction matters because reducible uncertainty calls for better tool integration and interaction design, while irreducible uncertainty calls for escalation policies and conservative decision thresholds. An agent should not waste resources trying to reduce irreducible uncertainty, and it should not proceed confidently when reducible uncertainty remains high.

> **Snippet status:** Runnable example pattern (demonstrates UQ-based decision gates).

```python
class UncertaintyAwareAgent:
    """Agent that uses uncertainty thresholds to make decisions"""

    def __init__(self, uncertainty_threshold=0.3, max_reduction_attempts=3):
        self.uncertainty_threshold = uncertainty_threshold
        self.max_reduction_attempts = max_reduction_attempts

    async def execute_task(self, task):
        """Execute task with uncertainty-based decision gates"""
        result = await self.initial_attempt(task)
        uncertainty = await self.estimate_uncertainty(result, task)

        # Try to reduce uncertainty through interaction
        attempts = 0
        while uncertainty > self.uncertainty_threshold and attempts < self.max_reduction_attempts:
            # Identify what information would reduce uncertainty
            missing_info = await self.identify_uncertainty_source(result, task)

            # Take action to acquire that information
            new_info = await self.acquire_information(missing_info)

            # Recompute with additional context
            result = await self.refine_with_context(result, new_info)
            uncertainty = await self.estimate_uncertainty(result, task)
            attempts += 1

        # Decision gate based on final uncertainty
        if uncertainty > self.uncertainty_threshold:
            return {'action': 'escalate', 'reason': 'irreducible_uncertainty',
                    'uncertainty': uncertainty, 'result': result}
        else:
            return {'action': 'proceed', 'uncertainty': uncertainty, 'result': result}

    async def estimate_uncertainty(self, result, task):
        """Estimate uncertainty in current result"""
        # Placeholder: real implementation would use model confidence scores,
        # semantic consistency checks, or ensemble disagreement
        return 0.2

    async def identify_uncertainty_source(self, result, task):
        """Identify what information is missing"""
        # Placeholder: real implementation would analyze result gaps
        return "version_info"

    async def acquire_information(self, info_type):
        """Use tools to acquire missing information"""
        # Placeholder: real implementation would call tools/APIs
        return {"version": "2.1.3"}
```

### Designing Safety Guardrails with UQ

Uncertainty quantification provides a principled foundation for safety guardrails. Rather than relying solely on heuristics like "block all access to /etc" or "require approval for PRs over 500 lines," UQ-based guardrails can adapt to task context.

**Integration with Progressive Autonomy** (Pattern B, earlier in this chapter): Start agents in suggest-only mode when uncertainty is high. As the agent successfully reduces uncertainty on similar tasks, graduate to autonomous execution. This pattern works because it directly tracks the reducible uncertainty: tasks where the agent consistently achieves low uncertainty become candidates for increased autonomy.

**Integration with Human-in-the-Loop Escalation** (Pattern E, earlier in this chapter): Define escalation triggers based on uncertainty thresholds rather than task properties alone. For example:
- If `uncertainty > 0.5` **and** `task_impact = "high"` → escalate to human review
- If `uncertainty < 0.2` → proceed autonomously even for high-impact tasks (the agent has demonstrated it can reduce uncertainty)
- If `attempts >= max_reduction_attempts` **and** `uncertainty > threshold` → escalate with "irreducible uncertainty" rationale

**Practical implementation**: Track uncertainty across multiple dimensions:
1. **Output correctness**: How confident is the model that its answer is correct?
2. **Task interpretation**: How certain is the agent that it has understood the requirement correctly?
3. **Tool reliability**: How confident is the agent that tool outputs are valid?
4. **Environmental assumptions**: How certain is the agent about the state of external systems?

When any dimension exceeds a threshold, route the task for additional verification. When all dimensions are below threshold, proceed with execution.

This approach moves beyond fixed rules to adaptive guardrails that respond to the specific characteristics of each task. It combines the model's intrinsic uncertainty signals with the agent's demonstrated ability to reduce uncertainty through interaction, producing more reliable and maintainable safety boundaries.

For more on multi-agent uncertainty propagation, see [Agent Orchestration](020-orchestration.md#uncertainty-propagation-in-multi-agent-systems).

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
