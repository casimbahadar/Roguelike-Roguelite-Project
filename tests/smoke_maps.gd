extends SceneTree

# Headless smoke test for MapDef + BattlefieldTemplate. Verifies:
#
#   * Each of the six hand-crafted maps loads.
#   * build_grid() produces a CombatGrid with width/height
#     matching tile_rows.
#   * Tile-character interpretation is correct (FOREST tile in
#     forest_road row 0 col 0 should read as FOREST).
#   * Each template loads and build_grid produces a grid with
#     declared width/height and at least the spawn rows clear.
#
# Run: godot --headless --script res://tests/smoke_maps.gd

const MAP_PATHS: Array[String] = [
	"res://games/sengoku/data/maps/forest_road.tres",
	"res://games/sengoku/data/maps/river_crossing.tres",
	"res://games/sengoku/data/maps/hill_redoubt.tres",
	"res://games/sengoku/data/maps/ruined_temple.tres",
	"res://games/sengoku/data/maps/open_plain.tres",
	"res://games/sengoku/data/maps/mountain_pass.tres",
]
const TEMPLATE_PATHS: Array[String] = [
	"res://games/sengoku/data/maps/template_open.tres",
	"res://games/sengoku/data/maps/template_dense.tres",
	"res://games/sengoku/data/maps/template_choke.tres",
]

func _initialize() -> void:
	for path in MAP_PATHS:
		var m: MapDef = load(path)
		if m == null:
			_fail("failed to load %s" % path)
			return
		var grid: CombatGrid = m.build_grid()
		if grid.width != m.width():
			_fail("%s: grid width %d != map width %d" % [path, grid.width, m.width()])
			return
		if grid.height != m.height():
			_fail("%s: grid height %d != map height %d" % [path, grid.height, m.height()])
			return

	# Spot-check forest_road tile interpretation.
	var forest_road: MapDef = load(MAP_PATHS[0])
	var fr_grid: CombatGrid = forest_road.build_grid()
	if fr_grid.tile_at(Vector2i(0, 0)) != CombatGrid.TileType.FOREST:
		_fail("forest_road (0,0) should be FOREST, got %d" % fr_grid.tile_at(Vector2i(0, 0)))
		return
	if fr_grid.tile_at(Vector2i(2, 0)) != CombatGrid.TileType.ROAD:
		_fail("forest_road (2,0) should be ROAD, got %d" % fr_grid.tile_at(Vector2i(2, 0)))
		return

	# Verify river_crossing has water tiles where the layout says so.
	var river: MapDef = load(MAP_PATHS[1])
	var rv_grid: CombatGrid = river.build_grid()
	if not rv_grid.is_blocked(Vector2i(0, 2)):
		_fail("river_crossing (0,2) should be WATER (blocked), got tile %d" % rv_grid.tile_at(Vector2i(0, 2)))
		return

	# Templates produce grids of the declared size with spawn rows clear.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 9001
	for path in TEMPLATE_PATHS:
		var t: BattlefieldTemplate = load(path)
		if t == null:
			_fail("failed to load %s" % path)
			return
		var grid: CombatGrid = t.build_grid(rng)
		if grid.width != t.width or grid.height != t.height:
			_fail("%s: built grid size mismatch" % path)
			return
		# Top and bottom safe rows should have only PLAIN tiles.
		var safe_top: int = t.spawn_inset
		var safe_bottom: int = t.height - 1 - t.spawn_inset
		for x in t.width:
			if grid.tile_at(Vector2i(x, safe_top)) != CombatGrid.TileType.PLAIN:
				_fail("%s: top safe row not PLAIN at x=%d" % [path, x])
				return
			if grid.tile_at(Vector2i(x, safe_bottom)) != CombatGrid.TileType.PLAIN:
				_fail("%s: bottom safe row not PLAIN at x=%d" % [path, x])
				return

	print("smoke_maps: ok. 6 hand-crafted maps load + 3 templates produce sized grids with clear spawn rows.")
	quit(0)

func _fail(msg: String) -> void:
	push_error("smoke_maps: %s" % msg)
	quit(1)
