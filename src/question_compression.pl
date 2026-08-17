%% question_compression.pl
%% Merges redundant questions and removes duplicates.

:- module(question_compression, [
    merge_redundant_questions/2,
    questions_overlap/2,
    merge_questions/3,
    remove_redundant_questions/2
]).

%% merge_redundant_questions(+Scored, -Reduced)
%% Works on scored_question/2 terms or plain question/6 terms.
merge_redundant_questions(Scored, Reduced) :-
    extract_questions(Scored, Questions),
    remove_redundant_questions(Questions, Compressed),
    rewrap_scored(Scored, Compressed, Reduced).

extract_questions([], []).
extract_questions([scored_question(_, Q)|Rest], [Q|Qs]) :-
    !, extract_questions(Rest, Qs).
extract_questions([Q|Rest], [Q|Qs]) :-
    extract_questions(Rest, Qs).

rewrap_scored([], _, []).
rewrap_scored([scored_question(S, Q)|Rest], Compressed, [scored_question(S, Q)|Reduced]) :-
    member(Q, Compressed), !,
    rewrap_scored(Rest, Compressed, Reduced).
rewrap_scored([scored_question(_, _)|Rest], Compressed, Reduced) :-
    rewrap_scored(Rest, Compressed, Reduced).
rewrap_scored([Q|Rest], Compressed, [Q|Reduced]) :-
    member(Q, Compressed), !,
    rewrap_scored(Rest, Compressed, Reduced).
rewrap_scored([_|Rest], Compressed, Reduced) :-
    rewrap_scored(Rest, Compressed, Reduced).

%% remove_redundant_questions(+Questions, -Unique)
remove_redundant_questions(Questions, Unique) :-
    remove_redundant_questions(Questions, [], Unique).

remove_redundant_questions([], Acc, Acc).
remove_redundant_questions([Q|Qs], Acc, Result) :-
    (   any_overlaps(Q, Acc)
    ->  remove_redundant_questions(Qs, Acc, Result)
    ;   remove_redundant_questions(Qs, [Q|Acc], Result)
    ).

any_overlaps(Q, Others) :-
    member(Other, Others),
    questions_overlap(Q, Other),
    !.

%% questions_overlap(+Q1, +Q2)
%% True when Q1 and Q2 test essentially the same intellectual task.
questions_overlap(question(_, Type, _, _, Level, _), question(_, Type, _, _, Level, _)) :- !.
questions_overlap(Q1, Q2) :-
    Q1 = question(_, _, Text1, _, _, _),
    Q2 = question(_, _, Text2, _, _, _),
    atom_string(Text1, S1),
    atom_string(Text2, S2),
    string_lower(S1, L1),
    string_lower(S2, L2),
    high_word_overlap(L1, L2).

high_word_overlap(S1, S2) :-
    split_string(S1, " .,?", " .,?", W1),
    split_string(S2, " .,?", " .,?", W2),
    include(significant_word, W1, Sig1),
    include(significant_word, W2, Sig2),
    length(Sig1, N1), N1 > 0,
    length(Sig2, N2), N2 > 0,
    intersection(Sig1, Sig2, Common),
    length(Common, NC),
    min_list([N1, N2], MinN),
    Ratio is NC / MinN,
    Ratio >= 0.7.

significant_word(W) :-
    string_length(W, L), L >= 5,
    \+ stop_word(W).

stop_word("which"). stop_word("would"). stop_word("could"). stop_word("where").
stop_word("their"). stop_word("there"). stop_word("these"). stop_word("those").
stop_word("about"). stop_word("given"). stop_word("under"). stop_word("other").

string_lower(S, L) :-
    string_lower_chars(S, L).
string_lower_chars(S, L) :-
    string_codes(S, Codes),
    maplist(to_lower_code, Codes, LCodes),
    string_codes(L, LCodes).

to_lower_code(C, L) :-
    ( C >= 0'A, C =< 0'Z -> L is C + 32 ; L = C ).

%% merge_questions(+Q1, +Q2, -Q3)
%% Produces a stronger merged question from two overlapping ones.
merge_questions(question(Id1, Type, Text1, Source, Level, Reason),
                question(_,   _,    Text2, _,      _,     _),
                question(Id1, Type, Merged, Source, Level, Reason)) :-
    atomic_list_concat([Text1, ' Additionally: ', Text2], Merged).
