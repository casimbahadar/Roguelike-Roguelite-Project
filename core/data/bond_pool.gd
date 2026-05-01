class_name BondPool
extends Resource

# Set of bonds available to a single theme pack. Loaded from
# `ThemePack.bond_pool_path`. The pool is iterated whenever a run
# starts (to apply max-rank relics) and whenever a run completes
# (to advance rank for the player's class).

@export var id: StringName
@export var bonds: Array[BondDef] = []
