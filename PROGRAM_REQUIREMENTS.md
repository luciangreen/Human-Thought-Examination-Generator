# Human Thought Examination Generator — Program Requirements

## 1. Purpose

The Human Thought Examination Generator is a Prolog program that converts source texts,
specifications, essays, notes, lectures, and other intellectual material into a rigorous
human-computed thinking task.

The program does **not** primarily answer intellectual questions itself. Its purpose is
to identify the important reasoning contained or implied in the material, convert that
reasoning into high-quality questions, and arrange those questions so that a human can
independently reconstruct, criticise, extend, and apply the ideas.

The intended result is that important reasoning normally delegated to a chatbot can
instead be performed by the human as:

- an assignment;
- a spoken-word examination;
- an oral viva;
- a computerless written examination;
- a discussion or tutorial;
- or a structured self-questioning exercise.

The system acts as a **thought curriculum and examination generator**, not as a substitute
thinker.

---

## 2. Central Principle

Given a source text T, derive a compact question set Q such that completing Q requires the
human to reproduce the important intellectual work associated with T.

```prolog
text_to_human_thought_exam(Text, Exam).
```

The transformation pipeline:

```
source material
    ↓
identify claims, concepts and problems
    ↓
identify reasoning required to understand them
    ↓
identify assumptions, alternatives and implications
    ↓
reduce duplicated or trivial reasoning
    ↓
construct rigorous questions
    ↓
order questions into an intellectual progression
    ↓
human performs the reasoning
```

The program must optimise for quality of thought elicited, not simply number of questions.

---

## 3. Core Functional Requirements

The program must:

1. Accept one or more source texts.
2. Divide them into meaningful intellectual units.
3. Identify the central task or problem represented by each unit.
4. Distinguish facts from reasoning tasks.
5. Identify important claims, concepts, definitions, mechanisms, arguments, assumptions,
   and conclusions.
6. Determine what a competent human would need to think through rather than merely remember.
7. Turn those requirements into intellectually demanding questions.
8. Eliminate questions that merely ask for superficial paraphrase.
9. Combine overlapping questions.
10. Order questions so that later questions can build upon earlier reasoning.
11. Generate assignment, oral-exam, and computerless-exam forms.
12. Generate marking criteria describing the qualities expected in good reasoning without
    supplying a complete model answer by default.

---

## 4. Human-First Constraint

The generated examination must be designed so that the human performs the substantive
reasoning. The default system must avoid generating full answers.

Instead of:

> **Question:** Why does X cause Y?  
> **Answer:** X causes Y because A, B and C.

Generate:

> Why might X cause Y?  
> Identify the intermediate mechanisms required for this conclusion.  
> Which assumptions must hold?  
> What evidence would distinguish this explanation from plausible alternatives?

An optional **teacher-only mode** may produce answer outlines, but student examination
material must remain answer-free.

---

## 5. Intellectual Decomposition

For each source unit, the program attempts to identify:

```prolog
claim(Claim).
definition(Term, Definition).
problem(Problem).
goal(Goal).
assumption(Assumption).
evidence(Evidence).
inference(Premises, Conclusion).
mechanism(Cause, Process, Effect).
comparison(A, B).
dependency(A, B).
constraint(Constraint).
example(Example).
counterexample(Counterexample).
uncertainty(Issue).
implication(Condition, Consequence).
```

Inferred material is marked separately from explicitly stated material.

---

## 6. Core-Task Reduction

The system identifies the smallest useful collection of questions capable of eliciting the
major reasoning in the text.

```prolog
core_task(TextUnit, Task).
```

Possible core tasks:

```prolog
explain_mechanism.      derive_conclusion.     compare_models.
construct_argument.     criticise_argument.    resolve_contradiction.
design_solution.        generalise_rule.       apply_rule.
identify_assumptions.   evaluate_evidence.     predict_consequences.
synthesise_sources.
```

---

## 7. Question Types

Questions requiring the student to:

- define an idea precisely;
- explain it in their own words;
- reconstruct an argument;
- derive a conclusion from premises;
- explain a mechanism;
- distinguish correlation from causation;
- identify assumptions;
- identify missing information;
- compare competing explanations;
- produce counterexamples;
- defend an interpretation;
- criticise an interpretation;
- resolve apparently conflicting claims;
- determine necessary and sufficient conditions;
- generalise a rule;
- identify where a generalisation fails;
- transfer an idea to a novel example;
- design an algorithm, procedure, experiment or solution;
- predict consequences;
- rank alternatives;
- justify a decision;
- integrate several parts of the source;
- formulate an original position supported by reasoning.

---

## 8. Thought Quality

Questions must preferentially require:

```prolog
reasoning.                  analysis.
synthesis.                  evaluation.
application.                abstraction.
counterfactual_reasoning.   causal_reasoning.
logical_derivation.         creative_problem_solving.
```

Fact-retrieval questions are retained only when necessary as scaffolding for subsequent
reasoning.

---

## 9. Question Chains

Questions form reasoning chains where appropriate.

Dependencies are represented as:

```prolog
requires(question_4, question_2).
requires(question_5, question_1).
requires(question_7, question_5).
requires(question_7, question_6).
```

---

## 10. Assignment Mode

```prolog
generate_assignment(Text, Options, Assignment).
```

Options may include:

```prolog
word_limit(2000).
question_count(8).
difficulty(university).
open_book(true).
references_allowed(true).
```

---

## 11. Computerless Examination Mode

```prolog
generate_computerless_exam(Text, Options, Exam).
```

Questions must contain sufficient context to be answered without a computer, search engine,
chatbot, or internet access.

---

## 12. Spoken-Word Examination Mode

```prolog
generate_oral_exam(Text, Options, Exam).
```

Follow-up structure:

```prolog
oral_question(Q1).
follow_up(Q1, adequate, Q2).
follow_up(Q1, incomplete, Q3).
follow_up(Q1, exceptional, Q4).
```

---

## 13. Adaptive Oral Examination

```prolog
response_quality(insufficient).
response_quality(partial).
response_quality(competent).
response_quality(strong).
response_quality(exceptional).

next_question(Current, insufficient, FoundationQuestion).
next_question(Current, competent, ExtensionQuestion).
next_question(Current, exceptional, ResearchQuestion).
```

---

## 14. Progressive Difficulty

```prolog
level(1, comprehension).
level(2, explanation).
level(3, application).
level(4, analysis).
level(5, synthesis).
level(6, evaluation).
level(7, original_contribution).
```

---

## 15. Question Compression

```prolog
questions_overlap(Q1, Q2).
merge_questions(Q1, Q2, Q3).
remove_redundant_questions(Questions0, Questions).
```

---

## 16. Thought Coverage

```prolog
thought_unit(t1, causal_explanation).
covers(q1, t1).
```

Objective: maximise intellectual coverage and reasoning depth; minimise redundancy,
trivia, answer leakage, and question count.

---

## 17. Answer Leakage Prevention

```prolog
answer_leakage(Question, Degree).
rewrite_to_reduce_leakage(Question0, Question).
```

---

## 18–34. Additional Requirements

See full requirements document in the problem statement or the Prolog source modules for
detailed specifications covering: prompt independence, source fidelity, multiple-text
synthesis, Socratic mode, researcher mode, question scoring, marking rubrics, teacher
answer mode, human originality requirements, oral response constraints, examiner prompts,
input/output formats, difficulty controls, discipline awareness, no artificial
single-answer requirement, and intellectual safety against hallucination.

---

## 35. Minimal Example

**Input:**

> Caching can make repeated computation faster by storing previous results. It uses
> additional memory and is useful only where the cost of retrieving a stored result is
> lower than recomputing it.

**Preferred output:**

1. Explain the mechanism by which caching can reduce computation time.
2. Derive the conditions under which caching provides a net benefit.
3. Construct a case in which caching makes a program worse.
4. Which measurements would you need in order to decide whether to introduce caching into
   an unfamiliar algorithm?
5. Can you derive a general decision rule for whether a computed value should be cached?

---

## 36. Prolog Architecture

Modules:

```
src/text_analysis.pl
src/concept_extraction.pl
src/reasoning_analysis.pl
src/core_task_reduction.pl
src/question_generation.pl
src/question_scoring.pl
src/question_compression.pl
src/exam_planning.pl
src/oral_exam.pl
src/rubric_generation.pl
src/output_formatter.pl
human_thought_exam.pl   (main entry point)
```

Main pipeline:

```prolog
human_thought_exam(Text, Options, Exam) :-
    analyse_text(Text, Analysis),
    extract_thought_units(Analysis, ThoughtUnits),
    derive_core_tasks(ThoughtUnits, Tasks),
    generate_candidate_questions(Tasks, Candidates),
    score_questions(Candidates, Scored),
    remove_weak_questions(Scored, Strong),
    merge_redundant_questions(Strong, Reduced),
    ensure_thought_coverage(ThoughtUnits, Reduced, Covered),
    order_question_dependencies(Covered, Ordered),
    construct_exam(Ordered, Options, Exam).
```

---

## 37. Deterministic Prolog Preference

Processing stages use clear input/output predicates. Uncontrolled accidental choicepoints
are avoided.

---

## 38. Explainability

```prolog
question_reason(q7, tests(assumption_identification, causal_reasoning, transfer)).
```

This metadata appears in teacher/developer output only, not on student papers.

---

## 39–40. Tests and Quality Tests

See `tests/` directory. Tests cover:

- short explanatory text
- argumentative essay
- contradictory source
- technical specification
- many repeated ideas
- factual-dominant text
- multiple competing theories
- mathematical reasoning
- scientific reasoning
- programming material
- philosophical material
- assignment generation
- written examination generation
- spoken examination generation
- adaptive oral follow-ups
- question compression
- answer-leakage detection
- source-fidelity checking
- rubric generation
- multiple valid interpretations

Quality properties tested:

```prolog
test(no_duplicate_questions).
test(core_claim_covered).
test(major_assumptions_examined).
test(no_student_answers_in_exam).
test(question_dependencies_valid).
test(source_claims_not_invented).
test(oral_questions_speakable).
test(computerless_exam_self_contained).
```

---

## 41. Benchmarking

See `tests/benchmark_test.pl`. Benchmark compares:

- number of source words
- number of extracted thought units
- number of candidate questions
- number of final questions
- thought-unit coverage
- redundancy removed
- question difficulty distribution
- estimated answer leakage

---

## 42. Command-Line Interface

```
swipl -q -s human_thought_exam.pl -- \
  --input essay.txt \
  --mode oral \
  --difficulty postgraduate
```

Or from within Prolog:

```prolog
?- text_exam(
       "essay.txt",
       [mode(computerless), difficulty(undergraduate),
        duration(minutes(120)), questions(10)],
       Exam).
```

---

## 43. Acceptance Criteria

The first usable release is complete when it can take an unfamiliar substantive text and
produce a compact examination in which:

- the central intellectual tasks are represented;
- major reasoning cannot be completed merely through copying passages;
- the questions require the human to perform analysis;
- obvious duplicate questions have been removed;
- answers are not embedded in question wording;
- the examination has a coherent progression;
- oral questions can be used without a computer;
- written questions can be attempted without chatbot assistance;
- teachers can obtain rubrics independently of student output;
- source claims and generator inferences are distinguishable;
- tests demonstrate consistent performance over several disciplines.

---

## 44. Governing Design Principle

> Do not ask: "What answer can the chatbot produce from this text?"  
> Ask: "What sequence of questions would cause a capable human to perform the valuable
> reasoning themselves?"

```
TEXT → THOUGHT STRUCTURE → CORE REASONING TASKS → RIGOROUS QUESTIONS
    → ASSIGNMENT / VIVA / COMPUTERLESS EXAM → HUMAN THINKING
```

The principal measure of success is not how much intelligence the program displays in its
output, but how much high-quality reasoning its questions successfully elicit from the
human.
