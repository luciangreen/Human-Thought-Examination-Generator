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

### Run tests
```bash
swipl -q -g "run_tests, halt" -t halt tests/test_suite.pl
```

### Use from Prolog REPL
```prolog
?- [human_thought_exam].
?- text_exam("examples/texts/caching.txt", [mode(written), difficulty(undergraduate)], Exam).
```
