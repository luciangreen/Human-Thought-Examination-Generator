%% question_scoring.pl
%% Scores candidate questions and removes weak ones.

:- module(question_scoring, [
    score_questions/2,
    remove_weak_questions/2,
    question_score/2
]).

%% score_questions(+Questions, -Scored)
%% Scored = list of scored_question(Score, Question)
score_questions(Questions, Scored) :-
    maplist(score_one_question, Questions, Scored).

score_one_question(Question, scored_question(Total, Question)) :-
    question_score(Question, score(R, D, N, Rsn, T, Cl, AL, Red)),
    Total is R + D + N + Rsn + T + Cl - AL - Red.

%% question_score(+Question, -Scores)
question_score(question(_Id, Type, Text, Source, Level, _Reason), score(R, D, N, Rsn, T, Cl, AL, Red)) :-
    relevance_score(Source, R),
    depth_score(Level, D),
    novelty_score(Type, N),
    reasoning_score(Type, Rsn),
    transfer_score(Type, T),
    clarity_score(Text, Cl),
    answer_leakage_score(Text, AL),
    redundancy_score(Type, Red).

relevance_score(source,    3).
relevance_score(inference, 2).
relevance_score(extension, 2).
relevance_score(research,  1).

depth_score(level(1), 1).
depth_score(level(2), 2).
depth_score(level(3), 3).
depth_score(level(4), 4).
depth_score(level(5), 5).
depth_score(level(6), 6).
depth_score(level(7), 7).

novelty_score(apply_rule,           2).
novelty_score(design_solution,      3).
novelty_score(generalise_rule,      3).
novelty_score(synthesise_sources,   3).
novelty_score(resolve_contradiction,2).
novelty_score(_,                    1).

reasoning_score(explain_mechanism,    3).
reasoning_score(identify_assumptions, 3).
reasoning_score(criticise_argument,   4).
reasoning_score(compare_models,       3).
reasoning_score(evaluate_evidence,    3).
reasoning_score(design_solution,      4).
reasoning_score(synthesise_sources,   4).
reasoning_score(generalise_rule,      4).
reasoning_score(resolve_contradiction,4).
reasoning_score(_,                    2).

transfer_score(apply_rule,      2).
transfer_score(design_solution, 2).
transfer_score(generalise_rule, 2).
transfer_score(_,               1).

clarity_score(Text, Score) :-
    atom_length(Text, L),
    ( L < 20  -> Score = 1
    ; L < 200 -> Score = 3
    ; Score = 2
    ).

%% answer_leakage_score(+Text, -LeakageScore)
%% Higher score = more leakage = penalised
answer_leakage_score(Text, Score) :-
    ( answer_leakage_detected(Text) -> Score = 2 ; Score = 0 ).

answer_leakage_detected(Text) :-
    atom(Text),
    (   sub_atom(Text, _, _, _, 'because ')
    ;   sub_atom(Text, _, _, _, 'the answer is')
    ;   sub_atom(Text, _, _, _, 'this works by')
    ;   sub_atom(Text, _, _, _, 'the three ')
    ;   sub_atom(Text, _, _, _, 'the two ')
    ).
answer_leakage_detected(Text) :-
    string(Text),
    (   sub_string(Text, _, _, _, "because ")
    ;   sub_string(Text, _, _, _, "the answer is")
    ;   sub_string(Text, _, _, _, "this works by")
    ).

redundancy_score(derive_conclusion, 0).
redundancy_score(_, 0).

%% remove_weak_questions(+Scored, -Strong)
%% Retains questions above a minimum threshold.
remove_weak_questions(Scored, Strong) :-
    include(above_threshold, Scored, Strong).

above_threshold(scored_question(Score, _)) :-
    Score >= 5.
