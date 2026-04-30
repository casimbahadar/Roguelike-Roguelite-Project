extends SceneTree

# Headless smoke test for the combat primitives.
# Run: godot --headless --script res://tests/smoke_combat.gd
# Exits 0 on a clean win, non-zero on failure (timeout or mutual KO).

func _initialize() -> void:
	var grid: CombatGrid = CombatGrid.new(6, 6)

	var hero: CombatUnit = CombatUnit.new("Hero", 0, 12, 4, 1, Vector2i(0, 0))
	var bandit: CombatUnit = CombatUnit.new("Bandit", 1, 8, 3, 1, Vector2i(5, 5))

	var roster: Array[CombatUnit] = [hero, bandit]
	var tm: TurnManager = TurnManager.new(grid, roster)

	var winner: int = tm.resolve(100)

	if winner == -1:
		push_error("smoke_combat: no winner within turn cap (hero hp=%d, bandit hp=%d)" % [hero.hp, bandit.hp])
		quit(1)
		return

	print("smoke_combat: side %d wins. hero hp=%d, bandit hp=%d" % [winner, hero.hp, bandit.hp])
	quit(0)
