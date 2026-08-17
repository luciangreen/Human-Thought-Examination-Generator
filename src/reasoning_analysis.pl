%% reasoning_analysis.pl
%% Identifies reasoning relationships between thought units.

:- module(reasoning_analysis, [
    derive_reasoning_relations/2
]).

%% derive_reasoning_relations(+ThoughtUnits, -Relations)
%% Relations = list of reasoning_rel(Type, UnitId1, UnitId2)
derive_reasoning_relations(ThoughtUnits, Relations) :-
    pairs_from_units(ThoughtUnits, Pairs),
    foldl(classify_pair, Pairs, [], Relations).

pairs_from_units(Units, Pairs) :-
    findall(A-B,
        (   member(A, Units),
            member(B, Units),
            A \= B,
            A = thought_unit(IdA, _, _),
            B = thought_unit(IdB, _, _),
            IdA @< IdB
        ),
        Pairs).

classify_pair(A-B, Acc, [Rel|Acc]) :-
    A = thought_unit(_IdA, TypeA, _),
    B = thought_unit(_IdB, TypeB, _),
    relation_type(TypeA, TypeB, RelType),
    !,
    Rel = reasoning_rel(RelType, A, B).
classify_pair(_, Acc, Acc).

%% relation_type(+TypeA, +TypeB, -RelationType)
relation_type(claim,      causal_explanation, supports).
relation_type(assumption, claim,              underpins).
relation_type(mechanism,  causal_explanation, elaborates).
relation_type(definition, claim,              defines_term_in).
relation_type(example,    claim,              instantiates).
relation_type(comparison, claim,              contrasts_with).
relation_type(assumption, mechanism,          constrains).
