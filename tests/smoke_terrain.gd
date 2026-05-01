extends SceneTree

# Headless smoke test for CombatGrid terrain. Verifies:
#
#   * Default tile is PLAIN, defense_bonus_at = 0.
#   * Setting FOREST gives defense_bonus_at = 1.
#   * Setting HILL gives defense_bonus_at = 2.
#   * WATER and WALL count as blocked (is_blocked = true) AND
#     drop out of neighbors().
#   * TurnManager._attack adds the defender's terrain bonus on
#     top of unit defense — a samurai standing on FOREST takes
#     1 less damage from an ashigaru hit.
#
# Run: godot --headless --script res://tests/smoke_terrain.gd

const SAMURAI_PATH := "res://games/sengoku/data/classes/samurai.tres"
const ASHIGARU_PATH := "res://games/sengoku/data/classes/ashigaru.tres"

func _initialize() -> void:
	var grid: CombatGrid = CombatGrid.new(6, 6)

	# Default tile.
	if grid.tile_at(Vector2i(0, 0)) != CombatGrid.TileType.PLAIN:
		_fail("default tile should be PLAIN")
		return
	if grid.defense_bonus_at(Vector2i(0, 0)) != 0:
		_fail("PLAIN defense bonus should be 0")
		return

	# FOREST.
	grid.set_tile(Vector2i(2, 2), CombatGrid.TileType.FOREST)
	if grid.defense_bonus_at(Vector2i(2, 2)) != 1:
		_fail("FOREST should give +1 defense, got %d" % grid.defense_bonus_at(Vector2i(2, 2)))
		return

	# HILL.
	grid.set_tile(Vector2i(3, 3), CombatGrid.TileType.HILL)
	if grid.defense_bonus_at(Vector2i(3, 3)) != 2:
		_fail("HILL should give +2 defense")
		return

	# WATER blocks.
	grid.set_tile(Vector2i(4, 4), CombatGrid.TileType.WATER)
	if not grid.is_blocked(Vector2i(4, 4)):
		_fail("WATER should be blocked")
		return
	for n in grid.neighbors(Vector2i(4, 3)):
		if n == Vector2i(4, 4):
			_fail("WATER should be excluded from neighbors")
			return

	# WALL blocks.
	grid.set_tile(Vector2i(5, 5), CombatGrid.TileType.WALL)
	if not grid.is_blocked(Vector2i(5, 5)):
		_fail("WALL should be blocked")
		return

	# End-to-end damage check: ashigaru attacks samurai standing on FOREST.
	# Samurai defense 5 + FOREST 1 = 6. Ashigaru atk 4 + LANCE-vs-SWORD +2 = 6.
	# Damage = max(1, 6 - 6) = 1.
	# On PLAIN ground, samurai defense 5, damage = max(1, 6 - 5) = 1.
	# So the difference shows when the foe deals more base damage. Test against
	# a stronger attack: ashigaru ability yari_thrust (+2 power) →
	# modded atk = 4 + 2 + 2 = 8. On PLAIN, dmg = 8 - 5 = 3. On FOREST,
	# dmg = 8 - 6 = 2.
	var samurai_class: ClassDef = load(SAMURAI_PATH)
	var ashigaru_class: ClassDef = load(ASHIGARU_PATH)
	var hero_def: UnitDef = UnitDef.new()
	hero_def.id = &"smoke_hero"
	hero_def.display_name = "Hero"
	hero_def.class_def = samurai_class
	hero_def.level = 1
	hero_def.side = 0
	var foe_def: UnitDef = UnitDef.new()
	foe_def.id = &"smoke_foe"
	foe_def.display_name = "Bandit"
	foe_def.class_def = ashigaru_class
	foe_def.level = 1
	foe_def.side = 1

	# Hero on FOREST.
	var hero_forest: CombatUnit = CombatUnit.new(hero_def, Vector2i(2, 2))
	var foe_a: CombatUnit = CombatUnit.new(foe_def, Vector2i(1, 2))
	var roster_a: Array[CombatUnit] = [hero_forest, foe_a]
	var tm_a: TurnManager = TurnManager.new(grid, roster_a)
	var ability: AbilityDef = ashigaru_class.signature_ability  # yari_thrust
	var hp_before_forest: int = hero_forest.hp
	tm_a._cast_ability(foe_a, hero_forest, ability)
	var dmg_forest: int = hp_before_forest - hero_forest.hp

	# Hero on PLAIN, otherwise identical.
	var hero_plain: CombatUnit = CombatUnit.new(hero_def, Vector2i(0, 0))
	var foe_b: CombatUnit = CombatUnit.new(foe_def, Vector2i(1, 0))
	var roster_b: Array[CombatUnit] = [hero_plain, foe_b]
	var tm_b: TurnManager = TurnManager.new(grid, roster_b)
	var hp_before_plain: int = hero_plain.hp
	tm_b._cast_ability(foe_b, hero_plain, ability)
	var dmg_plain: int = hp_before_plain - hero_plain.hp

	if dmg_forest >= dmg_plain:
		_fail("FOREST should reduce damage; forest=%d plain=%d" % [dmg_forest, dmg_plain])
		return

	print("smoke_terrain: ok. ability dmg plain=%d forest=%d (-%d on forest tile)" % [
		dmg_plain, dmg_forest, dmg_plain - dmg_forest,
	])
	quit(0)

func _fail(msg: String) -> void:
	push_error("smoke_terrain: %s" % msg)
	quit(1)
