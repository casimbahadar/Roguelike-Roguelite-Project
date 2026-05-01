extends SceneTree

# Headless smoke test for the branching MapGenerator. Builds a
# map from standard.tres with a fixed seed and verifies the
# structural invariants:
#
#   * Each act starts with exactly one BATTLE node (row 0).
#   * Each act ends with exactly one BOSS node (row N-1).
#   * Every node except the final-act boss has >= 1 outgoing edge.
#   * Cross-act links: each non-final boss points to the next act's
#     row-0 node.
#   * Edges within an act are non-crossing (source-column order
#     matches target-column order).
#   * Map has more than one path from start to end (true branching).
#
# Run: godot --headless --script res://tests/smoke_branching_map.gd

const RUN_CONFIG_PATH := "res://games/sengoku/data/runs/standard.tres"
const FIXED_SEED := 7777

func _initialize() -> void:
	var config: RunConfig = load(RUN_CONFIG_PATH)
	if config == null:
		_fail("failed to load %s" % RUN_CONFIG_PATH)
		return

	var map: Array[MapNode] = MapGenerator.build(config, FIXED_SEED)
	if map.is_empty():
		_fail("MapGenerator returned an empty map")
		return

	# Bucket nodes by act and depth for invariant checks.
	var by_act_depth: Dictionary = {}  # act -> {depth -> [indices]}
	for i in map.size():
		var n: MapNode = map[i]
		if not by_act_depth.has(n.act):
			by_act_depth[n.act] = {}
		var depth_map: Dictionary = by_act_depth[n.act]
		if not depth_map.has(n.depth):
			depth_map[n.depth] = []
		depth_map[n.depth].append(i)

	if by_act_depth.size() != config.act_count:
		_fail("expected %d acts, got %d" % [config.act_count, by_act_depth.size()])
		return

	# Check each act's structural invariants.
	for act in by_act_depth.keys():
		var depth_map: Dictionary = by_act_depth[act]
		var max_depth: int = 0
		for d in depth_map.keys():
			if d > max_depth:
				max_depth = d

		# Row 0: exactly one BATTLE.
		var row0: Array = depth_map[0]
		if row0.size() != 1:
			_fail("act %d row 0 should have 1 node, got %d" % [act, row0.size()])
			return
		if map[row0[0]].kind != MapNode.Kind.BATTLE:
			_fail("act %d row 0 should be BATTLE, got %d" % [act, map[row0[0]].kind])
			return

		# Last row: exactly one BOSS.
		var last_row: Array = depth_map[max_depth]
		if last_row.size() != 1:
			_fail("act %d last row should have 1 node, got %d" % [act, last_row.size()])
			return
		if map[last_row[0]].kind != MapNode.Kind.BOSS:
			_fail("act %d last row should be BOSS, got %d" % [act, map[last_row[0]].kind])
			return

		# Non-crossing edges within the act.
		for d in range(max_depth):
			var src_indices: Array = depth_map[d]
			# Sort by column for left-to-right traversal.
			src_indices.sort_custom(func(a, b): return map[a].column < map[b].column)
			var prev_max_target_col: int = -1
			for src in src_indices:
				if map[src].next_indices.is_empty():
					_fail("act %d depth %d col %d has no outgoing edges" % [act, d, map[src].column])
					return
				var min_target_col: int = 1 << 30
				var max_target_col: int = -1
				for nxt in map[src].next_indices:
					var tc: int = map[nxt].column
					min_target_col = mini(min_target_col, tc)
					max_target_col = maxi(max_target_col, tc)
				if min_target_col < prev_max_target_col:
					_fail("crossing edge: act %d depth %d col %d targets col %d, but prior source already targeted col %d" % [
						act, d, map[src].column, min_target_col, prev_max_target_col,
					])
					return
				prev_max_target_col = max_target_col

	# Final-act boss has empty next_indices; non-final-act bosses link to next act's row 0.
	var final_act: int = config.act_count - 1
	var final_boss_idx: int = by_act_depth[final_act][_max_depth_in(by_act_depth[final_act])][0]
	if not map[final_boss_idx].next_indices.is_empty():
		_fail("final-act boss should have no outgoing edges, got %d" % map[final_boss_idx].next_indices.size())
		return
	for a in range(final_act):
		var act_max_d: int = _max_depth_in(by_act_depth[a])
		var boss_idx: int = by_act_depth[a][act_max_d][0]
		var nexts: Array[int] = map[boss_idx].next_indices
		if nexts.size() != 1:
			_fail("act %d boss should link to exactly one next-act node, got %d" % [a, nexts.size()])
			return
		var target: MapNode = map[nexts[0]]
		if target.act != a + 1 or target.depth != 0:
			_fail("act %d boss should link to act %d row 0, got act=%d depth=%d" % [
				a, a + 1, target.act, target.depth,
			])
			return

	# True branching: at least one act has at least one row with width > 1.
	var has_branching: bool = false
	for act in by_act_depth.keys():
		var depth_map: Dictionary = by_act_depth[act]
		for d in depth_map.keys():
			if depth_map[d].size() > 1:
				has_branching = true
				break
		if has_branching:
			break
	if not has_branching:
		_fail("expected at least one row with multiple lanes; got fully linear map")
		return

	print("smoke_branching_map: ok. acts=%d, total_nodes=%d" % [config.act_count, map.size()])
	quit(0)

func _max_depth_in(depth_map: Dictionary) -> int:
	var m: int = 0
	for d in depth_map.keys():
		if d > m:
			m = d
	return m

func _fail(msg: String) -> void:
	push_error("smoke_branching_map: %s" % msg)
	quit(1)
