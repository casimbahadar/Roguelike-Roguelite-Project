class_name CombatGrid
extends RefCounted

# Square tile grid with 4-directional movement and per-tile
# terrain. Manhattan distance for pathing. Blocked tiles (WATER,
# WALL, or set via set_blocked) cannot be entered. Other terrain
# types modulate the defender's defense and movement cost into
# the tile.
#
# Tile-level data is intentionally simple — one TileType per
# tile, lookup tables for movement cost and defense bonus. More
# nuanced effects (forest grants stealth, hills raise sight
# range) layer on once their systems exist.

enum TileType {
	PLAIN,    # default, no modifier
	FOREST,   # +1 defense to a defender on the tile, costs 2 to enter
	HILL,     # +2 defense, costs 2 to enter
	ROAD,     # 0 defense, costs 1 (no advantage on a 1-cost grid; flavor)
	WATER,    # blocks movement entirely
	WALL,     # blocks movement entirely
}

const DEFENSE_BONUS: Dictionary = {
	TileType.PLAIN: 0,
	TileType.FOREST: 1,
	TileType.HILL: 2,
	TileType.ROAD: 0,
	TileType.WATER: 0,
	TileType.WALL: 0,
}

const MOVE_COST: Dictionary = {
	TileType.PLAIN: 1,
	TileType.FOREST: 2,
	TileType.HILL: 2,
	TileType.ROAD: 1,
	TileType.WATER: 99,
	TileType.WALL: 99,
}

var width: int
var height: int
var _tiles: Dictionary = {}    # Vector2i -> TileType (PLAIN if missing)
var _blocked: Dictionary = {}  # Vector2i -> true (legacy/manual block)

func _init(p_width: int, p_height: int) -> void:
	width = p_width
	height = p_height

func in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < width and p.y < height

func tile_at(p: Vector2i) -> int:
	return _tiles.get(p, TileType.PLAIN)

func set_tile(p: Vector2i, tile: int) -> void:
	if tile == TileType.PLAIN:
		_tiles.erase(p)
	else:
		_tiles[p] = tile

func is_blocked(p: Vector2i) -> bool:
	if _blocked.has(p):
		return true
	var t: int = tile_at(p)
	return t == TileType.WATER or t == TileType.WALL

func set_blocked(p: Vector2i, blocked: bool = true) -> void:
	if blocked:
		_blocked[p] = true
	else:
		_blocked.erase(p)

func defense_bonus_at(p: Vector2i) -> int:
	return DEFENSE_BONUS.get(tile_at(p), 0)

func move_cost_into(p: Vector2i) -> int:
	if not in_bounds(p) or is_blocked(p):
		return 99
	return MOVE_COST.get(tile_at(p), 1)

func neighbors(p: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var n: Vector2i = p + d
		if in_bounds(n) and not is_blocked(n):
			out.append(n)
	return out

func distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)
