class_name BondDef
extends Resource

# A support-bond definition: a per-class progression that builds
# rank across runs. When the player completes a run with a unit
# of `class_id`, the matching bond ticks +1 (capped at MAX_RANK).
# At MAX_RANK the bond grants a permanent relic — applied to
# every future run for that class. This is the FE "supports persist"
# hook re-shaped for a single-unit slice; multi-unit pair-bonds
# layer on once parties are bigger.

const MAX_RANK: int = 2  # 0 = Acquaintance, 1 = Friend, 2 = Sworn

@export var id: StringName
@export var display_name: String
@export_multiline var description: String

# Bond progression hooks off the player's class id (ClassDef.id).
@export var class_id: StringName

# Awarded automatically while the bond is at MAX_RANK. Reuses the
# existing RelicDef machinery so the buff stacks with the run's
# normal relic pool — no parallel codepath.
@export var relic_at_max: RelicDef
