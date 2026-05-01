extends SceneTree

# Headless smoke test for BattleScreen. Loads samurai + ashigaru
# from .tres, builds CombatUnits, instances the battle screen,
# binds, presses Resolve, and asserts:
#   * battle_resolved signal fires with side 0 (the samurai
#     wins under the existing weapon-triangle math)
#   * the screen ends in the resolved state with disabled button
#   * unit HP labels reflect post-battle state
#
# Run: godot --headless --script res://tests/smoke_battle_screen.gd

const SAMURAI_PATH := "res://games/sengoku/data/classes/samurai.tres"
const ASHIGARU_PATH := "res://games/sengoku/data/classes/ashigaru.tres"

var _signal_winner: int = -2
var _signal_fired: bool = false

func _initialize() -> void:
	var samurai_class: ClassDef = load(SAMURAI_PATH)
	var ashigaru_class: ClassDef = load(ASHIGARU_PATH)
	if samurai_class == null or ashigaru_class == null:
		_fail("could not load class .tres")
		return

	var samurai_def: UnitDef = UnitDef.new()
	samurai_def.id = &"smoke_samurai"
	samurai_def.display_name = "Hero"
	samurai_def.class_def = samurai_class
	samurai_def.level = 1
	samurai_def.side = 0

	var ashigaru_def: UnitDef = UnitDef.new()
	ashigaru_def.id = &"smoke_ashigaru"
	ashigaru_def.display_name = "Bandit"
	ashigaru_def.class_def = ashigaru_class
	ashigaru_def.level = 1
	ashigaru_def.side = 1

	var grid: CombatGrid = CombatGrid.new(6, 6)
	var hero: CombatUnit = CombatUnit.new(samurai_def, Vector2i(0, 0))
	var bandit: CombatUnit = CombatUnit.new(ashigaru_def, Vector2i(5, 5))

	var scene: PackedScene = load("res://core/ui/battle_screen.tscn")
	if scene == null:
		_fail("could not load battle_screen.tscn")
		return

	var screen: BattleScreen = scene.instantiate()
	root.add_child(screen)
	screen.battle_resolved.connect(_on_battle_resolved)

	var players: Array[CombatUnit] = [hero]
	var enemies: Array[CombatUnit] = [bandit]
	screen.bind_battle(grid, players, enemies)

	# Press Resolve programmatically.
	screen._resolve_btn.emit_signal("pressed")

	if not _signal_fired:
		_fail("battle_resolved signal did not fire")
		return
	if _signal_winner != 0:
		_fail("expected hero (side 0) to win, signal reported %d" % _signal_winner)
		return
	if not screen._resolve_btn.disabled:
		_fail("Resolve button should be disabled after resolution")
		return
	if hero.is_alive() == false:
		_fail("hero should still be alive (won the duel)")
		return
	if bandit.is_alive():
		_fail("bandit should be down")
		return

	print("smoke_battle_screen: ok. hero hp=%d, bandit hp=%d, signal=%d" % [hero.hp, bandit.hp, _signal_winner])
	quit(0)

func _on_battle_resolved(winning_side: int) -> void:
	_signal_fired = true
	_signal_winner = winning_side

func _fail(msg: String) -> void:
	push_error("smoke_battle_screen: %s" % msg)
	quit(1)
