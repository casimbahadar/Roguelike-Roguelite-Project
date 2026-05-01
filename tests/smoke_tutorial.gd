extends SceneTree

# Headless smoke test for the tutorial scripted-layout path.
# Verifies that:
#
#   * tutorial.tres loads with scripted_node_kinds non-empty.
#   * MapGenerator returns a linear chain of exactly the
#     declared kinds, in order, single-act.
#   * Walking the run via nexts[0] reaches the BOSS at the
#     end and is_run_complete() flips true.
#
# Run: godot --headless --script res://tests/smoke_tutorial.gd

const TUTORIAL_PATH := "res://games/sengoku/data/runs/tutorial.tres"

func _initialize() -> void:
	var config: RunConfig = load(TUTORIAL_PATH)
	if config == null:
		_fail("failed to load %s" % TUTORIAL_PATH)
		return
	if config.scripted_node_kinds.is_empty():
		_fail("tutorial should declare scripted_node_kinds")
		return

	var map: Array[MapNode] = MapGenerator.build(config, config.fixed_seed)
	if map.size() != config.scripted_node_kinds.size():
		_fail("tutorial map size %d != scripted_node_kinds size %d" % [map.size(), config.scripted_node_kinds.size()])
		return

	for i in map.size():
		var node: MapNode = map[i]
		if node.kind != config.scripted_node_kinds[i]:
			_fail("node %d kind mismatch: expected %d got %d" % [i, config.scripted_node_kinds[i], node.kind])
			return
		if node.act != 0:
			_fail("scripted layout should be single-act; node %d has act=%d" % [i, node.act])
			return

	# Build a RunState and walk it.
	var party: Array[UnitDef] = []
	var run: RunState = RunState.new(config, config.fixed_seed, party)
	if run.current_node().kind != map[0].kind:
		_fail("RunState start node kind doesn't match map[0]")
		return

	var safety: int = 50
	while not run.is_run_complete() and safety > 0:
		var nexts: Array[int] = run.next_options()
		if nexts.is_empty():
			_fail("stuck mid-walk at index %d (kind %d)" % [run.current_node_index, run.current_node().kind])
			return
		run.advance_to(nexts[0])
		safety -= 1

	if not run.is_run_complete():
		_fail("never reached completion within safety cap")
		return
	if run.current_node().kind != MapNode.Kind.BOSS:
		_fail("tutorial should end on BOSS, got kind %d" % run.current_node().kind)
		return

	print("smoke_tutorial: ok. linear scripted layout walked %d nodes ending in BOSS." % map.size())
	quit(0)

func _fail(msg: String) -> void:
	push_error("smoke_tutorial: %s" % msg)
	quit(1)
