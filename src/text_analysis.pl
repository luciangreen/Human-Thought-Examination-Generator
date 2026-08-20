%% text_analysis.pl
%% Breaks source text into meaningful intellectual units (sentences / paragraphs).

:- module(text_analysis, [
    analyse_text/2,
    split_into_sentences/2,
    split_into_paragraphs/2,
    word_count/2,
    classify_sentence/2
]).

%% analyse_text(+Text, -Analysis)
%% Main entry point.  Produces a structured analysis term.
analyse_text(Text, analysis(Words, Sentences, Paragraphs)) :-
    word_count(Text, Words),
    split_into_sentences(Text, Sentences),
    split_into_paragraphs(Text, Paragraphs),
    !.

%% word_count(+Text, -Count)
word_count(Text, Count) :-
    atomic(Text),
    atomic_list_concat(Parts, ' ', Text),
    length(Parts, Count).

%% split_into_sentences(+Text, -Sentences)
%% Very lightweight sentence splitter on terminal punctuation.
split_into_sentences(Text, Sentences) :-
    atomic(Text),
    atom_string(Text, S),
    split_string(S, "", "", [S1]),
    sentence_split(S1, RawSentences),
    include(non_empty_string, RawSentences, Sentences).

sentence_split(S, Sentences) :-
    split_string(S, ".!?", "", Parts0),
    maplist(string_trim, Parts0, Sentences).

string_trim(S, T) :-
    split_string(S, "", " \t\n\r", [T|_]).

non_empty_string(S) :- S \= "".

%% split_into_paragraphs(+Text, -Paragraphs)
split_into_paragraphs(Text, Paragraphs) :-
    atomic(Text),
    atom_string(Text, S),
    ( split_string(S, "\n\n", "", Ps0) -> true ; Ps0 = [S] ),
    include(non_empty_string, Ps0, Paragraphs).

%% classify_sentence(+Sentence, -Class)
%% Classes: definition, claim, example, mechanism, comparison, assumption, conclusion
classify_sentence(S, Class) :-
    (   definition_pattern(S) -> Class = definition
    ;   example_pattern(S)    -> Class = example
    ;   assumption_pattern(S) -> Class = assumption
    ;   conclusion_pattern(S) -> Class = conclusion
    ;   mechanism_pattern(S)  -> Class = mechanism
    ;   comparison_pattern(S) -> Class = comparison
    ;   Class = claim
    ).

definition_pattern(S) :-
    (   sub_string(S, _, _, _, " is ")
    ;   sub_string(S, _, _, _, " are ")
    ;   sub_string(S, _, _, _, " means ")
    ;   sub_string(S, _, _, _, " defined as ")
    ;   sub_string(S, _, _, _, "definition")
    ).

example_pattern(S) :-
    (   sub_string(S, _, _, _, "for example")
    ;   sub_string(S, _, _, _, "for instance")
    ;   sub_string(S, _, _, _, "e.g.")
    ;   sub_string(S, _, _, _, "such as")
    ).

assumption_pattern(S) :-
    (   sub_string(S, _, _, _, "assum")
    ;   sub_string(S, _, _, _, "presuppos")
    ;   sub_string(S, _, _, _, "given that")
    ;   sub_string(S, _, _, _, "provided that")
    ).

conclusion_pattern(S) :-
    (   sub_string(S, _, _, _, "therefore")
    ;   sub_string(S, _, _, _, "thus")
    ;   sub_string(S, _, _, _, "hence")
    ;   sub_string(S, _, _, _, "it follows")
    ;   sub_string(S, _, _, _, "consequently")
    ).

mechanism_pattern(S) :-
    (   sub_string(S, _, _, _, " causes ")
    ;   sub_string(S, _, _, _, " leads to ")
    ;   sub_string(S, _, _, _, " results in ")
    ;   sub_string(S, _, _, _, " produces ")
    ;   sub_string(S, _, _, _, " enables ")
    ).

comparison_pattern(S) :-
    (   sub_string(S, _, _, _, " whereas ")
    ;   sub_string(S, _, _, _, " however ")
    ;   sub_string(S, _, _, _, " unlike ")
    ;   sub_string(S, _, _, _, " compared to ")
    ;   sub_string(S, _, _, _, " in contrast")
    ).
