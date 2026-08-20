%% exam_planning.pl
%% Builds the final exam structure from scored, compressed questions.

:- module(exam_planning, [
    ensure_thought_coverage/3,
    order_question_dependencies/2,
    construct_exam/3,
    generate_assignment/3,
    generate_computerless_exam/3,
    pipeline/3
]).

:- use_module(question_generation, [generate_candidate_questions/2]).
:- use_module(concept_extraction,  [extract_thought_units/2]).
:- use_module(text_analysis,       [analyse_text/2]).
:- use_module(core_task_reduction, [derive_core_tasks/2]).
:- use_module(question_scoring,    [score_questions/2, remove_weak_questions/2]).
:- use_module(question_compression,[merge_redundant_questions/2]).

%% ensure_thought_coverage(+ThoughtUnits, +Questions, -Covered)
%% Adds a fallback question for any uncovered thought unit type.
ensure_thought_coverage(ThoughtUnits, Questions, Covered) :-
    covered_types(Questions, CoveredTypes),
    uncovered_units(ThoughtUnits, CoveredTypes, Uncovered),
    length(Questions, N0),
    generate_coverage_questions(Uncovered, N0, ExtraQs),
    append(Questions, ExtraQs, Covered).

covered_types(Questions, Types) :-
    findall(T,
        (   member(scored_question(_, question(_, T, _, _, _, _)), Questions)
        ;   member(question(_, T, _, _, _, _), Questions)
        ),
        Types0),
    list_to_set(Types0, Types).

uncovered_units(Units, CoveredTypes, Uncovered) :-
    include(unit_not_covered(CoveredTypes), Units, Uncovered).

unit_not_covered(CoveredTypes, thought_unit(_, UnitType, _)) :-
    \+ unit_type_covered(UnitType, CoveredTypes).

unit_type_covered(definition,        Types) :- member(identify_assumptions, Types).
unit_type_covered(claim,             Types) :- member(derive_conclusion, Types).
unit_type_covered(assumption,        Types) :- member(identify_assumptions, Types).
unit_type_covered(causal_explanation,Types) :- member(explain_mechanism, Types).
unit_type_covered(mechanism,         Types) :- member(explain_mechanism, Types).
unit_type_covered(example,           Types) :- member(apply_rule, Types).
unit_type_covered(comparison,        Types) :- member(compare_models, Types).
unit_type_covered(_,                 Types) :- member(derive_conclusion, Types).

generate_coverage_questions([], _, []).
generate_coverage_questions([thought_unit(_, _, Content)|Rest], N, [Q|Qs]) :-
    atom_concat(q, N, Id),
    N1 is N + 1,
    format(atom(QText), "Analyse the reasoning in: ~w", [Content]),
    Q = scored_question(5, question(Id, derive_conclusion, QText, source, level(3), reason(coverage))),
    generate_coverage_questions(Rest, N1, Qs).

%% order_question_dependencies(+Covered, -Ordered)
%% Sort by level ascending (comprehension before synthesis).
order_question_dependencies(Covered, Ordered) :-
    extract_all_questions(Covered, Questions),
    msort_by_level(Questions, Ordered).

extract_all_questions([], []).
extract_all_questions([scored_question(_, Q)|Rest], [Q|Qs]) :-
    !, extract_all_questions(Rest, Qs).
extract_all_questions([Q|Rest], [Q|Qs]) :-
    extract_all_questions(Rest, Qs).

msort_by_level(Questions, Sorted) :-
    maplist(add_level_key, Questions, Keyed),
    msort(Keyed, SortedKeyed),
    pairs_values(SortedKeyed, Sorted).

add_level_key(Q, K-Q) :-
    Q = question(_, _, _, _, level(L), _),
    !,
    K = L.
add_level_key(Q, 3-Q).

%% construct_exam(+Ordered, +Options, -Exam)
construct_exam(Questions, Options, Exam) :-
    apply_question_count(Questions, Options, Selected),
    apply_difficulty(Selected, Options, Filtered),
    assign_exam_numbers(Filtered, 1, Numbered),
    Exam = exam(Options, Numbered).

apply_question_count(Questions, Options, Selected) :-
    ( member(questions(N), Options) -> true ; length(Questions, N) ),
    length(Questions, Avail),
    Take is min(N, Avail),
    length(Selected, Take),
    append(Selected, _, Questions).

apply_difficulty(Questions, Options, Questions) :-
    ( member(difficulty(D), Options) -> min_level_for_difficulty(D, _) ; true ).

min_level_for_difficulty(primary,       1).
min_level_for_difficulty(secondary,     2).
min_level_for_difficulty(undergraduate, 2).
min_level_for_difficulty(postgraduate,  3).
min_level_for_difficulty(research,      4).
min_level_for_difficulty(expert,        5).

assign_exam_numbers([], _, []).
assign_exam_numbers([Q|Qs], N, [numbered_question(N, Q)|Numbered]) :-
    N1 is N + 1,
    assign_exam_numbers(Qs, N1, Numbered).

%% generate_assignment(+Text, +Options, -Assignment)
generate_assignment(Text, Options, assignment(Options, Questions)) :-
    pipeline(Text, Options, Questions).

%% generate_computerless_exam(+Text, +Options, -Exam)
%% Adds a note that no computer access is needed/permitted.
generate_computerless_exam(Text, Options, computerless_exam(Options, Questions, Note)) :-
    pipeline(Text, Options, Questions),
    Note = "This examination is designed to be completed without computer, chatbot, or internet access. All necessary context is contained within the questions.".

%% pipeline/3: shared generation pipeline
pipeline(Text, Options, Questions) :-
    analyse_text(Text, Analysis),
    extract_thought_units(Analysis, ThoughtUnits),
    derive_core_tasks(ThoughtUnits, Tasks),
    generate_candidate_questions(Tasks, Candidates),
    score_questions(Candidates, Scored),
    remove_weak_questions(Scored, Strong),
    merge_redundant_questions(Strong, Reduced),
    ensure_thought_coverage(ThoughtUnits, Reduced, Covered),
    order_question_dependencies(Covered, Ordered),
    construct_exam(Ordered, Options, exam(_, Numbered)),
    extract_all_questions(Numbered, NQ),
    unwrap_numbered(NQ, Questions),
    !.

unwrap_numbered([], []).
unwrap_numbered([numbered_question(_, Q)|Rest], [Q|Qs]) :-
    !, unwrap_numbered(Rest, Qs).
unwrap_numbered([Q|Rest], [Q|Qs]) :-
    unwrap_numbered(Rest, Qs).
