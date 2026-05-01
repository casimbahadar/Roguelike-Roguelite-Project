class_name BattlefieldTemplate
extends Resource

# Procedural-map shape config. The BattlefieldGenerator
# (helper, lower in this file via a static method) uses these
# numbers to produce a CombatGrid for combat nodes that aren't
# tied to a specific MapDef. Theme packs ship a few templates
# and let the encounter resolver pick by node kind.

@export var id: StringName
@export var display_name: String

@export_group("Size")
@export var width: int = 7
@export var height: int = 7

@export_group("Terrain density (0.0 - 1.0)")
@export_range(0.0, 1.0) var forest_density: float = 0.10
@export_range(0.0, 1.0) var hill_density: float = 0.05
@export_range(0.0, 1.0) var water_density: float = 0.0
@export_range(0.0, 1.0) var wall_density: float = 0.0

@export_group("Spawn margin (tiles)")
# How far from the edges player and enemy spawn rows sit. Lower
# values pull them closer to the center; higher values keep the
# arena open between the two sides.
@export var spawn_inset: int = 0

# Build a CombatGrid from this template. spawn rows are kept
# free of terrain so unit placement always succeeds.
func build_grid(rng: RandomNumberGenerator) -> CombatGrid:
	var grid: CombatGrid = CombatGrid.new(width, height)
	var safe_top: int = spawn_inset
	var safe_bottom: int = height - 1 - spawn_inset

	for y in height:
		var on_safe_row: bool = (y == safe_top) or (y == safe_bottom)
		for x in width:
			if on_safe_row:
				continue
			var tile: int = _roll_tile(rng)
			if tile != CombatGrid.TileType.PLAIN:
				grid.set_tile(Vector2i(x, y), tile)
	return grid

func _roll_tile(rng: RandomNumberGenerator) -> int:
	var r: float = rng.randf()
	var threshold: float = 0.0
	threshold += wall_density
	if r < threshold:
		return CombatGrid.TileType.WALL
	threshold += water_density
	if r < threshold:
		return CombatGrid.TileType.WATER
	threshold += hill_density
	if r < threshold:
		return CombatGrid.TileType.HILL
	threshold += forest_density
	if r < threshold:
		return CombatGrid.TileType.FOREST
	return CombatGrid.TileType.PLAIN

# Default spawn lists for procedural maps: a small column on
# each side along the safe rows. Callers ask for exactly the
# count they need.
func default_player_spawns(count: int) -> Array[Vector2i]:
	return _spawns_along(height - 1 - spawn_inset, count)

func default_enemy_spawns(count: int) -> Array[Vector2i]:
	return _spawns_along(spawn_inset, count)

func _spawns_along(y: int, count: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for x in width:
		if out.size() >= count:
			break
		out.append(Vector2i(x, y))
	return out
