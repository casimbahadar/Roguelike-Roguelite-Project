class_name EventDef
extends Resource

# A non-combat node's narrative beat: a title, a body of
# descriptive text, and 2-3 choices the player picks between.
# Each choice is an EventChoice with its own outcome text and
# small mechanical effect (gold / meta currency / party hp).
#
# Theme packs ship events as .tres files under
# games/<theme>/data/events/. Designers add events without
# touching code; the EventScreen reads whatever's in the
# selected EventDef.

@export var id: StringName
@export var display_name: String
@export_multiline var body: String
@export var choices: Array[EventChoice] = []

@export_group("Availability")
@export var act_min: int = 0
@export var act_max: int = 99
@export var weight: int = 10

func is_available_in_act(act: int) -> bool:
	return act >= act_min and act <= act_max
