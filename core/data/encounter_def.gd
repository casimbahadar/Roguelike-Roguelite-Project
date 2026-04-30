class_name EncounterDef
extends Resource

# A battle scenario — what the player fights at a combat node.
# Owns the roster of opposing units; the player party stays
# consistent across encounters so RunState supplies that.
#
# Encounters are tagged by kind so the EncounterPool can serve
# the right kind of fight per MapNode.Kind. act_min/act_max gate
# encounter availability — early acts shouldn't pull act-2 elite
# rosters, and act-3 routine battles shouldn't be a single
# bandit recruit.

@export var id: StringName
@export var display_name: String
@export_enum("BATTLE", "ELITE", "BOSS") var encounter_kind: String = "BATTLE"
@export var enemies: Array[UnitDef] = []

@export_group("Availability")
@export var act_min: int = 0       # first act this encounter can appear in
@export var act_max: int = 99      # last act this encounter can appear in
@export var weight: int = 10       # picker weight; higher = more common

func is_available_in_act(act: int) -> bool:
	return act >= act_min and act <= act_max
