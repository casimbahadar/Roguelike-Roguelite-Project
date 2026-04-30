class_name CombatUnit
extends RefCounted

# Runtime combat instance built from a UnitDef. The UnitDef is the
# data (identity, class, growths); the CombatUnit holds the live
# state for a battle (hp, position). Side is taken from the def
# but can be overridden — useful for charm / recruit / persuade.

var unit_def: UnitDef
var side: int
var hp: int
var pos: Vector2i

func _init(p_def: UnitDef, p_pos: Vector2i, p_side_override: int = -1) -> void:
	unit_def = p_def
	side = p_side_override if p_side_override >= 0 else p_def.side
	hp = p_def.max_hp()
	pos = p_pos

func unit_name() -> String:
	return unit_def.display_name

func max_hp() -> int:
	return unit_def.max_hp()

func atk() -> int:
	return unit_def.atk()

func defense() -> int:
	return unit_def.defense()

func is_alive() -> bool:
	return hp > 0

func take_damage(amount: int) -> void:
	hp = maxi(0, hp - amount)
