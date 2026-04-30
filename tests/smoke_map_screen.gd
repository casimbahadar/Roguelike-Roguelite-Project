extends SceneTree

# Headless smoke test for MapScreen. Builds a RunState from
# skirmish.tres with a fixed seed, instances MapScreen.tscn,
# binds the run, and:
#
#   * asserts the row count matches map.size()
#   * presses the Continue button programmatically and verifies
#     run_state.current_node_index advances
#   * walks to the end and verifies the button disables on
#     run_complete
#
# Run: godot --headless --script res://tests/smoke_map_screen.gd

const SKIRMISH_PATH := "res://games/sengoku/data/runs/skirmish.tres"
const FIXED_SEED := 4242

func _initialize() -> void:
	var config: RunConfig = load(SKIRMISH_PATH)
	if config == null:
		_fail("failed to load %s" % SKIRMISH_PATH)
		return

	var party: Array[UnitDef] = []
	var run: RunState = RunState.new(config, FIXED_SEED, party)

	var scene: PackedScene = load("res://core/ui/map_screen.tscn")
	if scene == null:
		_fail("failed to load map_screen.tscn")
		return

	var screen: MapScreen = scene.instantiate()
	root.add_child(screen)
	screen.bind_run(run)

	if screen._list.get_child_count() != run.map.size():
		_fail("expected %d list rows, got %d" % [run.map.size(), screen._list.get_child_count()])
		return

	# Press Continue once and verify advance.
	var before: int = run.current_node_index
	screen._continue_btn.emit_signal("pressed")
	if run.current_node_index != before + 1:
		_fail("Continue should have advanced from %d to %d, got %d" % [before, before + 1, run.current_node_index])
		return

	# Walk to the end.
	var safety: int = 200
	while not run.is_run_complete() and safety > 0:
		screen._continue_btn.emit_signal("pressed")
		safety -= 1
	if not run.is_run_complete():
		_fail("never reached run completion within safety cap")
		return
	if not screen._continue_btn.disabled:
		_fail("ContinueBtn should be disabled after run completion")
		return

	print("smoke_map_screen: ok. walked %d nodes." % run.map.size())
	quit(0)

func _fail(msg: String) -> void:
	push_error("smoke_map_screen: %s" % msg)
	quit(1)
