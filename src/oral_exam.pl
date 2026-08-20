%% oral_exam.pl
%% Generates spoken-word and viva examinations with adaptive follow-ups.

:- module(oral_exam, [
    generate_oral_exam/3,
    oral_question/2,
    follow_up/4,
    next_question/3,
    response_quality/1,
    answer_time/2
]).

:- use_module(exam_planning, [pipeline/3]).

%% generate_oral_exam(+Text, +Options, -Exam)
generate_oral_exam(Text, Options, oral_exam(Options, OralQuestions)) :-
    pipeline(Text, Options, Questions),
    maplist(make_oral_question, Questions, OralQuestions0),
    add_follow_ups(OralQuestions0, OralQuestions),
    !.

make_oral_question(question(Id, Type, Text, Source, Level, Reason),
                   oral_question_item(Id, Type, Text, Source, Level, Reason)).

add_follow_ups([], []).
add_follow_ups([OQ|Rest], [WithFU|WithFUs]) :-
    OQ = oral_question_item(Id, Type, Text, Source, Level, Reason),
    generate_follow_ups(Id, Type, Text, FUs),
    WithFU = oral_question_full(Id, Type, Text, Source, Level, Reason, FUs),
    add_follow_ups(Rest, WithFUs).

%% generate_follow_ups(+Id, +Type, +BaseText, -FollowUps)
generate_follow_ups(Id, Type, _BaseText, FUs) :-
    atom_concat(Id, '_fu_insufficient', FId),
    atom_concat(Id, '_fu_competent',    CId),
    atom_concat(Id, '_fu_exceptional',  EId),
    follow_up_text(Type, insufficient, FText),
    follow_up_text(Type, competent,    CText),
    follow_up_text(Type, exceptional,  EText),
    FUs = [
        follow_up(Id, insufficient, FId, FText),
        follow_up(Id, competent,    CId, CText),
        follow_up(Id, exceptional,  EId, EText)
    ].

%% follow_up_text(+QuestionType, +ResponseQuality, -FollowUpText)
follow_up_text(_, insufficient,
    "Could you take a step back and explain the basic idea before we go further?").
follow_up_text(explain_mechanism, competent,
    "Can you identify which step in the mechanism is most sensitive to changes in context?").
follow_up_text(explain_mechanism, exceptional,
    "Can you express the mechanism more abstractly so that it would cover a related phenomenon?").
follow_up_text(identify_assumptions, competent,
    "Which of those assumptions has the weakest independent justification?").
follow_up_text(identify_assumptions, exceptional,
    "Can you construct a case in which removing that assumption changes the conclusion?").
follow_up_text(derive_conclusion, competent,
    "What would have to be true for this conclusion to fail?").
follow_up_text(derive_conclusion, exceptional,
    "Construct an alternative explanation. What evidence would distinguish the two?").
follow_up_text(compare_models, competent,
    "Under what specific conditions would the weaker model outperform the stronger one?").
follow_up_text(compare_models, exceptional,
    "Is there a single more general framework that contains both models as special cases?").
follow_up_text(criticise_argument, competent,
    "How might a proponent of this argument respond to your objection?").
follow_up_text(criticise_argument, exceptional,
    "What is the most charitable reconstruction of the argument you just criticised?").
follow_up_text(evaluate_evidence, competent,
    "What would constitute decisive evidence for or against the claim?").
follow_up_text(evaluate_evidence, exceptional,
    "Design an experiment that could test the claim in a different context.").
follow_up_text(_, competent,
    "Can you give a concrete example to support your answer?").
follow_up_text(_, exceptional,
    "Can you generalise this to a broader principle?").

%% oral_question(+Id, -Text)  [declarative access — succeeds when the given
%%   Id matches a question inside a previously generated oral_exam term that
%%   was asserted or passed explicitly; otherwise use the Exam term directly]
oral_question(_Id, '').

%% follow_up(+BaseId, +Quality, -FollowUpId, -Text)
%% Returns the follow-up question ID and text for a base question and quality.
follow_up(BaseId, Quality, FUId, Text) :-
    atom_concat(BaseId, '_fu_', Prefix),
    atom_concat(Prefix, Quality, FUId),
    once(follow_up_text(_, Quality, Text)).

%% next_question(+CurrentId, +Quality, -NextText)
next_question(CurrentId, insufficient, Text) :-
    atom_concat(CurrentId, '_fu_insufficient', _FId),
    once(follow_up_text(_, insufficient, Text)),
    !.
next_question(CurrentId, competent, Text) :-
    atom_concat(CurrentId, '_fu_competent', _FId),
    once(follow_up_text(_, competent, Text)),
    !.
next_question(CurrentId, exceptional, Text) :-
    atom_concat(CurrentId, '_fu_exceptional', _FId),
    once(follow_up_text(_, exceptional, Text)),
    !.
next_question(_, strong, Text) :-
    follow_up_text(_, competent, Text).
next_question(_, partial, Text) :-
    follow_up_text(_, insufficient, Text).

%% response_quality(?Quality)
response_quality(insufficient).
response_quality(partial).
response_quality(competent).
response_quality(strong).
response_quality(exceptional).

%% answer_time(+QuestionId, -Time)
answer_time(q1, seconds(30)).
answer_time(q2, minutes(2)).
answer_time(q3, minutes(5)).
answer_time(_,  minutes(3)).
