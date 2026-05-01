extends SceneTree

# Headless smoke test for AiRanged. A yumi_archer (BOW, range 2..3,
# ai_kind=ranged) duels an ashigaru (LANCE, range 1..1, aggressive).
# The archer should kite, attack from 2-3 tiles, and win. We assert
# side 0 wins — the test fails if the archer ever gets cornered.
#
# Run: godot --headless --script res://tests/smoke_ranged.gd

const ARCHER_CLASS_PATH := "res://games/sengoku/data/classes/yumi_archer.tres"
const FOOT_CLASS_PATH := "res://games/sengoku/data/classes/ashigaru.tres"

func _initialize() -> void:
	var archer_class: ClassDef = load(ARCHER_CLASS_PATH)
	if archer_class == null:
		push_error("smoke_ranged: failed to load %s" % ARCHER_CLASS_PATH)
		quit(1)
		return
	var foot_class: ClassDef = load(FOOT_CLASS_PATH)
	if foot_class == null:
		push_error("smoke_ranged: failed to load %s" % FOOT_CLASS_PATH)
		quit(1)
		return

	var archer_def: UnitDef = UnitDef.new()
	archer_def.id = &"smoke_archer"
	archer_def.display_name = "Yumi Archer"
	archer_def.class_def = archer_class
	archer_def.level = 1
	archer_def.side = 0
	archer_def.ai_kind = "ranged"

	var foot_def: UnitDef = UnitDef.new()
	foot_def.id = &"smoke_foot"
	foot_def.display_name = "Ashigaru"
	foot_def.class_def = foot_class
	foot_def.level = 1
	foot_def.side = 1
	# ai_kind defaults to aggressive

	var grid: CombatGrid = CombatGrid.new(8, 8)
	var archer: CombatUnit = CombatUnit.new(archer_def, Vector2i(0, 3))
	var foot: CombatUnit = CombatUnit.new(foot_def, Vector2i(5, 3))

	var roster: Array[CombatUnit] = [archer, foot]
	var tm: TurnManager = TurnManager.new(grid, roster)

	var winner: int = tm.resolve(100)
	if winner == -1:
		push_error("smoke_ranged: no winner within turn cap (archer hp=%d, foot hp=%d)" % [archer.hp, foot.hp])
		quit(1)
		return
	if winner != 0:
		push_error("smoke_ranged: archer should win, got side %d (archer hp=%d, foot hp=%d)" % [winner, archer.hp, foot.hp])
		quit(1)
		return

	print("smoke_ranged: archer wins. archer hp=%d, foot hp=%d" % [archer.hp, foot.hp])
	quit(0)
