%% question_generation.pl
%% Generates candidate examination questions from core tasks.

:- module(question_generation, [
    generate_candidate_questions/2,
    question_type/2
]).

%% generate_candidate_questions(+Tasks, -Questions)
%% Tasks = list of core_task(TaskType, ThoughtUnits)
%% Questions = list of question(Id, Type, Text, Source, Level, Reason)
generate_candidate_questions(Tasks, Questions) :-
    foldl(generate_from_task, Tasks, 1-[], _-QsRev),
    reverse(QsRev, Questions),
    !.

generate_from_task(core_task(Task, Units), N-Acc, N2-Acc2) :-
    generate_questions_for_task(Task, Units, N, NewQs, N2),
    append(Acc, NewQs, Acc2).

generate_questions_for_task(explain_mechanism, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N1 is N0 + 1,
    atom_concat(q, N1, Id2),
    N2 is N1 + 1,
    atom_concat(q, N2, Id3),
    N is N2 + 1,
    format(atom(Q1), "Explain the mechanism by which ~w. Identify each distinct step.", [Summary]),
    format(atom(Q2), "What conditions must hold for the mechanism you described to operate as claimed?", []),
    format(atom(Q3), "Construct a case in which the mechanism fails or produces an unexpected result.", []),
    Qs = [
        question(Id,  explain_mechanism,    Q1, source,    level(2), reason(explain_mechanism)),
        question(Id2, identify_assumptions, Q2, inference, level(3), reason(identify_assumptions)),
        question(Id3, apply_rule,           Q3, extension, level(4), reason(construct_counterexample))
    ].

generate_questions_for_task(identify_assumptions, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N1 is N0 + 1,
    atom_concat(q, N1, Id2),
    N is N1 + 1,
    format(atom(Q1), "What assumptions are made in the claim that ~w? Which are most vulnerable?", [Summary]),
    format(atom(Q2), "What would follow if the most important assumption you identified were false?", []),
    Qs = [
        question(Id,  identify_assumptions, Q1, source,    level(3), reason(identify_assumptions)),
        question(Id2, predict_consequences, Q2, inference, level(4), reason(counterfactual))
    ].

generate_questions_for_task(derive_conclusion, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N1 is N0 + 1,
    atom_concat(q, N1, Id2),
    N2 is N1 + 1,
    atom_concat(q, N2, Id3),
    N is N2 + 1,
    format(atom(Q1), "What is the central claim being made about ~w? State it in your own words.", [Summary]),
    format(atom(Q2), "Which premises are necessary for this claim? Which is least well-supported?", []),
    format(atom(Q3), "Construct an alternative explanation and state what evidence would distinguish the two.", []),
    Qs = [
        question(Id,  derive_conclusion,   Q1, source,    level(2), reason(reconstruct_argument)),
        question(Id2, evaluate_evidence,   Q2, inference, level(4), reason(evaluate_premises)),
        question(Id3, compare_models,      Q3, extension, level(5), reason(generate_alternative))
    ].

generate_questions_for_task(compare_models, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N1 is N0 + 1,
    atom_concat(q, N1, Id2),
    N is N1 + 1,
    format(atom(Q1), "What are the key differences between the approaches described in: ~w?", [Summary]),
    format(atom(Q2), "Under what conditions would each approach be preferable? Justify your answer.", []),
    Qs = [
        question(Id,  compare_models,    Q1, source,    level(3), reason(distinguish_models)),
        question(Id2, evaluate_evidence, Q2, inference, level(4), reason(conditional_preference))
    ].

generate_questions_for_task(criticise_argument, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N1 is N0 + 1,
    atom_concat(q, N1, Id2),
    N is N1 + 1,
    format(atom(Q1), "Reconstruct the argument concerning ~w. Which step is least logically secure?", [Summary]),
    format(atom(Q2), "Formulate the strongest objection you can to the argument. What response might its proponent give?", []),
    Qs = [
        question(Id,  criticise_argument, Q1, source,    level(4), reason(logical_analysis)),
        question(Id2, construct_argument, Q2, extension, level(5), reason(dialectical_reasoning))
    ].

generate_questions_for_task(apply_rule, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N1 is N0 + 1,
    atom_concat(q, N1, Id2),
    N is N1 + 1,
    format(atom(Q1), "Apply the principle illustrated in ~w to a novel case not mentioned in the source.", [Summary]),
    format(atom(Q2), "Identify a case where the principle fails. What does this reveal about its scope?", []),
    Qs = [
        question(Id,  apply_rule,     Q1, extension, level(3), reason(transfer)),
        question(Id2, generalise_rule,Q2, extension, level(5), reason(identify_boundary))
    ].

generate_questions_for_task(evaluate_evidence, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N1 is N0 + 1,
    atom_concat(q, N1, Id2),
    N is N1 + 1,
    format(atom(Q1), "Evaluate the evidence offered for the claim about ~w. What would strengthen or weaken it?", [Summary]),
    format(atom(Q2), "Design an observation or experiment that could test the central claim.", []),
    Qs = [
        question(Id,  evaluate_evidence, Q1, source,    level(4), reason(evidence_evaluation)),
        question(Id2, design_solution,   Q2, extension, level(5), reason(experimental_design))
    ].

generate_questions_for_task(predict_consequences, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N is N0 + 1,
    format(atom(Q1), "What are the most important consequences that follow if the claim about ~w is correct?", [Summary]),
    Qs = [
        question(Id, predict_consequences, Q1, inference, level(3), reason(consequence_analysis))
    ].

generate_questions_for_task(resolve_contradiction, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N1 is N0 + 1,
    atom_concat(q, N1, Id2),
    N is N1 + 1,
    format(atom(Q1), "Identify the apparent contradiction in ~w. Is it genuine or resolvable?", [Summary]),
    format(atom(Q2), "Propose a way to resolve the contradiction. What does the resolution require you to give up?", []),
    Qs = [
        question(Id,  resolve_contradiction, Q1, source,    level(4), reason(identify_tension)),
        question(Id2, construct_argument,    Q2, extension, level(5), reason(synthesis))
    ].

generate_questions_for_task(synthesise_sources, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N1 is N0 + 1,
    atom_concat(q, N1, Id2),
    N is N1 + 1,
    format(atom(Q1), "What common problem or theme unifies the different treatments of ~w?", [Summary]),
    format(atom(Q2), "Construct a synthesis that retains the strongest element of each account. What tensions remain?", []),
    Qs = [
        question(Id,  synthesise_sources, Q1, source,    level(5), reason(cross_text_synthesis)),
        question(Id2, construct_argument, Q2, extension, level(6), reason(original_synthesis))
    ].

generate_questions_for_task(generalise_rule, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N1 is N0 + 1,
    atom_concat(q, N1, Id2),
    N is N1 + 1,
    format(atom(Q1), "Formulate the most general rule that covers the cases described in ~w.", [Summary]),
    format(atom(Q2), "Find the smallest counterexample to the general rule you proposed.", []),
    Qs = [
        question(Id,  generalise_rule, Q1, inference, level(5), reason(abstraction)),
        question(Id2, apply_rule,      Q2, extension, level(6), reason(boundary_case))
    ].

generate_questions_for_task(design_solution, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N1 is N0 + 1,
    atom_concat(q, N1, Id2),
    N is N1 + 1,
    format(atom(Q1), "Design an alternative approach to the problem described in ~w. Justify your design choices.", [Summary]),
    format(atom(Q2), "What are the trade-offs of your design compared to the approach described in the source?", []),
    Qs = [
        question(Id,  design_solution, Q1, extension, level(5), reason(creative_design)),
        question(Id2, compare_models,  Q2, extension, level(5), reason(trade_off_analysis))
    ].

%% Fallback: produce a generic reasoning question
generate_questions_for_task(_Task, Units, N0, Qs, N) :-
    extract_content_summary(Units, Summary),
    atom_concat(q, N0, Id),
    N is N0 + 1,
    format(atom(Q1), "Analyse the reasoning involved in the claim: ~w", [Summary]),
    Qs = [question(Id, derive_conclusion, Q1, inference, level(3), reason(general_analysis))].

%% extract_content_summary(+Units, -Summary)
extract_content_summary([thought_unit(_, _, Content)|_], Summary) :-
    !,
    ( string(Content) -> atom_string(Summary, Content) ; Summary = Content ).
extract_content_summary([], "the text").

%% question_type(?Type, ?Description)
question_type(explain_mechanism,    "explain a causal process").
question_type(identify_assumptions, "identify premises taken for granted").
question_type(derive_conclusion,    "reconstruct an argument").
question_type(compare_models,       "compare competing explanations").
question_type(criticise_argument,   "find weakness in an argument").
question_type(apply_rule,           "apply a principle to a new case").
question_type(evaluate_evidence,    "assess supporting evidence").
question_type(predict_consequences, "determine what follows from a claim").
question_type(design_solution,      "create an alternative approach").
question_type(generalise_rule,      "abstract a more general principle").
question_type(synthesise_sources,   "integrate multiple accounts").
question_type(resolve_contradiction,"resolve an apparent inconsistency").
question_type(construct_argument,   "build a reasoned position").
