class_name MapDef
extends Resource

# A hand-crafted battlefield layout. tile_rows is an array of
# strings, one per grid row top-to-bottom, using a single
# character per tile:
#
#   .  PLAIN
#   F  FOREST
#   H  HILL
#   R  ROAD
#   W  WATER
#   X  WALL
#
# Designers author maps as plain text in a .tres file —
# readable, version-control-friendly. build_grid() turns the
# rows into a CombatGrid the encounter resolver can use.
#
# player_spawns and enemy_spawns list candidate placement
# tiles. Battle setup walks the lists in order, placing one
# unit per tile; trailing spawns are unused. If a roster is
# bigger than the spawn list, callers should fall back to a
# generic placement (Main does this for safety).

@export var id: StringName
@export var display_name: String
@export var tile_rows: Array[String] = []
@export var player_spawns: Array[Vector2i] = []
@export var enemy_spawns: Array[Vector2i] = []

func width() -> int:
	if tile_rows.is_empty():
		return 0
	return tile_rows[0].length()

func height() -> int:
	return tile_rows.size()

func build_grid() -> CombatGrid:
	var w: int = width()
	var h: int = height()
	var grid: CombatGrid = CombatGrid.new(w, h)
	for y in h:
		var row: String = tile_rows[y]
		for x in row.length():
			var c: String = row.substr(x, 1)
			grid.set_tile(Vector2i(x, y), _char_to_tile(c))
	return grid

static func _char_to_tile(c: String) -> int:
	match c:
		"F":
			return CombatGrid.TileType.FOREST
		"H":
			return CombatGrid.TileType.HILL
		"R":
			return CombatGrid.TileType.ROAD
		"W":
			return CombatGrid.TileType.WATER
		"X":
			return CombatGrid.TileType.WALL
		_:
			return CombatGrid.TileType.PLAIN
