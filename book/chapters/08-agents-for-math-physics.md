---
title: "Chapter 8: Agents for Mathematics and Physics"
order: 8
---

# Chapter 8: Agents for Mathematics and Physics

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

1. **Theorem Proving Agents**: Construct formal proofs in systems like Lean, Coq, or Isabelle
2. **Symbolic Computation Agents**: Work with computer algebra systems (CAS)
3. **Numerical Simulation Agents**: Set up and run physics simulations
4. **Research Assistants**: Search literature, summarize findings, identify gaps
5. **Educational Scaffolding Agents**: Help students learn mathematical and physical concepts

## Theorem Proving Agents

### Formal Verification Background

Formal theorem proving ensures mathematical correctness through rigorous logical derivation. Unlike informal proofs in papers, formal proofs are machine-verifiable.

### Ax-Prover Architecture

**Ax-Prover** is a notable deep reasoning framework for theorem proving in mathematics and quantum physics. It demonstrates how multi-agent orchestration can tackle formal proofs:

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

1. **Search Space Explosion**: Proofs can have many possible paths
2. **Creativity Required**: Non-obvious proof strategies
3. **Formalization Gap**: Translating informal to formal
4. **Domain Knowledge**: Deep mathematical understanding needed

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

## Best Practices

### 1. Rigorous Verification

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

### 2. Uncertainty Quantification

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

### 3. Reproducibility

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

### 4. Domain Expert Collaboration

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

1. **Scientific agents** require formal verification and rigorous validation beyond what coding agents need.

2. **Theorem proving agents** combine LLM creativity with proof assistant verification for mathematical rigor.

3. **Symbolic computation** and neural approaches are complementary—use both for best results.

4. **Physics agents** must respect conservation laws, dimensional consistency, and physical constraints.

5. **Educational scaffolding** agents adapt explanations to student level and address misconceptions.

6. **Verification pipelines** should check proofs, dimensions, and compare with known results.

7. **Reproducibility** is essential—record seeds, versions, and all parameters.

8. **Collaboration** with domain experts improves agent reliability and trustworthiness.

---
