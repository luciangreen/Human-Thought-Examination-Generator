%% concept_extraction.pl
%% Extracts intellectual elements from classified sentences.

:- module(concept_extraction, [
    extract_thought_units/2,
    thought_unit_type/2
]).

:- use_module(text_analysis).

%% extract_thought_units(+Analysis, -ThoughtUnits)
%% Analysis = analysis(Words, Sentences, Paragraphs)
%% ThoughtUnits = list of thought_unit(Id, Type, Content)
extract_thought_units(analysis(_Words, Sentences, _Paragraphs), ThoughtUnits) :-
    extract_units_from_sentences(Sentences, 1, ThoughtUnits).

extract_units_from_sentences([], _, []).
extract_units_from_sentences([S|Ss], N, [Unit|Units]) :-
    classify_sentence(S, Class),
    map_class_to_unit_type(Class, UnitType),
    atom_concat(t, N, Id),
    Unit = thought_unit(Id, UnitType, S),
    N1 is N + 1,
    extract_units_from_sentences(Ss, N1, Units).

map_class_to_unit_type(definition,  definition).
map_class_to_unit_type(example,     example).
map_class_to_unit_type(assumption,  assumption).
map_class_to_unit_type(conclusion,  causal_explanation).
map_class_to_unit_type(mechanism,   mechanism).
map_class_to_unit_type(comparison,  comparison).
map_class_to_unit_type(claim,       claim).

%% thought_unit_type(?Type, ?Description)
thought_unit_type(definition,        "states what a term means").
thought_unit_type(claim,             "asserts a proposition").
thought_unit_type(assumption,        "takes something for granted").
thought_unit_type(causal_explanation,"explains a cause-effect relationship").
thought_unit_type(mechanism,         "describes a causal process").
thought_unit_type(example,           "provides a concrete instance").
thought_unit_type(comparison,        "contrasts two or more things").
thought_unit_type(counterargument,   "challenges a position").
thought_unit_type(evidence,          "supports a claim with data or observation").
thought_unit_type(implication,       "draws a consequence from a condition").
