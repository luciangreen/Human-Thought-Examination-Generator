%% rubric_generation.pl
%% Generates marking rubrics and optional teacher answer outlines.
%% Student output never contains teacher answers.

:- module(rubric_generation, [
    generate_rubric/2,
    teacher_outline/2,
    criterion/3
]).

%% generate_rubric(+Question, -Rubric)
generate_rubric(question(Id, Type, _Text, _Source, Level, _Reason),
                rubric(Id, Level, Criteria)) :-
    rubric_criteria(Type, Level, Criteria).

%% rubric_criteria(+QuestionType, +Level, -Criteria)
rubric_criteria(explain_mechanism, Level, Criteria) :-
    base_criteria(Level, Base),
    Criteria = [
        criterion(identifies_core_mechanism, 3),
        criterion(describes_causal_steps, 4),
        criterion(states_necessary_conditions, 3),
        criterion(distinguishes_essential_from_incidental, 3)
        | Base
    ].

rubric_criteria(identify_assumptions, Level, Criteria) :-
    base_criteria(Level, Base),
    Criteria = [
        criterion(identifies_implicit_premises, 4),
        criterion(ranks_by_vulnerability, 3),
        criterion(explains_consequence_of_removal, 3)
        | Base
    ].

rubric_criteria(derive_conclusion, Level, Criteria) :-
    base_criteria(Level, Base),
    Criteria = [
        criterion(reconstructs_argument_accurately, 4),
        criterion(identifies_weakest_premise, 3),
        criterion(considers_plausible_alternatives, 3)
        | Base
    ].

rubric_criteria(compare_models, Level, Criteria) :-
    base_criteria(Level, Base),
    Criteria = [
        criterion(identifies_key_differences, 3),
        criterion(identifies_shared_assumptions, 2),
        criterion(justifies_conditional_preference, 4)
        | Base
    ].

rubric_criteria(criticise_argument, Level, Criteria) :-
    base_criteria(Level, Base),
    Criteria = [
        criterion(identifies_logical_weakness, 4),
        criterion(formulates_strong_objection, 4),
        criterion(considers_proponent_response, 3)
        | Base
    ].

rubric_criteria(evaluate_evidence, Level, Criteria) :-
    base_criteria(Level, Base),
    Criteria = [
        criterion(assesses_evidential_strength, 4),
        criterion(identifies_alternative_explanations, 3),
        criterion(proposes_discriminating_test, 3)
        | Base
    ].

rubric_criteria(design_solution, Level, Criteria) :-
    base_criteria(Level, Base),
    Criteria = [
        criterion(proposes_workable_design, 4),
        criterion(justifies_design_choices, 3),
        criterion(acknowledges_trade_offs, 3)
        | Base
    ].

rubric_criteria(generalise_rule, Level, Criteria) :-
    base_criteria(Level, Base),
    Criteria = [
        criterion(states_rule_precisely, 4),
        criterion(identifies_scope_conditions, 3),
        criterion(finds_non_trivial_counterexample, 4)
        | Base
    ].

rubric_criteria(synthesise_sources, Level, Criteria) :-
    base_criteria(Level, Base),
    Criteria = [
        criterion(identifies_agreements, 3),
        criterion(identifies_genuine_disagreements, 4),
        criterion(constructs_coherent_synthesis, 4),
        criterion(acknowledges_residual_tensions, 3)
        | Base
    ].

rubric_criteria(_, Level, Criteria) :-
    base_criteria(Level, Criteria).

base_criteria(level(L), Base) :-
    ( L >= 5 ->
        Base = [
            criterion(reasoning_quality, 4),
            criterion(logical_coherence, 3),
            criterion(awareness_of_alternatives, 3),
            criterion(originality, 2)
        ]
    ; L >= 3 ->
        Base = [
            criterion(reasoning_quality, 4),
            criterion(logical_coherence, 3)
        ]
    ;
        Base = [
            criterion(accuracy, 3),
            criterion(clarity, 2)
        ]
    ).

%% criterion(+QuestionId, +CriterionName, +MaxMark)
%% Used externally to query criteria for a specific question.
criterion(Qid, Name, Mark) :-
    generate_rubric(question(Qid, derive_conclusion, _, source, level(3), _),
                    rubric(Qid, _, Criteria)),
    member(criterion(Name, Mark), Criteria).

%% teacher_outline(+Question, -Outline)
%% Teacher-only.  Must not appear on student paper.
teacher_outline(question(Id, Type, Text, _Source, Level, _Reason),
                teacher_outline(Id, Level, ExpectedConcepts, ReasoningPath, CommonMistakes)) :-
    expected_concepts(Type, ExpectedConcepts),
    reasoning_path(Type, Text, ReasoningPath),
    common_mistakes(Type, CommonMistakes).

expected_concepts(explain_mechanism,
    ["causal chain", "necessary conditions", "boundary cases"]).
expected_concepts(identify_assumptions,
    ["implicit premises", "hidden dependencies", "warranted vs unwarranted assumptions"]).
expected_concepts(derive_conclusion,
    ["central thesis", "supporting premises", "logical validity"]).
expected_concepts(compare_models,
    ["key differences", "shared assumptions", "context-dependent preference"]).
expected_concepts(criticise_argument,
    ["logical structure", "weakest link", "counterexample", "charitable reading"]).
expected_concepts(evaluate_evidence,
    ["evidential strength", "alternative explanations", "falsifiability"]).
expected_concepts(generalise_rule,
    ["abstraction", "scope conditions", "counterexample"]).
expected_concepts(design_solution,
    ["design constraints", "trade-offs", "feasibility"]).
expected_concepts(synthesise_sources,
    ["agreements", "disagreements", "synthesis", "residual tensions"]).
expected_concepts(_, ["core concept", "supporting argument", "implication"]).

reasoning_path(Type, Text, Path) :-
    format(atom(Path),
        "Expected reasoning path for ~w: \
        (1) Identify the core claim in the source. \
        (2) Enumerate the relevant considerations. \
        (3) Assess the strongest and weakest points. \
        (4) Reach a supported conclusion. \
        Question text: ~w",
        [Type, Text]).

common_mistakes(explain_mechanism,
    ["confusing correlation with causation",
     "omitting intermediate steps",
     "ignoring boundary conditions"]).
common_mistakes(identify_assumptions,
    ["identifying only explicit premises",
     "failing to rank by importance",
     "not considering what removal implies"]).
common_mistakes(derive_conclusion,
    ["restating the source without analysis",
     "accepting all premises uncritically"]).
common_mistakes(compare_models,
    ["listing differences without analysing them",
     "failing to consider context-dependence"]).
common_mistakes(criticise_argument,
    ["attacking a strawman",
     "failing to reconstruct the strongest version"]).
common_mistakes(evaluate_evidence,
    ["accepting evidence at face value",
     "ignoring alternative explanations"]).
common_mistakes(_, ["vague or unsupported assertions",
                    "failure to engage with the question"]).
