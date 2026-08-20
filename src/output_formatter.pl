%% output_formatter.pl
%% Formats exam terms as human-readable text or Prolog terms.

:- module(output_formatter, [
    format_exam/2,
    format_exam/3,
    print_exam/1,
    print_exam/2,
    format_rubric/2,
    print_rubric/1,
    exam_to_text/2
]).

%% format_exam(+Exam, -Text)
%% format_exam(+Exam, +Format, -Text)   Format: text | prolog
format_exam(Exam, Text) :-
    format_exam(Exam, text, Text).

format_exam(Exam, prolog, Text) :-
    !,
    term_to_atom(Exam, Text).

format_exam(exam(Options, Numbered), text, Text) :-
    !,
    format(atom(Header), "=== EXAMINATION ===~nOptions: ~w~n~n", [Options]),
    maplist(format_numbered_question_text, Numbered, Parts),
    atomic_list_concat([Header|Parts], '\n', Text).

format_exam(computerless_exam(Options, Questions, Note), text, Text) :-
    !,
    format(atom(Header), "=== COMPUTERLESS EXAMINATION ===~n~w~n~nOptions: ~w~n~n", [Note, Options]),
    maplist(format_question_text, Questions, Parts),
    atomic_list_concat([Header|Parts], '\n', Text).

format_exam(assignment(Options, Questions), text, Text) :-
    !,
    format(atom(Header), "=== ASSIGNMENT ===~nOptions: ~w~n~n", [Options]),
    maplist(format_question_text, Questions, Parts),
    atomic_list_concat([Header|Parts], '\n', Text).

format_exam(oral_exam(Options, OralQuestions), text, Text) :-
    !,
    format(atom(Header), "=== ORAL EXAMINATION ===~nOptions: ~w~n~n", [Options]),
    maplist(format_oral_question_text, OralQuestions, Parts),
    atomic_list_concat([Header|Parts], '\n', Text).

format_exam(Exam, text, Text) :-
    term_to_atom(Exam, Text).

%% format_numbered_question_text(+NumberedQuestion, -Text)
format_numbered_question_text(numbered_question(N, question(_, _, QText, Source, level(L), _)), Text) :-
    !,
    source_label(Source, SLabel),
    format(atom(Text), "~w. [Level ~w | ~w]~n~w~n", [N, L, SLabel, QText]).
format_numbered_question_text(numbered_question(N, Q), Text) :-
    format(atom(Text), "~w. ~w~n", [N, Q]).

%% format_question_text(+Question, -Text)
format_question_text(question(_, _, QText, Source, level(L), _), Text) :-
    !,
    source_label(Source, SLabel),
    format(atom(Text), "[Level ~w | ~w]~n~w~n", [L, SLabel, QText]).
format_question_text(Q, Text) :-
    format(atom(Text), "~w~n", [Q]).

format_oral_question_text(oral_question_full(Id, _, QText, _, level(L), _, FUs), Text) :-
    !,
    format(atom(QLine), "[~w | Level ~w]: ~w~n", [Id, L, QText]),
    maplist(format_follow_up_text, FUs, FUParts),
    atomic_list_concat([QLine|FUParts], '  ', Text).
format_oral_question_text(oral_question_item(Id, _, QText, _, level(L), _), Text) :-
    format(atom(Text), "[~w | Level ~w]: ~w~n", [Id, L, QText]).
format_oral_question_text(Q, Text) :-
    format(atom(Text), "~w~n", [Q]).

format_follow_up_text(follow_up(_, Quality, _, FUText), Text) :-
    format(atom(Text), "  [If ~w]: ~w~n", [Quality, FUText]).

source_label(source,    "from source").
source_label(inference, "inferred").
source_label(extension, "extension").
source_label(research,  "research").

%% print_exam(+Exam)
print_exam(Exam) :-
    format_exam(Exam, text, Text),
    write(Text), nl.

%% print_exam(+Exam, +Format)
print_exam(Exam, Format) :-
    format_exam(Exam, Format, Text),
    write(Text), nl.

%% format_rubric(+Rubric, -Text)
format_rubric(rubric(Id, Level, Criteria), Text) :-
    format(atom(Header), "--- Rubric for ~w (Level ~w) ---~n", [Id, Level]),
    maplist(format_criterion_text, Criteria, Parts),
    atomic_list_concat([Header|Parts], '\n', Text).

format_criterion_text(criterion(Name, Mark), Text) :-
    format(atom(Text), "  * ~w  [~w marks]", [Name, Mark]).

%% print_rubric(+Rubric)
print_rubric(Rubric) :-
    format_rubric(Rubric, Text),
    write(Text), nl.

%% exam_to_text(+Exam, -Text)
exam_to_text(Exam, Text) :- format_exam(Exam, text, Text).
