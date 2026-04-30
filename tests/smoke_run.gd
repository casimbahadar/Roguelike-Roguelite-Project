extends SceneTree

# Headless smoke test for the run loop. Loads standard.tres (a
# multi-act RunConfig), builds a RunState with a fixed seed, and
# walks the map node-by-node until is_run_complete(). Asserts:
#
#   * first node is a BATTLE
#   * starting revive tokens match the policy (ONE_PER_RUN → 1)
#   * each step calls advance_to() with a legal next index
#   * the run completes on a BOSS node in the final act
#
# Combat at each node is out of scope here — RunState is a graph
# walker; the combat smoke tests cover the in-fight path.
#
# Run: godot --headless --script res://tests/smoke_run.gd

const RUN_CONFIG_PATH := "res://games/sengoku/data/runs/standard.tres"
const FIXED_SEED := 12345
const MAX_WALK := 200

func _initialize() -> void:
	var config: RunConfig = load(RUN_CONFIG_PATH)
	if config == null:
		push_error("smoke_run: failed to load %s" % RUN_CONFIG_PATH)
		quit(1)
		return

	var party: Array[UnitDef] = []
	var run: RunState = RunState.new(config, FIXED_SEED, party)

	if run.current_node_index != 0:
		push_error("smoke_run: expected start index 0, got %d" % run.current_node_index)
		quit(1)
		return
	if run.current_node().kind != MapNode.Kind.BATTLE:
		push_error("smoke_run: first node should be BATTLE, got kind=%d" % run.current_node().kind)
		quit(1)
		return
	if run.revive_tokens != 1:
		push_error("smoke_run: expected 1 revive token (ONE_PER_RUN), got %d" % run.revive_tokens)
		quit(1)
		return

	var visited: int = 1
	while not run.is_run_complete():
		var nexts: Array[int] = run.next_options()
		if nexts.is_empty():
			push_error("smoke_run: stuck at index %d (act %d, kind %d)" % [
				run.current_node_index, run.current_act(), run.current_node().kind,
			])
			quit(1)
			return
		if not run.advance_to(nexts[0]):
			push_error("smoke_run: advance_to(%d) refused" % nexts[0])
			quit(1)
			return
		visited += 1
		if visited > MAX_WALK:
			push_error("smoke_run: walked > %d nodes without completing" % MAX_WALK)
			quit(1)
			return

	if run.current_node().kind != MapNode.Kind.BOSS:
		push_error("smoke_run: last node should be BOSS")
		quit(1)
		return
	if run.current_act() != config.act_count - 1:
		push_error("smoke_run: should end on final act %d, got %d" % [config.act_count - 1, run.current_act()])
		quit(1)
		return

	print("smoke_run: %s completed. nodes=%d, acts=%d, final boss act=%d, revives=%d" % [
		config.id, visited, config.act_count, run.current_act(), run.revive_tokens,
	])
	quit(0)
