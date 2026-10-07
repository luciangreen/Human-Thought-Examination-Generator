%% human_thought_exam.pl
%% Main entry point for the Human Thought Examination Generator.
%%
%% Command-line usage:
%%   swipl -q -s human_thought_exam.pl -- --input essay.txt --mode oral --difficulty postgraduate
%%
%% Prolog interface:
%%   ?- human_thought_exam(Text, Options, Exam).
%%   ?- text_exam("path/to/file.txt", [mode(computerless), difficulty(undergraduate)], Exam).

:- module(human_thought_exam, [
    human_thought_exam/3,
    text_exam/3,
    generate_synthesis_exam/3
]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(readutil)).

:- use_module(src/text_analysis).
:- use_module(src/concept_extraction).
:- use_module(src/reasoning_analysis).
:- use_module(src/core_task_reduction).
:- use_module(src/question_generation).
:- use_module(src/question_scoring).
:- use_module(src/question_compression).
:- use_module(src/exam_planning).
:- use_module(src/oral_exam).
:- use_module(src/rubric_generation).
:- use_module(src/output_formatter).

%% ============================================================
%% Main pipeline
%% ============================================================

%% human_thought_exam(+Text, +Options, -Exam)
%%
%% Text    : atom or string containing source text
%% Options : list of option terms, e.g.
%%           [mode(written), difficulty(undergraduate), questions(8)]
%% Exam    : structured exam term
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
    construct_exam(Ordered, Options, Exam),
    !.

%% text_exam(+PathOrText, +Options, -Exam)
%%
%% Accepts either a file path or inline text.
text_exam(PathOrText, Options, Exam) :-
    ( exists_file(PathOrText) ->
        read_text_file(PathOrText, Text)
    ;
        Text = PathOrText
    ),
    ( member(mode(oral), Options) ->
        oral_exam:generate_oral_exam(Text, Options, Exam)
    ; member(mode(computerless), Options) ->
        exam_planning:generate_computerless_exam(Text, Options, Exam)
    ; member(mode(assignment), Options) ->
        exam_planning:generate_assignment(Text, Options, Exam)
    ;
        human_thought_exam(Text, Options, Exam)
    ),
    !.

%% generate_synthesis_exam(+Texts, +Options, -Exam)
%% Texts: list of text atoms/strings
generate_synthesis_exam(Texts, Options, Exam) :-
    maplist(source_text_atom, Texts, TextAtoms),
    atomic_list_concat(TextAtoms, '\n\n', Combined),
    Options1 = [synthesis(true)|Options],
    human_thought_exam(Combined, Options1, exam(_, Numbered)),
    maplist(numbered_question_term, Numbered, BaseQuestions),
    synthesis_questions(Texts, SynthesisQuestions),
    append(BaseQuestions, SynthesisQuestions, Questions0),
    exam_planning:order_question_dependencies(Questions0, Ordered),
    exam_planning:construct_exam(Ordered, Options1, Exam),
    !.

source_text_atom(Text, Atom) :-
    ( string(Text) -> atom_string(Atom, Text) ; Atom = Text ).

synthesis_questions(Texts, Questions) :-
    length(Texts, Count),
    (   Count >= 2
    ->  Questions = [
            question(q_synthesis_1, synthesise_sources,
                     "Where do the supplied sources agree, and where do their explanations or assumptions differ?",
                     inference, level(5), reason(cross_text_synthesis)),
            question(q_synthesis_2, construct_argument,
                     "Construct a synthesis that preserves the strongest contribution of each source. What tensions remain?",
                     extension, level(6), reason(original_synthesis))
        ]
    ;   Questions = []
    ).

numbered_question_term(numbered_question(_, Question), Question).

%% ============================================================
%% File I/O
%% ============================================================

read_text_file(Path, Text) :-
    read_file_to_string(Path, Text, []).

%% ============================================================
%% Command-line interface
%% ============================================================

:- initialization(main, main).

main :-
    current_prolog_flag(argv, Argv),
    ( Argv = [] ->
        print_usage
    ;
        parse_args(Argv, Inputs, Mode, Difficulty, QCount, OutputFormat, Teacher),
        run_cli(Inputs, Mode, Difficulty, QCount, OutputFormat, Teacher)
    ).

print_usage :-
    writeln("Human Thought Examination Generator"),
    writeln(""),
    writeln("Usage:"),
    writeln("  swipl -q -s human_thought_exam.pl -- [options]"),
    writeln(""),
    writeln("Options:"),
    writeln("  --input FILE          Source text file (repeat for multiple sources)"),
    writeln("  --mode MODE           Mode: written|oral|computerless|assignment|synthesis|socratic"),
    writeln("                        (default: written)"),
    writeln("  --difficulty LEVEL    primary|secondary|undergraduate|postgraduate|research|expert"),
    writeln("                        (default: undergraduate)"),
    writeln("  --questions N         Number of questions (default: all)"),
    writeln("  --output FORMAT       text|prolog (default: text)"),
    writeln("  --teacher             Include teacher rubric"),
    writeln("").

parse_args(Argv, Inputs, Mode, Difficulty, QCount, OutputFormat, Teacher) :-
    ( select('--teacher', Argv, R0) -> Teacher = true ; R0 = Argv, Teacher = false ),
    parse_input_paths(R0, Inputs, R1),
    ( select('--mode',       R1,    R2), select(ModeAtom,    R2,  R3) -> atom_to_term(ModeAtom, Mode, []) ; Mode = written, R3 = R1 ),
    ( select('--difficulty', R3,    R4), select(DiffAtom,    R4,  R5) -> atom_to_term(DiffAtom, Difficulty, []) ; Difficulty = undergraduate, R5 = R3 ),
    ( select('--questions',  R5,    R6), select(QAtom,       R6,  R7) -> atom_number(QAtom, QCount) ; QCount = 0, R7 = R5 ),
    ( select('--output',     R7,    R8), select(FmtAtom,     R8,  _)  -> atom_to_term(FmtAtom, OutputFormat, []) ; OutputFormat = text ).

parse_input_paths(Args, [Input|Inputs], Rest) :-
    select('--input', Args, WithoutFlag),
    select(Input, WithoutFlag, Remaining),
    !,
    parse_input_paths(Remaining, Inputs, Rest).
parse_input_paths(Args, [], Args).

run_cli([], _, _, _, _, _) :-
    !,
    writeln("Error: --input is required."), nl,
    print_usage,
    halt(1).

run_cli(InputPaths, Mode, Difficulty, QCount, OutputFormat, Teacher) :-
    read_cli_texts(InputPaths, Texts),
    build_options(Mode, Difficulty, QCount, Options),
    (   Mode == synthesis
    ->  generate_synthesis_exam(Texts, Options, Exam)
    ;   maplist(source_text_atom, Texts, TextAtoms),
        atomic_list_concat(TextAtoms, '\n\n', Text),
        text_exam(Text, Options, Exam)
    ),
    format_exam(Exam, OutputFormat, ExamText),
    writeln(ExamText),
    (   Teacher == true
    ->  teacher_material(Exam, TeacherText),
        writeln("=== TEACHER-ONLY MATERIAL ==="),
        writeln(TeacherText)
    ;   true
    ).

read_cli_texts([], []).
read_cli_texts([Path|Paths], [Text|Texts]) :-
    (   exists_file(Path)
    ->  read_text_file(Path, Text)
    ;   format(atom(Err), "Error: file not found: ~w", [Path]),
        writeln(Err),
        halt(1)
    ),
    read_cli_texts(Paths, Texts).

teacher_material(Exam, Text) :-
    exam_questions(Exam, Questions),
    maplist(format_teacher_question, Questions, Parts),
    atomic_list_concat(Parts, '\n\n', Text).

exam_questions(exam(_, Numbered), Questions) :-
    !,
    maplist(numbered_question_term, Numbered, Questions).
exam_questions(assignment(_, Questions), Questions) :- !.
exam_questions(computerless_exam(_, Questions, _), Questions) :- !.
exam_questions(oral_exam(_, OralQuestions), Questions) :-
    !,
    maplist(oral_question_term, OralQuestions, Questions).
exam_questions(_, []).

oral_question_term(oral_question_full(_, Type, Text, Source, Level, Reason, _),
                   question(oral, Type, Text, Source, Level, Reason)).
oral_question_term(oral_question_item(_, Type, Text, Source, Level, Reason),
                   question(oral, Type, Text, Source, Level, Reason)).

format_teacher_question(Question, Text) :-
    generate_rubric(Question, Rubric),
    format_rubric(Rubric, RubricText),
    teacher_outline(Question, Outline),
    format(atom(Text), "Question: ~w~n~w~nTeacher outline: ~w",
           [Question, RubricText, Outline]).

build_options(Mode, Difficulty, QCount, Options) :-
    Opts0 = [mode(Mode), difficulty(Difficulty)],
    ( QCount > 0 -> Options = [questions(QCount)|Opts0] ; Options = Opts0 ).
