# Human-Thought-Examination-Generator
Human Thought Examination Generator

## Example commands

### Run from command line
```bash
swipl -q -s human_thought_exam.pl -- --input examples/texts/caching.txt
```

```bash
swipl -q -s human_thought_exam.pl -- --input examples/texts/evolution.txt --mode oral --difficulty postgraduate
```

```bash
swipl -q -s human_thought_exam.pl -- --input examples/texts/kant_ethics.txt --mode computerless --questions 8 --output prolog
```

Use repeated `--input` arguments to compare sources. Add `--teacher` to print
teacher-only rubrics and outlines after the student examination:

```bash
swipl -q -s human_thought_exam.pl -- \
  --input examples/texts/caching.txt \
  --input examples/texts/evolution.txt \
  --mode synthesis --teacher
```

The `socratic` mode produces a question-only examination:

```bash
swipl -q -s human_thought_exam.pl -- --input examples/texts/caching.txt --mode socratic
```

### Run tests
```bash
swipl -q -g "run_tests, halt" -t halt tests/test_suite.pl
```

### Use from Prolog REPL
```prolog
?- [human_thought_exam].
?- text_exam("examples/texts/caching.txt", [mode(written), difficulty(undergraduate)], Exam).
```

## Remaining specification work

The current implementation is a deterministic, pattern-based prototype; it does
not yet satisfy every item in `pr1.txt`:

- Intellectual decomposition detects only a subset of the specified elements and
  uses keyword patterns rather than semantic analysis.
- Question dependencies and thought-unit coverage are not represented as explicit,
  validated relations; computerless mode adds a note but does not supply missing
  source context.
- Oral follow-ups are static templates: there is no live adaptive examiner,
  examiner-prompt system, or complexity-based response-time estimate.
- Socratic mode currently uses the ordinary ordered question set; it does not yet
  build a distinct discovery-guiding dialogue.
- Researcher, tutorial, revision, viva, and discipline-specific reasoning modes
  are not implemented as distinct workflows.
- Assignment options such as word limits, open-book policy, and reference policy
  are not enforced. Question difficulty currently caps the maximum level rather
  than changing question sophistication.
- The benchmark suite and full cross-discipline quality properties described in
  the specification are not present.
