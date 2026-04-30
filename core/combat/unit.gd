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

# Per-battle stat buffs aggregated from relics, supports, and
# event payoffs. Set once at battle setup via apply_buffs().
# Enemies leave them at zero (the slice doesn't apply enemy
# buffs; later difficulty modifiers can use the same hook).
var buff_atk: int = 0
var buff_defense: int = 0
var buff_max_hp: int = 0

func _init(p_def: UnitDef, p_pos: Vector2i, p_side_override: int = -1) -> void:
	unit_def = p_def
	side = p_side_override if p_side_override >= 0 else p_def.side
	hp = p_def.max_hp()
	pos = p_pos

# Apply party-level stat buffs and refill HP to the new max.
# Idempotent: calling twice with the same values yields the same
# state, since buff_* simply replace prior values.
func apply_buffs(p_buff_atk: int, p_buff_defense: int, p_buff_max_hp: int) -> void:
	buff_atk = p_buff_atk
	buff_defense = p_buff_defense
	buff_max_hp = p_buff_max_hp
	hp = max_hp()

func unit_name() -> String:
	return unit_def.display_name

func max_hp() -> int:
	return unit_def.max_hp() + buff_max_hp

func atk() -> int:
	return unit_def.atk() + buff_atk

func defense() -> int:
	return unit_def.defense() + buff_defense

func weapon_type() -> String:
	return unit_def.class_def.weapon_type

func is_alive() -> bool:
	return hp > 0

func take_damage(amount: int) -> void:
	hp = maxi(0, hp - amount)
