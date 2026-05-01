extends SceneTree

# Headless smoke test. Loads two ClassDef .tres files from disk
# (proving the data pipeline works) and resolves a 2-unit duel.
# Run: godot --headless --script res://tests/smoke_combat.gd
# Exits 0 on a clean win, non-zero on failure.

const HERO_CLASS_PATH := "res://games/sengoku/data/classes/samurai.tres"
const ENEMY_CLASS_PATH := "res://games/sengoku/data/classes/ashigaru.tres"

func _initialize() -> void:
	var hero_class: ClassDef = load(HERO_CLASS_PATH)
	if hero_class == null:
		push_error("smoke_combat: failed to load %s" % HERO_CLASS_PATH)
		quit(1)
		return
	var enemy_class: ClassDef = load(ENEMY_CLASS_PATH)
	if enemy_class == null:
		push_error("smoke_combat: failed to load %s" % ENEMY_CLASS_PATH)
		quit(1)
		return

	var hero_def: UnitDef = UnitDef.new()
	hero_def.id = &"smoke_hero"
	hero_def.display_name = "Hero"
	hero_def.class_def = hero_class
	hero_def.level = 1
	hero_def.side = 0

	var bandit_def: UnitDef = UnitDef.new()
	bandit_def.id = &"smoke_bandit"
	bandit_def.display_name = "Bandit"
	bandit_def.class_def = enemy_class
	bandit_def.level = 1
	bandit_def.side = 1

	var grid: CombatGrid = CombatGrid.new(6, 6)
	var hero: CombatUnit = CombatUnit.new(hero_def, Vector2i(0, 0))
	var bandit: CombatUnit = CombatUnit.new(bandit_def, Vector2i(5, 5))

	var roster: Array[CombatUnit] = [hero, bandit]
	var tm: TurnManager = TurnManager.new(grid, roster)

	var winner: int = tm.resolve(100)

	if winner == -1:
		push_error("smoke_combat: no winner within turn cap (hero hp=%d, bandit hp=%d)" % [hero.hp, bandit.hp])
		quit(1)
		return

	print("smoke_combat: side %d wins. hero(%s) hp=%d, bandit(%s) hp=%d" % [
		winner,
		hero_class.display_name, hero.hp,
		enemy_class.display_name, bandit.hp,
	])
	quit(0)
