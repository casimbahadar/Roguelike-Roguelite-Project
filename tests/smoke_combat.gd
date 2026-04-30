extends SceneTree

# Headless smoke test for the combat primitives, now data-driven.
# Run: godot --headless --script res://tests/smoke_combat.gd
# Exits 0 on a clean win, non-zero on failure (timeout or mutual KO).

func _initialize() -> void:
	var grid: CombatGrid = CombatGrid.new(6, 6)

	var hero_class: ClassDef = ClassDef.new()
	hero_class.id = &"smoke_hero_class"
	hero_class.display_name = "SmokeHeroClass"
	hero_class.theme = &"shared"
	hero_class.base_hp = 12
	hero_class.base_atk = 4
	hero_class.base_defense = 1
	hero_class.base_speed = 5

	var hero_def: UnitDef = UnitDef.new()
	hero_def.id = &"smoke_hero"
	hero_def.display_name = "Hero"
	hero_def.class_def = hero_class
	hero_def.level = 1
	hero_def.side = 0

	var bandit_class: ClassDef = ClassDef.new()
	bandit_class.id = &"smoke_bandit_class"
	bandit_class.display_name = "SmokeBanditClass"
	bandit_class.theme = &"shared"
	bandit_class.base_hp = 8
	bandit_class.base_atk = 3
	bandit_class.base_defense = 1
	bandit_class.base_speed = 4

	var bandit_def: UnitDef = UnitDef.new()
	bandit_def.id = &"smoke_bandit"
	bandit_def.display_name = "Bandit"
	bandit_def.class_def = bandit_class
	bandit_def.level = 1
	bandit_def.side = 1

	var hero: CombatUnit = CombatUnit.new(hero_def, Vector2i(0, 0))
	var bandit: CombatUnit = CombatUnit.new(bandit_def, Vector2i(5, 5))

	var roster: Array[CombatUnit] = [hero, bandit]
	var tm: TurnManager = TurnManager.new(grid, roster)

	var winner: int = tm.resolve(100)

	if winner == -1:
		push_error("smoke_combat: no winner within turn cap (hero hp=%d, bandit hp=%d)" % [hero.hp, bandit.hp])
		quit(1)
		return

	print("smoke_combat: side %d wins. hero hp=%d, bandit hp=%d" % [winner, hero.hp, bandit.hp])
	quit(0)
