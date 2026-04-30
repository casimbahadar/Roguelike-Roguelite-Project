class_name CombatUnit
extends RefCounted

# Minimal unit: identity, allegiance, three combat stats, and a tile.
# Stats are intentionally bare — no growths, no weapon triangle, no
# class system here. Those layer on later via .tres Resources.

var unit_name: String
var side: int
var max_hp: int
var hp: int
var atk: int
var defense: int
var pos: Vector2i

func _init(
	p_name: String,
	p_side: int,
	p_hp: int,
	p_atk: int,
	p_defense: int,
	p_pos: Vector2i
) -> void:
	unit_name = p_name
	side = p_side
	max_hp = p_hp
	hp = p_hp
	atk = p_atk
	defense = p_defense
	pos = p_pos

func is_alive() -> bool:
	return hp > 0

func take_damage(amount: int) -> void:
	hp = maxi(0, hp - amount)
