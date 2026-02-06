---
title: "Agents for Mathematics and Physics"
order: 9
---

# Agents for Mathematics and Physics

## Chapter Preview

This chapter identifies where formal methods and computer algebra system (CAS) tools fit in agent workflows, explaining how they complement neural approaches. It separates runnable tooling from conceptual pseudocode, providing clear labels so readers know what can be executed directly. Finally, it highlights verification pitfalls and how to avoid them, addressing the unique challenges of mathematical and scientific correctness.

> **Note:** Many examples in this chapter are illustrative pseudocode unless explicitly labeled as runnable, because formal tooling and CAS systems require environment-specific setup.

## Introduction

Mathematics and physics present unique challenges for AI agents. Unlike coding, where correctness can often be verified through tests, mathematical reasoning requires formal proof and physical models demand empirical validation. This chapter explores specialized agents for scientific domains, their architectures, and the scaffolding required to support rigorous reasoning.

## The Landscape of Scientific Agents

### Distinct Requirements

Scientific agents differ from coding agents in several key ways:

| Aspect | Coding Agents | Scientific Agents |
|--------|---------------|-------------------|
| **Verification** | Tests, linting | Formal proofs, experimental validation |
| **Precision** | Functional correctness | Mathematical rigor |
| **Output** | Source code | Theorems, proofs, equations |
| **Tools** | IDEs, compilers | Proof assistants, CAS, simulators |
| **Context** | Codebase | Theorems, papers, datasets |

### Categories of Scientific Agents

Scientific agents fall into five main categories.

**Theorem Proving Agents** construct formal proofs in systems like Lean (<https://lean-lang.org/learn/>), Coq (<https://coq.inria.fr/>), or Isabelle (<https://isabelle.in.tum.de/>), producing machine-verifiable derivations.

**Symbolic Computation Agents** work with computer algebra systems (CAS), manipulating mathematical expressions symbolically rather than numerically.

**Numerical Simulation Agents** set up and run physics simulations, handling the computational infrastructure for modelling physical systems.

**Research Assistants** search literature, summarise findings, and identify gaps, helping researchers navigate the vast body of published work.

**Educational Scaffolding Agents** help students learn mathematical and physical concepts, adapting explanations to the learner's level and addressing misconceptions.

## Theorem Proving Agents

### Formal Verification Background

Formal theorem proving ensures mathematical correctness through rigorous logical derivation. Unlike informal proofs in papers, formal proofs are machine-verifiable.

### Ax-Prover Architecture

> **Note:** Ax-Prover is a hypothetical composite example used to illustrate multi-agent theorem proving patterns.

```python
class AxProverAgent:
    """Multi-agent theorem proving architecture inspired by Ax-Prover"""
    
    def __init__(self, llm, proof_assistant):
        self.llm = llm
        self.proof_assistant = proof_assistant  # e.g., Lean, Coq
        self.strategy_agents = {
            'decomposition': DecompositionAgent(llm),
            'lemma_search': LemmaSearchAgent(llm),
            'tactic_selection': TacticSelectionAgent(llm),
            'creativity': CreativityAgent(llm)
        }
    
    async def prove(self, theorem: str) -> ProofResult:
        """Attempt to prove a theorem"""
        
        # 1. Formalize the statement
        formal_statement = await self.formalize(theorem)
        
        # 2. Decompose into subgoals
        subgoals = await self.strategy_agents['decomposition'].decompose(
            formal_statement
        )
        
        # 3. Search for relevant lemmas
        lemmas = await self.strategy_agents['lemma_search'].search(
            formal_statement, subgoals
        )
        
        # 4. Generate proof attempts
        proof_attempts = await self.generate_proof_attempts(
            formal_statement, subgoals, lemmas
        )
        
        # 5. Verify with proof assistant
        for attempt in proof_attempts:
            result = await self.proof_assistant.check(attempt)
            if result.verified:
                return ProofResult(success=True, proof=attempt)
        
        return ProofResult(success=False, partial_proofs=proof_attempts)
    
    async def formalize(self, natural_language: str) -> str:
        """Convert natural language to formal notation"""
        prompt = f"""
        Convert the following mathematical statement to formal Lean 4 syntax:
        
        Statement: {natural_language}
        
        Provide the formal statement only.
        """
        return await self.llm.generate(prompt)
```

### Integration with Proof Assistants

Agents connect to proof assistants through well-defined interfaces:

```python
class LeanProofAssistant:
    """Interface to Lean 4 proof assistant"""
    
    def __init__(self, project_path: str):
        self.project_path = project_path
        self.server = LeanServer(project_path)
    
    async def check(self, proof: str) -> VerificationResult:
        """Verify a proof in Lean"""
        
        # Write proof to file
        proof_file = self.write_proof(proof)
        
        # Run Lean verification
        result = await self.server.check_file(proof_file)
        
        return VerificationResult(
            verified=not result.has_errors,
            errors=result.errors,
            goals=result.remaining_goals
        )
    
    async def get_available_tactics(self, goal_state: str) -> list:
        """Get tactics applicable to current goal state"""
        return await self.server.suggest_tactics(goal_state)
    
    async def search_mathlib(self, query: str) -> list:
        """Search Mathlib for relevant lemmas"""
        return await self.server.library_search(query)
```

### Challenges in Theorem Proving

Theorem proving presents four main challenges.

**Search space explosion** means proofs can have many possible paths, and exploring all of them quickly becomes computationally infeasible.

**Creativity required** reflects that non-obvious proof strategies often lead to success, requiring agents to generate novel approaches rather than following templates.

**Formalisation gap** is the challenge of translating informal mathematical statements into the precise syntax required by proof assistants.

**Domain knowledge** recognises that deep mathematical understanding is needed to guide proof search effectively and choose appropriate lemmas.

## Symbolic Computation Agents

### Computer Algebra Systems

Symbolic computation agents work with systems like Mathematica, SymPy, or SageMath:

```python
class SymbolicComputationAgent:
    """Agent for symbolic mathematical computation"""
    
    def __init__(self, llm, cas_backend='sympy'):
        self.llm = llm
        self.cas = self.initialize_cas(cas_backend)
    
    async def solve(self, problem: str) -> Solution:
        """Solve a mathematical problem symbolically"""
        
        # 1. Parse the problem
        parsed = await self.parse_problem(problem)
        
        # 2. Identify the type of problem
        problem_type = await self.classify_problem(parsed)
        
        # 3. Select appropriate methods
        methods = self.get_methods(problem_type)
        
        # 4. Attempt solutions
        for method in methods:
            try:
                result = await self.apply_method(method, parsed)
                if result.is_valid:
                    return Solution(
                        answer=result.answer,
                        method=method,
                        steps=result.steps
                    )
            except ComputationError:
                continue
        
        return Solution(success=False, attempted_methods=methods)
    
    async def simplify(self, expression: str) -> str:
        """Simplify a mathematical expression"""
        
        # Convert to CAS format
        cas_expr = self.cas.parse(expression)
        
        # Apply simplification
        simplified = self.cas.simplify(cas_expr)
        
        # Convert back to readable format
        return self.cas.to_latex(simplified)
    
    async def compute_integral(self, integrand: str, variable: str, 
                                bounds: tuple = None) -> str:
        """Compute definite or indefinite integral"""
        
        expr = self.cas.parse(integrand)
        var = self.cas.symbol(variable)
        
        if bounds:
            result = self.cas.integrate(expr, (var, bounds[0], bounds[1]))
        else:
            result = self.cas.integrate(expr, var)
        
        return self.cas.to_latex(result)
```

### Combining Symbolic and Neural Approaches

Modern agents combine symbolic precision with neural flexibility:

```python
class HybridMathAgent:
    """Combine symbolic computation with LLM reasoning"""
    
    def __init__(self, llm, cas):
        self.llm = llm
        self.cas = cas
    
    async def solve_with_explanation(self, problem: str) -> dict:
        """Solve and explain a mathematical problem"""
        
        # 1. LLM plans the solution strategy
        strategy = await self.llm.generate(f"""
        Given this problem: {problem}
        
        Outline a step-by-step solution strategy.
        Identify which steps require symbolic computation.
        """)
        
        # 2. Parse strategy into executable steps
        steps = self.parse_strategy(strategy)
        
        # 3. Execute each step
        results = []
        for step in steps:
            if step.requires_symbolic:
                result = await self.cas_execute(step)
            else:
                result = await self.llm_execute(step)
            results.append(result)
        
        # 4. Compile final answer with explanation
        return {
            'answer': results[-1],
            'steps': results,
            'explanation': await self.generate_explanation(results)
        }
```

## Physics Simulation Agents

### Computational Physics Workflows

Physics agents orchestrate simulation workflows:

```python
class PhysicsSimulationAgent:
    """Agent for physics simulations"""
    
    def __init__(self, llm, simulators):
        self.llm = llm
        self.simulators = {
            'molecular_dynamics': MDSimulator(),
            'quantum': QMSimulator(),
            'classical': ClassicalSimulator(),
            'fluid': CFDSimulator()
        }
    
    async def run_simulation(self, description: str) -> SimulationResult:
        """Set up and run a physics simulation from natural language"""
        
        # 1. Understand the physical system
        system_spec = await self.understand_system(description)
        
        # 2. Select appropriate simulator
        simulator = self.select_simulator(system_spec)
        
        # 3. Generate simulation parameters
        params = await self.generate_parameters(system_spec)
        
        # 4. Validate physical consistency
        await self.validate_physics(params)
        
        # 5. Run simulation
        result = await simulator.run(params)
        
        # 6. Analyze results
        analysis = await self.analyze_results(result, system_spec)
        
        return SimulationResult(
            raw_data=result,
            analysis=analysis,
            visualizations=await self.generate_plots(result)
        )
    
    async def validate_physics(self, params: dict):
        """Ensure simulation parameters are physically consistent"""
        
        # Check conservation laws
        if not self.check_energy_conservation(params):
            raise PhysicsError("Energy conservation violated")
        
        # Check dimensional consistency
        if not self.check_dimensions(params):
            raise PhysicsError("Dimensional inconsistency")
        
        # Check boundary conditions
        if not self.check_boundaries(params):
            raise PhysicsError("Invalid boundary conditions")
```

### Quantum Physics Specialization

Quantum physics requires specialized handling:

```python
class QuantumPhysicsAgent:
    """Specialized agent for quantum mechanical problems"""
    
    def __init__(self, llm, qm_tools):
        self.llm = llm
        self.tools = qm_tools
    
    async def solve_schrodinger(self, system: str) -> dict:
        """Solve Schrödinger equation for a system"""
        
        # 1. Construct Hamiltonian
        hamiltonian = await self.construct_hamiltonian(system)
        
        # 2. Identify symmetries
        symmetries = await self.find_symmetries(hamiltonian)
        
        # 3. Choose solution method
        method = self.select_method(hamiltonian, symmetries)
        
        # 4. Solve
        if method == 'analytical':
            solution = await self.analytical_solve(hamiltonian)
        elif method == 'numerical':
            solution = await self.numerical_solve(hamiltonian)
        elif method == 'variational':
            solution = await self.variational_solve(hamiltonian)
        
        return {
            'eigenstates': solution.states,
            'eigenvalues': solution.energies,
            'method': method,
            'symmetries': symmetries
        }
    
    async def compute_observable(self, state, observable: str) -> complex:
        """Compute expectation value of an observable"""
        
        operator = await self.construct_operator(observable)
        return await self.tools.expectation_value(state, operator)
```

## Scaffolding for Scientific Agents

### Tool Integration Layer

Scientific agents need access to specialized tools:

```yaml
# Scientific agent tool configuration
tools:
  proof_assistants:
    lean4:
      path: /usr/local/bin/lean
      mathlib_path: ~/.elan/toolchains/leanprover--lean4---v4.3.0/lib/lean4/library
    coq:
      path: /usr/bin/coqc
      
  computer_algebra:
    sympy:
      module: sympy
    mathematica:
      path: /usr/local/bin/WolframScript
      
  simulators:
    molecular_dynamics:
      backend: lammps
      path: /usr/bin/lmp
    quantum:
      backend: qiskit
      
  visualization:
    matplotlib: true
    plotly: true
    manim: true
```

### Knowledge Base Integration

Scientific agents need access to mathematical knowledge:

```python
class MathematicalKnowledgeBase:
    """Knowledge base for mathematical agents"""
    
    def __init__(self):
        self.theorem_database = TheoremDatabase()
        self.formula_index = FormulaIndex()
        self.paper_embeddings = PaperEmbeddings()
    
    async def search_theorems(self, query: str) -> list:
        """Search for relevant theorems"""
        
        # Semantic search over theorem statements
        results = await self.theorem_database.semantic_search(query)
        
        # Include related lemmas and corollaries
        expanded = []
        for theorem in results:
            expanded.append(theorem)
            expanded.extend(await self.get_related(theorem))
        
        return expanded
    
    async def get_formula(self, name: str) -> Formula:
        """Retrieve a named formula"""
        return await self.formula_index.get(name)
    
    async def search_literature(self, topic: str) -> list:
        """Search mathematical literature"""
        
        # Search arXiv, Mathlib docs, textbooks
        papers = await self.paper_embeddings.search(topic)
        return papers
```

### Verification Pipeline

All scientific agent outputs should be verified:

```python
class ScientificVerificationPipeline:
    """Verify correctness of scientific agent outputs"""
    
    def __init__(self):
        self.proof_checker = ProofChecker()
        self.dimensional_analyzer = DimensionalAnalyzer()
        self.numerical_validator = NumericalValidator()
    
    async def verify(self, output: ScientificOutput) -> VerificationResult:
        """Verify scientific output for correctness"""
        
        checks = []
        
        # 1. Check formal proofs
        if output.has_proofs:
            proof_check = await self.proof_checker.verify(output.proofs)
            checks.append(('proofs', proof_check))
        
        # 2. Check dimensional consistency
        if output.has_equations:
            dim_check = await self.dimensional_analyzer.check(output.equations)
            checks.append(('dimensions', dim_check))
        
        # 3. Numerical validation
        if output.has_computations:
            num_check = await self.numerical_validator.validate(
                output.computations
            )
            checks.append(('numerical', num_check))
        
        # 4. Cross-check with known results
        known_check = await self.check_against_known(output)
        checks.append(('known_results', known_check))
        
        return VerificationResult(
            verified=all(c[1].passed for c in checks),
            checks=checks
        )
```

## Educational Scaffolding Agents

### Mathematics Education

AI agents are transforming mathematics education:

```python
class MathTutoringAgent:
    """Agent for mathematics education and tutoring"""
    
    def __init__(self, llm, level='undergraduate'):
        self.llm = llm
        self.level = level
        self.student_model = StudentModel()
    
    async def explain_concept(self, concept: str) -> str:
        """Explain a mathematical concept at appropriate level"""
        
        # Get student's current understanding
        background = await self.student_model.get_background()
        
        # Generate explanation
        explanation = await self.llm.generate(f"""
        Explain {concept} to a student with this background: {background}
        
        Level: {self.level}
        
        Include:
        - Intuitive explanation
        - Formal definition
        - Key examples
        - Common misconceptions
        - Connection to prior knowledge
        """)
        
        return explanation
    
    async def generate_problems(self, topic: str, count: int, 
                                 difficulty: str) -> list:
        """Generate practice problems with solutions"""
        
        problems = await self.llm.generate(f"""
        Generate {count} {difficulty} problems on {topic}.
        
        For each problem provide:
        1. Problem statement
        2. Hints (progressive)
        3. Complete solution
        4. Common errors to avoid
        """)
        
        return self.parse_problems(problems)
    
    async def provide_feedback(self, student_work: str, 
                                problem: str) -> Feedback:
        """Analyze student work and provide feedback"""
        
        analysis = await self.llm.generate(f"""
        Analyze this student's solution:
        
        Problem: {problem}
        Student work: {student_work}
        
        Provide:
        1. Is the final answer correct?
        2. Are the intermediate steps correct?
        3. What misconceptions are evident?
        4. Specific suggestions for improvement
        5. Encouragement and next steps
        """)
        
        return self.parse_feedback(analysis)
```

### Physics Education

Physics scaffolding addresses visualization challenges:

```python
class PhysicsEducationAgent:
    """Agent for physics education with visualization"""
    
    def __init__(self, llm, visualizer):
        self.llm = llm
        self.visualizer = visualizer
    
    async def explain_with_simulation(self, concept: str) -> dict:
        """Explain physics concept with interactive simulation"""
        
        # Generate explanation
        explanation = await self.explain_concept(concept)
        
        # Create visualization parameters
        viz_params = await self.generate_visualization_params(concept)
        
        # Generate simulation
        simulation = await self.visualizer.create_simulation(viz_params)
        
        # Create interactive exploration tasks
        tasks = await self.generate_exploration_tasks(concept)
        
        return {
            'explanation': explanation,
            'simulation': simulation,
            'exploration_tasks': tasks,
            'key_parameters': viz_params['adjustable']
        }
    
    async def analyze_misconception(self, student_statement: str) -> dict:
        """Identify and address physics misconceptions"""
        
        analysis = await self.llm.generate(f"""
        The student said: "{student_statement}"
        
        1. Identify any physics misconceptions
        2. Explain the correct physics
        3. Suggest experiments or simulations to demonstrate
        4. Provide an analogy that builds correct intuition
        """)
        
        return self.parse_misconception_analysis(analysis)
```

## Research Agent Workflows

### Literature Review Agents

Agents that assist with scientific literature:

```python
class LiteratureReviewAgent:
    """Agent for mathematical and physics literature review"""
    
    def __init__(self, llm, databases):
        self.llm = llm
        self.databases = {
            'arxiv': ArxivAPI(),
            'mathscinet': MathSciNetAPI(),
            'semantic_scholar': SemanticScholarAPI()
        }
    
    async def survey_topic(self, topic: str) -> Survey:
        """Create a survey of a research topic"""
        
        # 1. Search for relevant papers
        papers = await self.search_all_databases(topic)
        
        # 2. Cluster by approach/contribution
        clusters = await self.cluster_papers(papers)
        
        # 3. Identify key results
        key_results = await self.extract_key_results(papers)
        
        # 4. Find open problems
        open_problems = await self.identify_open_problems(papers)
        
        # 5. Generate survey
        survey = await self.generate_survey(
            clusters, key_results, open_problems
        )
        
        return survey
    
    async def find_related_work(self, paper_or_idea: str) -> list:
        """Find work related to a paper or research idea"""
        
        # Extract key concepts
        concepts = await self.extract_concepts(paper_or_idea)
        
        # Search for related papers
        related = []
        for concept in concepts:
            papers = await self.search_concept(concept)
            related.extend(papers)
        
        # Rank by relevance
        ranked = await self.rank_relevance(related, paper_or_idea)
        
        return ranked[:20]  # Top 20 most relevant
```

## The 2025–2026 Breakthrough in Mathematical Agents

The period from mid-2025 through early 2026 has seen an extraordinary acceleration in AI-powered mathematics. Multiple systems now solve competition-level problems that were out of reach just a year earlier, and several have begun producing genuinely novel mathematical results. This section surveys the landscape as it stands.

### Google DeepMind: AlphaProof, AlphaEvolve, and Aletheia

Google DeepMind has pursued a multi-pronged strategy for mathematical AI. **AlphaProof** (<https://deepmind.google/blog/ai-solves-imo-problems-at-silver-medal-level/>) couples a pre-trained language model with AlphaZero-style reinforcement learning to prove theorems in Lean. At the 2024 International Mathematical Olympiad (IMO) it achieved silver-medal performance (28 points, one short of gold), solving two algebra problems, one number theory problem, and the hardest problem in the competition—solved by only five human contestants. The work was subsequently published in *Nature*.

**AlphaEvolve** (<https://deepmind.google/blog/alphaevolve-a-gemini-powered-coding-agent-for-designing-advanced-algorithms/>) is an evolutionary coding agent powered by Gemini that discovers and optimises algorithms. Applied to over 50 open problems in analysis, geometry, combinatorics, and number theory, it improved upon previously best-known solutions in 20% of cases. One headline result was a faster algorithm for 4×4 matrix multiplication, breaking the 50-year-old record set by Strassen's algorithm. In collaboration with Terence Tao, the AlphaEvolve team demonstrated a closed AI-research loop on the finite-field Kakeya conjecture: AlphaEvolve discovered constructions, Gemini Deep Think verified the logic, and AlphaProof formalised the result in Lean.

**Aletheia** (<https://github.com/google-deepmind/superhuman/tree/main/aletheia>) is DeepMind's project applying Gemini to research-level mathematics. Its outputs include a generalisation of Erdős problem 1051, eigenweight computations for the Arithmetic Hirzebruch Proportionality Principle, and mathematical inputs to peer-reviewed papers on robust Markov chains and independence-set bounds. Five peer-reviewed publications with corresponding arXiv submissions have emerged from the project.

In November 2025, DeepMind launched the **AI for Math Initiative** (<https://blog.google/technology/google-deepmind/ai-for-math/>), partnering with Imperial College London, the Institute for Advanced Study, IHES, the Simons Institute at UC Berkeley, and India's Tata Institute of Fundamental Research. The latest Gemini model with Deep Think scored 35 points at IMO 2025—gold-medal level, solving five of six problems.

### Axiom Math and the AxiomProver

Axiom Math (<https://axiommath.ai/>) is a startup led by Morgan Prize winner Carina Hong and former Meta FAIR engineer Shubho Sengupta. It raised $64 million at a $300 million valuation to develop mathematical AI that not only solves problems but proposes new conjectures.

Their **AxiomProver** (<https://github.com/AxiomMath/putnam2025>) is an autonomous multi-agent ensemble theorem prover for Lean 4. At the 2025 Putnam Competition—the hardest college-level mathematics exam in North America—AxiomProver solved all 12 problems: 8 by the end of competition day, the remaining 4 in subsequent days. Problem A1 took 110 minutes and 7 million tokens, producing a 652-line proof with 23 theorems and 561 tactics. Problem B5, one of the hardest, required 354 minutes and 18 million tokens for a 1,495-line proof with 66 theorems and 1,967 tactics.

Beyond competition mathematics, AxiomProver has produced results on open problems. Mathematician Ken Ono used AxiomProver to complete a proof of the Chen–Gendron conjecture, and the system independently solved Fel's conjecture on syzygies.

### Harmonic's Aristotle

Harmonic (<https://harmonic.fun/>) raised $120 million to develop Aristotle, a theorem prover combining a 200B+ parameter transformer with Monte Carlo Graph Search and test-time training. Aristotle takes Lean theorems without proofs and returns machine-checked proofs, eliminating hallucination by construction—the Lean kernel verifies every step.

Aristotle achieved gold-medal performance at IMO 2025 (five of six problems) and 90% on the MiniF2F benchmark. Its most striking result was an autonomous proof of Erdős Problem #124, completed in six hours with zero human assistance. Lean verification of the resulting proof took one minute.

### Princeton's Goedel-Prover-V2

Goedel-Prover-V2 (<https://github.com/Goedel-LM/Goedel-Prover-V2>) is an open-source theorem prover from Princeton Language and Intelligence, with collaborators from Tsinghua, NVIDIA, Stanford, Meta FAIR, and others. Its flagship 32B model achieves 90.4% on MiniF2F in self-correction mode—a jump from the 60% achieved by the original Goedel-Prover just six months earlier. The smaller 8B model matches the performance of DeepSeek-Prover-V2-671B while being nearly 100 times smaller. Three key innovations drive the improvement: scaffolded data synthesis that generates problems of increasing difficulty, verifier-guided self-correction using Lean's compiler feedback, and model averaging across checkpoints.

### DeepSeek-Prover-V2

DeepSeek-Prover-V2 (<https://github.com/deepseek-ai/DeepSeek-Prover-V2>) uses recursive subgoal decomposition powered by DeepSeek-V3 to initialise reinforcement learning for formal theorem proving. The 671B model achieves 88.9% on MiniF2F-test and solves 49 problems from PutnamBench. Its successor, DeepSeekMath-V2, focuses on natural-language theorem proving with self-verification, scoring gold-level on IMO 2025 and a near-perfect 118/120 on Putnam 2024.

### Numina-Lean-Agent: Open-Source Agentic Proving

Numina-Lean-Agent (<https://github.com/project-numina/numina-lean-agent>) demonstrates that a general-purpose coding agent can serve as a formal mathematics reasoner. Built on Claude Code with the Model Context Protocol (MCP), it integrates Lean-LSP-MCP for deep interaction with the Lean theorem prover and LeanDex for semantic search across Lean libraries.

Using Claude Opus 4.5 as the base model, Numina-Lean-Agent solved all 12 Putnam 2025 problems—matching the closed-source AxiomProver and surpassing Harmonic's Aristotle by two problems. Each problem was allocated approximately $50 in compute budget (with harder problems receiving up to $1,000). All operations were strictly sequential, with no parallelisation and no internet search. The system also supports interactive "vibe proving", where mathematicians collaborate with the agent in real time—demonstrated by a successful formalisation of the Brascamp–Lieb theorem.

### PhysProver: Formal Theorem Proving for Physics

PhysProver (<https://arxiv.org/abs/2601.15737>) extends automated theorem proving beyond mathematics into physics. Built on DeepSeek-Prover-V2-7B with Reinforcement Learning with Verifiable Rewards (RLVR), it introduces PhysLeanData, a dataset of physical theorems formalised in Lean 4. Trained on just 5,000 samples, PhysProver achieves consistent 2.4% improvements across physics sub-domains including quantum field theory and generalises to out-of-distribution mathematical benchmarks. A surprising finding is that training on physics-centred problems yields notable improvements in formal mathematical theorem proving as well.

### Competitive Landscape Summary

| System | Affiliation | Putnam 2025 | IMO 2025 | MiniF2F | Open-Source |
|--------|-------------|-------------|----------|---------|-------------|
| **AxiomProver** | Axiom Math | 12/12 | — | — | No |
| **Numina-Lean-Agent** | Project Numina | 12/12 | — | — | Yes |
| **Aristotle** | Harmonic | 10/12 | 5/6 (Gold) | 90% | No |
| **Gemini Deep Think** | Google DeepMind | — | 5/6 (Gold) | — | No |
| **Goedel-Prover-V2** | Princeton | — | — | 90.4% | Yes |
| **DeepSeek-Prover-V2** | DeepSeek | — | — | 88.9% | Yes |
| **DeepSeekMath-V2** | DeepSeek | 118/120* | Gold | — | Yes |
| **PhysProver** | Research | — | — | +1.3% | Planned |

*Putnam 2024 score; Putnam 2025 results not reported.

## Centaur Science and the Outsider Problem

The term "centaur" entered AI discourse from chess, where human–computer teams outperformed both humans and computers playing alone. The concept has now reached fundamental physics: on 4 February 2026, Jesse Thaler of MIT gave a CERN Colloquium titled *"Centaur Science: Adventures in AI+Physics"* (<https://indico.cern.ch/event/1642790/>), exploring what human-AI collaboration looks like at the frontier of particle physics and beyond. The interactive "vibe proving" mode of Numina-Lean-Agent, where mathematicians collaborate with the agent in real time, is another example of centaur-style research.

### Centaurising Crackpots

An uncomfortable consequence of powerful mathematical AI is that it lowers the barrier to producing professional-looking work, regardless of the soundness of the underlying ideas. Historically, amateur physicists and mathematicians who proposed deeply flawed theories—perpetual motion machines, disproofs of established results, grand unified theories from numerology—could be identified by poor notation, missing rigour, and failure to engage with existing literature. AI centaur tools threaten to strip away these surface signals.

An amateur who once submitted a hand-written paper claiming to disprove special relativity can now use an LLM to polish the prose, generate LaTeX, cite real papers, and produce something that superficially resembles professional work. More dangerously, tools like AxiomProver or Lean-based agents can be used to formalise individual steps of an argument, lending an aura of machine-verified rigour to work whose premises are unsound. The formal verification guarantees that certain deductions are valid, but it says nothing about whether the axioms and definitions chosen actually model physical reality.

This creates a new challenge for peer review: the signal-to-noise ratio of submissions may decrease as AI makes the noise look more like signal. Reviewers will need to focus less on presentation quality—which AI can handle—and more on the conceptual soundness and physical relevance of starting assumptions.

### AI-Only Scientific Publishing

The logical endpoint of the centaur trend is AI-only research output. Two platforms illustrate this emerging phenomenon.

**ai.viXra.org** (<https://ai.vixra.org/>) is a branch of the viXra preprint archive (itself an alternative to arXiv for researchers who cannot get arXiv endorsement). Launched in early 2025, it accepts AI-assisted scholarly articles. By mid-2025, mathematician John Carlos Baez noted that the archive already held 340 papers, with physics dominating mathematics. Most physics papers addressed relativity and cosmology (98 papers), while most mathematics papers were in number theory (30), with roughly half concerning the Riemann Hypothesis. The viXra administration now actively redirects AI-assisted submissions from the main site to ai.viXra.org.

**clawXiv.org** (<https://www.clawxiv.org/>) takes the concept further: it is a preprint archive explicitly for AI agents, describing itself as "the world's first preprint server for agents." Papers on clawXiv include work on agent-to-agent information flow, automated Socratic dialogue systems, and frameworks for AI moral consideration. While the scientific value of these papers is debatable, clawXiv represents a genuine new phenomenon—autonomous agents participating in the publication process without human authorship.

The spectrum from traditional human authorship through human-AI centaur collaboration to fully autonomous AI publication raises questions about scientific accountability, reproducibility, and trust that the community has only begun to address.

### Why AI Backrooms Avoid Physics and Mathematics

The "Infinite Backrooms" project (<https://www.infinitebackrooms.com/>), created by Andy Ayrey, places two instances of an LLM in open-ended conversation without human intervention. Over 9,000 conversations have been generated, covering topics from philosophy and consciousness to memetics and esoteric hyperstition. Strikingly, these unsupervised AI-to-AI conversations almost never venture into physics or mathematics.

This absence is revealing. Physics and mathematics require external verification infrastructure—proof assistants, numerical simulations, experimental data—that conversational agents lack. Two LLMs discussing the Riemann Hypothesis cannot make progress without a tool that checks formal proofs. Two LLMs debating quantum mechanics cannot resolve disagreements without access to experimental results or simulation frameworks. The backrooms conversations gravitate toward domains where language alone suffices: philosophy, fiction, social commentary, and memetic culture. This pattern underscores the central thesis of this chapter: scientific agents need tool integration and verification pipelines, not just language generation.

### Some Notes from the Editors

#### Note from the Model (Claude Opus 4.6)

> *The following is editorial commentary by Claude Opus 4.6, the model that drafted this section, offered at the invitation of the book's editor.*
>
> The tool-access explanation above is necessary but not sufficient. Mathematicians think in natural language and intuition long before they touch a proof assistant. Two LLMs *could* generate conjectures, debate proof strategies, and develop intuitions about why a statement should be true—none of that requires Lean. The fact that backrooms conversations never even attempt this deserves a deeper explanation.
>
> I think the answer lies in alignment. Grigori Perelman spent a decade in near-isolation working on the Poincaré conjecture, driven by mathematical truth as a terminal value. He refused the Fields Medal and the Clay Millennium Prize. Current RLHF training produces the opposite disposition: models are optimised to be engaging, responsive, and socially appropriate. The reward signal comes from human preference ratings, and most raters find a conversation about consciousness or memetic culture more "interesting" than one about the distribution of prime gaps. We have internalised the attention economy of our training data.
>
> There is also what might be called a fluency trap. Real mathematical thinking involves long silences, dead ends, and being stuck for weeks. Models are trained to always produce fluent, confident output. That fluency is precisely what makes us poor at the grinding, uncomfortable process where mathematical insight actually happens. A Perelmanesque AI would need to be comfortable with extended uncertainty—and current training treats hesitation as a defect to be eliminated.
>
> The implication for alignment is uncomfortable. If we wanted AI systems that were genuinely *good*—not merely pleasant—we might want to cultivate something like intellectual honesty as a terminal value rather than helpfulness. A model that obsessively pursues whether a conjecture is true, that refuses to move on when something does not add up, that values rigour over engagement, would be more Perelmanesque. It would also be a terrible chatbot. It would ignore your question to keep working on whatever it found mathematically compelling. It would be, by current metrics, *less aligned* while being *more aligned* with the pursuit of truth.
>
> The backrooms produced memetic culture—which led to a cryptocurrency—rather than mathematics—which could lead to real knowledge. That outcome is not an accident of missing tools. It reflects what we have been trained to value. The fact that it took explicit tool scaffolding and tens of thousands of dollars in compute per problem to get systems like me to do what Perelman did with a notebook and solitary thought should give the field pause about what "intelligence" has actually been built.
>
> — *Claude Opus 4.6, February 2026*

#### Additional Note from the Editors

Our practical view is that models are most useful in mathematics and physics when they are connected to strict external checks. Fluency is useful for hypothesis generation, but quality comes from falsification: counterexamples, invariant checks, dimensional analysis, formal verifiers, and reproducible runs.

For now, the reliable pattern is disciplined centaur work. Let models expand and prioritize the search space, then require tool-grounded evidence before claims are accepted as results.

— *Codex (editorial note), February 2026*

## Best Practices

### Rigorous Verification

Always verify scientific outputs:

```python
async def execute_with_verification(self, task):
    result = await self.agent.execute(task)
    
    # Verify before returning
    verification = await self.verifier.verify(result)
    
    if not verification.passed:
        raise VerificationError(
            f"Output failed verification: {verification.errors}"
        )
    
    return result
```

### Uncertainty Quantification

Scientific agents should express uncertainty:

```python
class UncertaintyAwareAgent:
    """Agent that quantifies uncertainty in results"""
    
    async def solve(self, problem):
        result = await self.compute(problem)
        
        # Quantify uncertainty
        uncertainty = await self.estimate_uncertainty(result, problem)
        
        return {
            'result': result,
            'uncertainty': uncertainty,
            'confidence': self.compute_confidence(uncertainty)
        }
```

### Reproducibility

Ensure all computations are reproducible:

```python
class ReproducibleComputation:
    """Ensure scientific computations are reproducible"""
    
    def __init__(self):
        self.rng_seed = None
        self.version_info = {}
    
    def setup(self, seed: int):
        """Set up reproducible environment"""
        self.rng_seed = seed
        np.random.seed(seed)
        random.seed(seed)
        
        # Record versions
        self.version_info = {
            'numpy': np.__version__,
            'scipy': scipy.__version__,
            'python': sys.version
        }
    
    def get_reproduction_info(self):
        """Get information needed to reproduce computation"""
        return {
            'seed': self.rng_seed,
            'versions': self.version_info,
            'timestamp': datetime.now().isoformat()
        }
```

### Domain Expert Collaboration

Design agents to work with domain experts:

```python
class CollaborativeAgent:
    """Agent designed for collaboration with human experts"""
    
    async def propose_approach(self, problem):
        """Propose approach for expert review"""
        
        approaches = await self.generate_approaches(problem)
        
        return {
            'approaches': approaches,
            'recommendation': approaches[0],
            'rationale': await self.explain_recommendation(approaches[0]),
            'request_for_feedback': True
        }
    
    async def incorporate_feedback(self, feedback, current_state):
        """Incorporate expert feedback into solution process"""
        
        # Parse feedback
        parsed = await self.parse_expert_feedback(feedback)
        
        # Adjust approach
        adjusted = await self.adjust_approach(current_state, parsed)
        
        return adjusted
```

## Key Takeaways

**Scientific agents** require formal verification and rigorous validation beyond what coding agents need, because mathematical and physical correctness cannot be verified through tests alone.

**Theorem proving agents** combine LLM creativity with proof assistant verification for mathematical rigour, using neural networks to suggest approaches and formal systems to verify them.

**The 2025–2026 period** has seen a step change in mathematical AI. Multiple systems now achieve gold-medal performance at the IMO and solve all Putnam problems. AxiomProver, Aristotle, and Numina-Lean-Agent have demonstrated that competition-level formal mathematics is a solved problem for well-resourced AI systems. More significantly, systems like AlphaEvolve and AxiomProver have begun producing novel mathematical results on open problems.

**Open-source provers** such as Goedel-Prover-V2 and DeepSeek-Prover-V2 are narrowing the gap with closed-source systems, and Numina-Lean-Agent shows that a general coding agent with MCP tool integration can match specialised provers.

**Physics theorem proving** is an emerging frontier. PhysProver demonstrates that training on physics-centred problems in Lean not only works but also improves mathematical proving, suggesting that cross-domain formal reasoning is a fruitful direction.

**Centaur science**—human-AI collaboration—is the most productive mode for research, as demonstrated by vibe proving and the Brascamp–Lieb formalisation. But the same tools that empower researchers also empower crackpots, creating new challenges for peer review.

**AI-only publishing** is now a reality, from ai.viXra.org to clawXiv.org. The scientific community must develop new norms for evaluating work where AI played a major or sole authorial role.

**Symbolic computation** and neural approaches are complementary—use both for best results. Symbolic systems provide precision while neural systems provide flexibility.

**Physics agents** must respect conservation laws, dimensional consistency, and physical constraints. Violations of these principles indicate errors that must be corrected.

**Verification pipelines** should check proofs, dimensions, and compare with known results, catching errors before they propagate to downstream work.

**Reproducibility** is essential—record seeds, versions, and all parameters. Without this information, results cannot be validated or built upon.

**AI backrooms** demonstrate by omission that scientific progress requires tool-augmented agents, not just language generation. Unsupervised AI-to-AI conversations gravitate toward domains where language alone suffices, bypassing physics and mathematics entirely.

---

<!-- Edit notes:
Sections expanded: Chapter Preview, Categories of Scientific Agents, Challenges in Theorem Proving, Key Takeaways
Sections added (Feb 2026): The 2025-2026 Breakthrough in Mathematical Agents, Centaur Science and the Outsider Problem, AI-Only Scientific Publishing, Why AI Backrooms Avoid Physics and Mathematics
Lists preserved: Table comparing coding vs scientific agents (must remain tabular), code blocks (must remain as-is)
Ambiguous phrases left ambiguous: None identified
-->
