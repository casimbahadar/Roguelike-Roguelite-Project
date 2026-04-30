extends SceneTree

# Headless smoke test for MapScreen with the branching picker.
# Builds a RunState from skirmish.tres with a fixed seed,
# instances MapScreen.tscn, binds the run, and:
#
#   * asserts the row count matches map.size()
#   * presses the first choice button and verifies advance
#   * walks to the end pressing the first choice each step,
#     verifies the picker empties on run completion
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

	if screen._choices.get_child_count() < 1:
		_fail("expected at least one choice button at start, got 0")
		return

	# Press the first choice once and verify advance.
	var before: int = run.current_node_index
	_press_first_choice(screen)
	if run.current_node_index == before:
		_fail("first choice should have advanced from %d, still there" % before)
		return

	# Walk to the end always taking the first choice.
	var safety: int = 200
	while not run.is_run_complete() and safety > 0:
		if screen._choices.get_child_count() < 1:
			_fail("no choice buttons mid-walk at node %d" % run.current_node_index)
			return
		_press_first_choice(screen)
		safety -= 1
	if not run.is_run_complete():
		_fail("never reached run completion within safety cap")
		return
	if screen._choices.get_child_count() != 0:
		_fail("Choices should be empty after run completion, got %d" % screen._choices.get_child_count())
		return

	print("smoke_map_screen: ok. walked %d nodes." % run.map.size())
	quit(0)

func _press_first_choice(screen: MapScreen) -> void:
	var btn: Node = screen._choices.get_child(0)
	btn.emit_signal("pressed")

func _fail(msg: String) -> void:
	push_error("smoke_map_screen: %s" % msg)
	quit(1)
