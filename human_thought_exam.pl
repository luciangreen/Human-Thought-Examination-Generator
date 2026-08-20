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
    atomic_list_concat(Texts, ' ', Combined),
    Options1 = [synthesis(true)|Options],
    human_thought_exam(Combined, Options1, Exam),
    !.

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
        parse_args(Argv, Input, Mode, Difficulty, QCount, OutputFormat),
        run_cli(Input, Mode, Difficulty, QCount, OutputFormat)
    ).

print_usage :-
    writeln("Human Thought Examination Generator"),
    writeln(""),
    writeln("Usage:"),
    writeln("  swipl -q -s human_thought_exam.pl -- [options]"),
    writeln(""),
    writeln("Options:"),
    writeln("  --input FILE          Source text file (required)"),
    writeln("  --mode MODE           Mode: written|oral|computerless|assignment|synthesis"),
    writeln("                        (default: written)"),
    writeln("  --difficulty LEVEL    primary|secondary|undergraduate|postgraduate|research|expert"),
    writeln("                        (default: undergraduate)"),
    writeln("  --questions N         Number of questions (default: all)"),
    writeln("  --output FORMAT       text|prolog (default: text)"),
    writeln("  --teacher             Include teacher rubric"),
    writeln("").

parse_args(Argv, Input, Mode, Difficulty, QCount, OutputFormat) :-
    ( select('--input',      Argv,  R0), select(Input,       R0,  R1) -> true ; Input = '', R1 = Argv ),
    ( select('--mode',       R1,    R2), select(ModeAtom,    R2,  R3) -> atom_to_term(ModeAtom, Mode, []) ; Mode = written, R3 = R1 ),
    ( select('--difficulty', R3,    R4), select(DiffAtom,    R4,  R5) -> atom_to_term(DiffAtom, Difficulty, []) ; Difficulty = undergraduate, R5 = R3 ),
    ( select('--questions',  R5,    R6), select(QAtom,       R6,  R7) -> atom_number(QAtom, QCount) ; QCount = 0, R7 = R5 ),
    ( select('--output',     R7,    R8), select(FmtAtom,     R8,  _)  -> atom_to_term(FmtAtom, OutputFormat, []) ; OutputFormat = text ).

run_cli('', _, _, _, _) :-
    !,
    writeln("Error: --input is required."), nl,
    print_usage,
    halt(1).

run_cli(InputPath, Mode, Difficulty, QCount, OutputFormat) :-
    ( exists_file(InputPath) ->
        read_text_file(InputPath, Text)
    ;
        format(atom(Err), "Error: file not found: ~w", [InputPath]),
        writeln(Err),
        halt(1)
    ),
    build_options(Mode, Difficulty, QCount, Options),
    text_exam(Text, Options, Exam),
    format_exam(Exam, OutputFormat, ExamText),
    writeln(ExamText).

build_options(Mode, Difficulty, QCount, Options) :-
    Opts0 = [mode(Mode), difficulty(Difficulty)],
    ( QCount > 0 -> Options = [questions(QCount)|Opts0] ; Options = Opts0 ).
