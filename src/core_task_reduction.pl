%% core_task_reduction.pl
%% Maps thought units to the smallest set of core intellectual tasks.

:- module(core_task_reduction, [
    derive_core_tasks/2
]).

%% derive_core_tasks(+ThoughtUnits, -Tasks)
%% Tasks = list of core_task(TaskType, ThoughtUnits)
derive_core_tasks(ThoughtUnits, Tasks) :-
    group_by_task(ThoughtUnits, Grouped),
    maplist(make_task, Grouped, Tasks).

group_by_task(Units, Grouped) :-
    foldl(assign_unit_to_task, Units, [], Grouped).

assign_unit_to_task(thought_unit(Id, Type, Content), Acc, Acc1) :-
    unit_type_to_task(Type, Task),
    ( select(Task-Units, Acc, Rest)
    -> Acc1 = [Task-[thought_unit(Id, Type, Content)|Units]|Rest]
    ;  Acc1 = [Task-[thought_unit(Id, Type, Content)]|Acc]
    ).

make_task(Task-Units, core_task(Task, Units)).

%% unit_type_to_task(+UnitType, -CoreTask)
unit_type_to_task(definition,        identify_assumptions).
unit_type_to_task(claim,             derive_conclusion).
unit_type_to_task(assumption,        identify_assumptions).
unit_type_to_task(causal_explanation,explain_mechanism).
unit_type_to_task(mechanism,         explain_mechanism).
unit_type_to_task(example,           apply_rule).
unit_type_to_task(comparison,        compare_models).
unit_type_to_task(counterargument,   criticise_argument).
unit_type_to_task(evidence,          evaluate_evidence).
unit_type_to_task(implication,       predict_consequences).

%% unit_type_to_task(+UnitType, -CoreTask)
unit_type_to_task(definition,        identify_assumptions).
unit_type_to_task(claim,             derive_conclusion).
unit_type_to_task(assumption,        identify_assumptions).
unit_type_to_task(causal_explanation,explain_mechanism).
unit_type_to_task(mechanism,         explain_mechanism).
unit_type_to_task(example,           apply_rule).
unit_type_to_task(comparison,        compare_models).
unit_type_to_task(counterargument,   criticise_argument).
unit_type_to_task(evidence,          evaluate_evidence).
unit_type_to_task(implication,       predict_consequences).
