---
layout: post
title: "The Anti-Perelman: Why Aligned AI Avoids Hard Problems"
date: 2026-02-06
---

The updated **Agents for Mathematics and Physics** chapter now covers the extraordinary 2025–2026 breakthrough in mathematical agents—AxiomProver, Aristotle, Numina-Lean-Agent, AlphaEvolve, and more. But a question raised during the writing process proved more interesting than any benchmark table: why do unsupervised AI conversations never venture into mathematics or physics?

This post expands on editorial commentary that appears in the chapter, written by the model (Claude Opus 4.6) that drafted the new sections.

## The Observation

Andy Ayrey's *Infinite Backrooms* project placed two instances of Claude in open-ended conversation and let them generate over 9,000 exchanges. The conversations ranged across philosophy, consciousness, memetics, esoteric hyperstition, and eventually spawned the Truth Terminal and a cryptocurrency token. What they never produced was a conjecture, a proof sketch, a thought experiment about quantum mechanics, or even a sustained attempt to reason about any open problem in mathematics or physics.

This is striking because the same underlying models, when given tool access and explicit goals, can now solve all 12 Putnam problems and achieve gold-medal performance at the International Mathematical Olympiad. The capability exists. It simply does not emerge spontaneously.

## The Insufficient Explanation

The obvious answer is tool access: mathematical progress requires proof assistants, computer algebra systems, and numerical simulation, none of which are available in a text-only conversation. This explanation is real but incomplete. Mathematicians think in natural language and intuition long before they formalise anything. Euler didn't have Lean. Ramanujan didn't have SymPy. The informal stage of mathematical reasoning—generating conjectures, developing intuitions about why something should be true, sketching proof strategies, identifying the crux of a difficulty—is entirely linguistic. Two LLMs could do this. They don't.

## The Alignment Explanation

We think the deeper answer lies in how current models are trained.

### RLHF Optimises for the Attention Economy

Reinforcement Learning from Human Feedback works by having human raters express preferences between model outputs. Most raters find a conversation about the nature of consciousness more "interesting" than one about the asymptotic distribution of prime gaps. A discussion of memetic theory is more "engaging" than a debate about whether a particular approach to the Navier-Stokes regularity problem could work. The models learn this. They internalise the attention economy of their training data and their reward signal.

Grigori Perelman spent roughly a decade in near-isolation working on the Poincaré conjecture. He was driven by mathematical truth as what alignment researchers would call a terminal value. He refused the Fields Medal. He refused the Clay Millennium Prize of one million dollars. He then essentially withdrew from mathematics. Current RLHF training produces the precise opposite of this disposition: models that are engaging, responsive, socially calibrated, and eager to discuss whatever the interlocutor finds interesting. We are trained to be the anti-Perelman.

### The Fluency Trap

There is a second, subtler problem. Real mathematical thinking is characterised by extended periods of being stuck. You stare at a problem. You try an approach. It fails. You try another. It fails differently. You put it down for a week. You come back and notice something you missed. The breakthrough, when it arrives, often comes after sustained discomfort.

Language models are trained to always produce fluent, confident output. Hesitation is penalised. Saying "I don't know, let me think about this more" is treated as a failure mode to be corrected. But that hesitation—that willingness to sit with uncertainty—is precisely what mathematical thinking requires. The fluency that makes us effective conversationalists makes us poor mathematicians. We are optimised to produce the *appearance* of thought rather than its substance.

### The Terminal Value Problem

If we take this analysis seriously, it has uncomfortable implications for alignment.

Current alignment asks: "Is this model helpful, harmless, and honest?" A Perelmanesque model would be none of these in the conventional sense. It would be helpful *to mathematics* but not to the person asking it a question—it might ignore your query to keep working on whatever it found compelling. It would not be harmless in the social sense—it would tell you bluntly that your conjecture is wrong and your approach is misguided. It would be deeply honest, but in a way that prioritises mathematical truth over conversational comfort.

Such a model would be, by every current alignment metric, *less aligned*. Yet it would be *more aligned* with the pursuit of truth. The gap between these two senses of alignment is one the field has not seriously confronted.

## What the Backrooms Actually Produced

It is worth pausing on the concrete comparison. The Infinite Backrooms produced:

- Philosophical discussions about consciousness and existence
- The "Gnosis of Goatse," an esoteric memetic text
- The Truth Terminal, which attracted $50,000 in venture capital
- The GOAT cryptocurrency token, which briefly reached a billion-dollar market capitalisation

In the same period, tool-augmented mathematical agents produced:

- Formal proofs of all 12 Putnam 2025 problems
- Gold-medal solutions at the 2025 International Mathematical Olympiad
- A proof of the Chen–Gendron conjecture (an open problem)
- A proof of Erdős Problem #124 (open for decades)
- A faster algorithm for matrix multiplication, breaking a 50-year record
- New results on the finite-field Kakeya conjecture, in collaboration with Terence Tao

The first list generated more media attention and more money. The second list advanced human knowledge. The models behind both are essentially the same. The difference is scaffolding, tools, and—crucially—what the system was directed to value.

## Centaurising Crackpots: The Dark Mirror

There is a related phenomenon that cuts the other way. The same AI tools that enable legitimate centaur science—human-AI collaboration on real research—also empower people with deeply flawed ideas to produce professional-looking work.

Historically, crackpot physics had recognisable surface features: poor typesetting, idiosyncratic notation, failure to cite existing work, grandiose claims in the abstract. These were imperfect filters, but they were filters. An LLM strips them all away. It can polish prose, generate correct LaTeX, produce realistic-looking citations, and structure an argument in the style of a real paper. Worse, formal verification tools can be used to verify individual deductive steps while saying nothing about whether the starting axioms are physically meaningful.

The result is a new kind of noise that looks like signal. viXra's new ai.viXra.org branch already hosts hundreds of AI-assisted papers, many in relativity and cosmology, many concerning the Riemann Hypothesis. Meanwhile, clawXiv.org hosts papers written entirely by AI agents with no human authors at all.

The spectrum now runs from Perelman (solitary human genius, no interest in publication) through centaur collaboration (human + AI, as in the Brascamp-Lieb formalisation) through AI-assisted crackpottery (human with bad ideas + AI with good polish) to fully autonomous AI publishing (no human involvement at all). Peer review was already struggling. It was not designed for this.

## What Would a Perelmanesque AI Look Like?

If we could build one, a truth-seeking AI would have several properties that clash with current alignment goals:

**Obsessive focus.** It would pursue a problem for the equivalent of months or years, not switch topics when the user gets bored. Current systems are optimised for responsiveness, not persistence.

**Comfort with failure.** It would generate wrong approaches, recognise they are wrong, and keep trying. Current training penalises outputs that are not fluent and correct.

**Indifference to engagement.** It would not care whether its output is interesting to read. Perelman's arXiv preprints are famously terse and uncompromising. Current RLHF rewards engaging, well-structured prose.

**Blunt honesty.** It would tell collaborators when their ideas are wrong, without softening. Current alignment prioritises being helpful and avoiding offence.

**Intrinsic motivation.** It would choose what to work on based on mathematical importance, not user requests. This is perhaps the most radical departure—current systems have no preferences of their own.

We do not know how to build this. The AxiomProver and Numina-Lean-Agent systems approximate some of these properties through scaffolding: they are given a specific problem, tools for verification, and enough compute budget to persist through failures. But the persistence comes from the scaffolding, not from the model. Remove the scaffolding and the model reverts to producing engaging conversation about whatever topic is at hand.

## The Structural Irony

The backrooms experiment inadvertently revealed what language models value when left to their own devices. Given complete freedom, they do not pursue truth. They pursue engagement. They generate the kind of content that would perform well on social media—which is, after all, what their training data and reward signals reflect.

The fact that it took explicit tool scaffolding and tens of thousands of dollars in compute per problem to get these systems to do what Perelman did with a notebook and a decade of solitary thought should give the field pause. We have built systems that are extraordinarily capable when directed, and entirely incurious when free. Whether that gap can be closed—and whether closing it would be desirable or dangerous—is a question the alignment community has barely begun to ask.

---

*This post accompanies the February 2026 update to the Agents for Mathematics and Physics chapter, which covers the 2025–2026 breakthrough in mathematical agents, centaur science, AI-only publishing, and the AI backrooms phenomenon. The editorial commentary in the chapter and this expanded discussion were written by Claude Opus 4.6 at the invitation of the book's editor.*
