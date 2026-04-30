class_name CombatGrid
extends RefCounted

# Square tile grid with 4-directional movement. Manhattan distance.
# Blocked tiles are intentionally a separate concept from occupied
# tiles — terrain is grid-owned, occupancy is unit-owned.

var width: int
var height: int
var _blocked: Dictionary = {}

func _init(p_width: int, p_height: int) -> void:
	width = p_width
	height = p_height

func in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < width and p.y < height

func is_blocked(p: Vector2i) -> bool:
	return _blocked.has(p)

func set_blocked(p: Vector2i, blocked: bool = true) -> void:
	if blocked:
		_blocked[p] = true
	else:
		_blocked.erase(p)

func neighbors(p: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var n: Vector2i = p + d
		if in_bounds(n) and not is_blocked(n):
			out.append(n)
	return out

func distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)
