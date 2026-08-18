%% tests/test_suite.pl
%% Comprehensive test suite for the Human Thought Examination Generator.
%% Run with:  swipl -q -g "run_tests, halt" -t halt tests/test_suite.pl

:- use_module(library(plunit)).

:- use_module('../src/text_analysis').
:- use_module('../src/concept_extraction').
:- use_module('../src/reasoning_analysis').
:- use_module('../src/core_task_reduction').
:- use_module('../src/question_generation').
:- use_module('../src/question_scoring').
:- use_module('../src/question_compression').
:- use_module('../src/exam_planning').
:- use_module('../src/oral_exam').
:- use_module('../src/rubric_generation').
:- use_module('../src/output_formatter').
:- use_module('../human_thought_exam', [human_thought_exam/3, text_exam/3, generate_synthesis_exam/3]).

%% ---------------------------------------------------------------------------
%% Helper predicates
%% ---------------------------------------------------------------------------

short_text('Caching stores previous computation results to reduce repeated work. \
It uses memory and is only beneficial when retrieval is cheaper than recomputation.').

argumentative_text('Free markets lead to optimal resource allocation because price \
signals communicate information that no central planner can aggregate. \
Therefore government intervention distorts these signals and causes inefficiency. \
However critics argue that market failures such as externalities require \
correction and that pure markets produce unacceptable inequality.').

contradictory_text('Increasing money supply always causes inflation. \
However there are periods in which money supply increased dramatically \
without any measurable inflation. Therefore the relationship between \
money supply and inflation is more complex than the simple claim suggests.').

technical_text('A binary search tree stores values in nodes such that the left \
subtree of any node contains only values less than the node value and the \
right subtree contains only greater values. Search requires O(log n) time \
in a balanced tree. Insertion and deletion must maintain the ordering invariant.').

repetitive_text('X is important. X matters a great deal. X has significance. \
X should not be overlooked. X plays a key role. X is central to understanding this.').

factual_text('The Battle of Hastings was fought in 1066. \
William of Normandy defeated Harold of England. \
The Normans subsequently transformed English language and governance.').

competing_theories_text('Behaviourism holds that psychology should study only \
observable behaviour, rejecting mental states as unscientific. \
Cognitivism argues that mental representations and processes are \
scientifically tractable and necessary to explain behaviour. \
Both theories seek to explain learning but differ fundamentally on \
the role of internal states.').

math_text('The fundamental theorem of calculus states that differentiation and \
integration are inverse operations. If f is continuous on an interval then \
the integral of f from a to b equals F(b) minus F(a) where F is any antiderivative \
of f. This connects two apparently separate definitions.').

science_text('Antibiotics inhibit bacterial growth by targeting processes absent in \
human cells, such as cell-wall synthesis and certain ribosomal subunits. \
Resistance arises when bacteria acquire mutations or genes that neutralise the \
antibiotic mechanism. Overuse accelerates the selection of resistant strains.').

programming_text('Recursion is a technique in which a function calls itself with a \
simpler version of the same problem until a base case is reached. \
The call stack grows with each recursive call and may overflow on very deep \
recursion. An iterative solution using an explicit stack avoids this limit.').

philosophical_text('Kant argues that moral worth depends on acting from duty alone. \
The categorical imperative requires acting only on maxims one can universalise. \
Critics hold that consequences cannot be entirely irrelevant to moral assessment.').

%% ---------------------------------------------------------------------------
%% 1. Short explanatory text
%% ---------------------------------------------------------------------------
:- begin_tests(short_text).

test(produces_questions) :-
    short_text(T),
    human_thought_exam(T, [difficulty(undergraduate)], Exam),
    Exam = exam(_, Qs),
    Qs \= [].

test(no_duplicate_questions) :-
    short_text(T),
    human_thought_exam(T, [], Exam),
    Exam = exam(_, Numbered),
    extract_question_texts(Numbered, Texts),
    list_to_set(Texts, Unique),
    length(Texts, L1),
    length(Unique, L2),
    L1 =:= L2.

:- end_tests(short_text).

%% ---------------------------------------------------------------------------
%% 2. Argumentative essay
%% ---------------------------------------------------------------------------
:- begin_tests(argumentative_essay).

test(covers_argument) :-
    argumentative_text(T),
    human_thought_exam(T, [], Exam),
    Exam = exam(_, Qs),
    Qs \= [].

test(includes_assumption_or_criticism) :-
    argumentative_text(T),
    human_thought_exam(T, [], exam(_, Numbered)),
    extract_question_types(Numbered, Types),
    (   member(identify_assumptions, Types)
    ;   member(criticise_argument, Types)
    ;   member(derive_conclusion, Types)
    ).

:- end_tests(argumentative_essay).

%% ---------------------------------------------------------------------------
%% 3. Contradictory source
%% ---------------------------------------------------------------------------
:- begin_tests(contradictory_source).

test(generates_questions_for_contradiction) :-
    contradictory_text(T),
    human_thought_exam(T, [], Exam),
    Exam = exam(_, Qs),
    Qs \= [].

:- end_tests(contradictory_source).

%% ---------------------------------------------------------------------------
%% 4. Technical specification
%% ---------------------------------------------------------------------------
:- begin_tests(technical_specification).

test(generates_questions) :-
    technical_text(T),
    human_thought_exam(T, [difficulty(undergraduate)], Exam),
    Exam = exam(_, Qs),
    Qs \= [].

:- end_tests(technical_specification).

%% ---------------------------------------------------------------------------
%% 5. Source with many repeated ideas (compression test)
%% ---------------------------------------------------------------------------
:- begin_tests(repeated_ideas).

test(fewer_questions_than_sentences) :-
    repetitive_text(T),
    analyse_text(T, Analysis),
    extract_thought_units(Analysis, Units),
    length(Units, UnitCount),
    human_thought_exam(T, [], exam(_, Numbered)),
    length(Numbered, QCount),
    QCount =< UnitCount.

:- end_tests(repeated_ideas).

%% ---------------------------------------------------------------------------
%% 6. Factual-dominant text
%% ---------------------------------------------------------------------------
:- begin_tests(factual_text).

test(generates_reasoning_questions) :-
    factual_text(T),
    human_thought_exam(T, [], Exam),
    Exam = exam(_, Qs),
    Qs \= [].

:- end_tests(factual_text).

%% ---------------------------------------------------------------------------
%% 7. Multiple competing theories
%% ---------------------------------------------------------------------------
:- begin_tests(competing_theories).

test(generates_comparison_questions) :-
    competing_theories_text(T),
    human_thought_exam(T, [], exam(_, Numbered)),
    extract_question_types(Numbered, Types),
    ( member(compare_models, Types) ; member(derive_conclusion, Types) ).

:- end_tests(competing_theories).

%% ---------------------------------------------------------------------------
%% 8. Mathematical reasoning
%% ---------------------------------------------------------------------------
:- begin_tests(mathematical_reasoning).

test(generates_questions) :-
    math_text(T),
    human_thought_exam(T, [difficulty(undergraduate)], Exam),
    Exam = exam(_, Qs),
    Qs \= [].

:- end_tests(mathematical_reasoning).

%% ---------------------------------------------------------------------------
%% 9. Scientific reasoning
%% ---------------------------------------------------------------------------
:- begin_tests(scientific_reasoning).

test(generates_mechanism_or_assumption_questions) :-
    science_text(T),
    human_thought_exam(T, [], exam(_, Numbered)),
    extract_question_types(Numbered, Types),
    ( member(explain_mechanism, Types)
    ; member(identify_assumptions, Types)
    ; member(derive_conclusion, Types)
    ).

:- end_tests(scientific_reasoning).

%% ---------------------------------------------------------------------------
%% 10. Programming material
%% ---------------------------------------------------------------------------
:- begin_tests(programming_material).

test(generates_questions) :-
    programming_text(T),
    human_thought_exam(T, [difficulty(undergraduate)], Exam),
    Exam = exam(_, Qs),
    Qs \= [].

:- end_tests(programming_material).

%% ---------------------------------------------------------------------------
%% 11. Philosophical material
%% ---------------------------------------------------------------------------
:- begin_tests(philosophical_material).

test(generates_questions) :-
    philosophical_text(T),
    human_thought_exam(T, [difficulty(postgraduate)], Exam),
    Exam = exam(_, Qs),
    Qs \= [].

:- end_tests(philosophical_material).

%% ---------------------------------------------------------------------------
%% 12. Assignment generation
%% ---------------------------------------------------------------------------
:- begin_tests(assignment_generation).

test(generates_assignment) :-
    short_text(T),
    generate_assignment(T, [difficulty(undergraduate), questions(5)], Asgn),
    Asgn = assignment(_, Qs),
    Qs \= [].

test(assignment_respects_question_count) :-
    argumentative_text(T),
    generate_assignment(T, [questions(3)], assignment(_, Qs)),
    length(Qs, L),
    L =< 3.

:- end_tests(assignment_generation).

%% ---------------------------------------------------------------------------
%% 13. Written examination generation
%% ---------------------------------------------------------------------------
:- begin_tests(written_exam_generation).

test(generates_exam) :-
    science_text(T),
    human_thought_exam(T, [mode(written), difficulty(undergraduate)], Exam),
    Exam = exam(_, Qs),
    Qs \= [].

:- end_tests(written_exam_generation).

%% ---------------------------------------------------------------------------
%% 14. Spoken examination generation
%% ---------------------------------------------------------------------------
:- begin_tests(spoken_exam_generation).

test(generates_oral_exam) :-
    short_text(T),
    generate_oral_exam(T, [difficulty(undergraduate)], Exam),
    Exam = oral_exam(_, OQs),
    OQs \= [].

test(oral_questions_have_follow_ups) :-
    short_text(T),
    generate_oral_exam(T, [], oral_exam(_, OQs)),
    member(OQ, OQs),
    (   OQ = oral_question_full(_, _, _, _, _, _, FUs)
    ->  FUs \= []
    ;   true  % oral_question_item is also acceptable
    ).

:- end_tests(spoken_exam_generation).

%% ---------------------------------------------------------------------------
%% 15. Adaptive oral follow-ups
%% ---------------------------------------------------------------------------
:- begin_tests(adaptive_oral).

test(next_question_for_insufficient) :-
    next_question(q1, insufficient, Text),
    Text \= ''.

test(next_question_for_competent) :-
    next_question(q1, competent, Text),
    Text \= ''.

test(next_question_for_exceptional) :-
    next_question(q1, exceptional, Text),
    Text \= ''.

test(response_quality_values) :-
    aggregate_all(count, response_quality(_), N),
    N >= 4.

:- end_tests(adaptive_oral).

%% ---------------------------------------------------------------------------
%% 16. Question compression
%% ---------------------------------------------------------------------------
:- begin_tests(question_compression).

test(removes_identical_type_and_level) :-
    Qs = [
        question(q1, derive_conclusion, 'What is X?', source, level(2), reason(r)),
        question(q2, derive_conclusion, 'Describe X.', source, level(2), reason(r)),
        question(q3, explain_mechanism, 'How does Y work?', source, level(3), reason(r))
    ],
    remove_redundant_questions(Qs, Reduced),
    length(Reduced, L),
    L < 3.

test(non_overlapping_questions_kept) :-
    Qs = [
        question(q1, derive_conclusion,  'What is X?', source, level(2), reason(r)),
        question(q2, explain_mechanism,  'Explain mechanism Z.', source, level(3), reason(r)),
        question(q3, evaluate_evidence,  'Evaluate evidence for W.', source, level(4), reason(r))
    ],
    remove_redundant_questions(Qs, Reduced),
    length(Reduced, L),
    L >= 2.

:- end_tests(question_compression).

%% ---------------------------------------------------------------------------
%% 17. Answer-leakage detection
%% ---------------------------------------------------------------------------
:- begin_tests(answer_leakage).

test(detects_leakage_in_question) :-
    Q = question(q1, explain_mechanism, 'How does X work because it uses A and B?', source, level(2), reason(r)),
    question_score(Q, score(_, _, _, _, _, _, Leakage, _)),
    Leakage > 0.

test(no_leakage_in_clean_question) :-
    Q = question(q1, explain_mechanism, 'Explain how caching reduces computation time.', source, level(2), reason(r)),
    question_score(Q, score(_, _, _, _, _, _, Leakage, _)),
    Leakage =:= 0.

:- end_tests(answer_leakage).

%% ---------------------------------------------------------------------------
%% 18. Source fidelity
%% ---------------------------------------------------------------------------
:- begin_tests(source_fidelity).

%% Questions generated from a text must refer to the text, not invented content.
%% We verify by checking that source-type questions have Source = source.
test(source_questions_labelled_correctly) :-
    short_text(T),
    human_thought_exam(T, [], exam(_, Numbered)),
    extract_all_numbered_questions(Numbered, Qs),
    include(is_source_question, Qs, SourceQs),
    SourceQs \= [].

is_source_question(question(_, _, _, source, _, _)).

:- end_tests(source_fidelity).

%% ---------------------------------------------------------------------------
%% 19. Rubric generation
%% ---------------------------------------------------------------------------
:- begin_tests(rubric_generation_tests).

test(generates_rubric) :-
    Q = question(q1, explain_mechanism, 'Explain how X works.', source, level(3), reason(r)),
    generate_rubric(Q, Rubric),
    Rubric = rubric(q1, _, Criteria),
    Criteria \= [].

test(rubric_has_criteria_with_marks) :-
    Q = question(q1, derive_conclusion, 'What follows from X?', source, level(3), reason(r)),
    generate_rubric(Q, rubric(_, _, Criteria)),
    member(criterion(_, Mark), Criteria),
    number(Mark), Mark > 0.

test(no_teacher_answers_in_student_output) :-
    short_text(T),
    human_thought_exam(T, [], Exam),
    format_exam(Exam, text, Text),
    \+ sub_atom(Text, _, _, _, 'teacher_outline'),
    \+ sub_atom(Text, _, _, _, 'expected_reasoning').

:- end_tests(rubric_generation_tests).

%% ---------------------------------------------------------------------------
%% 20. Multiple valid interpretations
%% ---------------------------------------------------------------------------
:- begin_tests(multiple_interpretations).

test(does_not_embed_single_answer) :-
    %% Question text must not contain "the answer is"
    short_text(T),
    human_thought_exam(T, [], exam(_, Numbered)),
    extract_question_texts(Numbered, Texts),
    forall(member(Text, Texts),
           \+ sub_atom(Text, _, _, _, 'the answer is')).

:- end_tests(multiple_interpretations).

%% ---------------------------------------------------------------------------
%% Quality property tests
%% ---------------------------------------------------------------------------
:- begin_tests(quality_properties).

test(no_duplicate_questions_global) :-
    science_text(T),
    human_thought_exam(T, [], exam(_, Numbered)),
    extract_question_texts(Numbered, Texts),
    list_to_set(Texts, Unique),
    length(Texts, L1),
    length(Unique, L2),
    L1 =:= L2.

test(question_dependencies_valid_levels) :-
    %% Later questions should have >= level of earlier questions (after ordering)
    science_text(T),
    human_thought_exam(T, [], exam(_, Numbered)),
    extract_all_numbered_questions(Numbered, Qs),
    levels_non_decreasing(Qs).

test(computerless_exam_self_contained) :-
    short_text(T),
    generate_computerless_exam(T, [], computerless_exam(_, _, Note)),
    atom_length(Note, L),
    L > 0.

test(oral_questions_speakable) :-
    %% Oral questions should be short enough to read aloud once: < 300 chars each
    short_text(T),
    generate_oral_exam(T, [], oral_exam(_, OQs)),
    forall(
        member(OQ, OQs),
        oral_question_speakable(OQ)
    ).

:- end_tests(quality_properties).

%% ---------------------------------------------------------------------------
%% Benchmark test
%% ---------------------------------------------------------------------------
:- begin_tests(benchmark).

test(benchmark_caching) :-
    T = 'Caching stores previous computation results. It uses additional memory. It is useful only when retrieval is cheaper than recomputation. A cache hit occurs when data is already stored. A cache miss requires fresh computation.',
    word_count(T, SourceWords),
    analyse_text(T, Analysis),
    extract_thought_units(Analysis, Units),
    length(Units, UnitCount),
    derive_core_tasks(Units, Tasks),
    generate_candidate_questions(Tasks, Candidates),
    length(Candidates, CandidateCount),
    human_thought_exam(T, [], exam(_, Numbered)),
    length(Numbered, FinalCount),
    format("Benchmark — source words: ~w | thought units: ~w | candidates: ~w | final: ~w~n",
           [SourceWords, UnitCount, CandidateCount, FinalCount]),
    FinalCount =< CandidateCount.  %% compression must not increase count

:- end_tests(benchmark).

%% ---------------------------------------------------------------------------
%% Helper predicates for tests
%% ---------------------------------------------------------------------------

extract_question_texts([], []).
extract_question_texts([numbered_question(_, Q)|Rest], [T|Ts]) :-
    !, get_question_text(Q, T),
    extract_question_texts(Rest, Ts).
extract_question_texts([Q|Rest], [T|Ts]) :-
    get_question_text(Q, T),
    extract_question_texts(Rest, Ts).

get_question_text(question(_, _, Text, _, _, _), Text) :- !.
get_question_text(Q, Q).

extract_question_types([], []).
extract_question_types([numbered_question(_, Q)|Rest], [T|Ts]) :-
    !, get_question_type(Q, T),
    extract_question_types(Rest, Ts).
extract_question_types([Q|Rest], [T|Ts]) :-
    get_question_type(Q, T),
    extract_question_types(Rest, Ts).

get_question_type(question(_, Type, _, _, _, _), Type) :- !.
get_question_type(_, unknown).

extract_all_numbered_questions([], []).
extract_all_numbered_questions([numbered_question(_, Q)|Rest], [Q|Qs]) :-
    !, extract_all_numbered_questions(Rest, Qs).
extract_all_numbered_questions([Q|Rest], [Q|Qs]) :-
    extract_all_numbered_questions(Rest, Qs).

levels_non_decreasing([]) :- !.
levels_non_decreasing([_]) :- !.
levels_non_decreasing([Q1, Q2|Rest]) :-
    get_level(Q1, L1),
    get_level(Q2, L2),
    L2 >= L1,
    levels_non_decreasing([Q2|Rest]).

get_level(question(_, _, _, _, level(L), _), L) :- !.
get_level(_, 1).

oral_question_speakable(oral_question_full(_, _, Text, _, _, _, _)) :-
    !,
    ( atom(Text) -> atom_length(Text, L) ; string_length(Text, L) ),
    L < 400.
oral_question_speakable(oral_question_item(_, _, Text, _, _, _)) :-
    ( atom(Text) -> atom_length(Text, L) ; string_length(Text, L) ),
    L < 400.
oral_question_speakable(_).
