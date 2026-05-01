class_name EventChoice
extends Resource

# One option in an EventDef. The label is the button text; the
# outcome_text is shown after the player picks. Effects are
# applied immediately to the active RunState.
#
# Effects intentionally start simple — gold, meta currency,
# party hp. Recruit / relic / status effects layer on later as
# their systems exist.

@export var label: String
@export var outcome_text: String

@export_group("Effects")
@export var gold_delta: int = 0           # added to RunState.gold
@export var meta_currency_delta: int = 0  # added to MetaState.meta_currency
@export var party_hp_delta: int = 0       # applied to every alive party UnitDef hp ratio (clamped)
