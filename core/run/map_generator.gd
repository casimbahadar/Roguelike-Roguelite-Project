class_name MapGenerator
extends RefCounted

# Builds a branching campaign map (Array[MapNode]) from a
# RunConfig + seed. Slay-the-Spire-style:
#
#   * Each act has a number of rows determined by RunConfig.
#   * Row 0 is a single BATTLE (the starting point).
#   * Last row is a single BOSS — all middle-row paths converge.
#   * Middle rows have 1-3 nodes (lanes).
#   * Each non-final node connects to 1-2 nodes in the next row,
#     biased toward keeping its column. Edges don't cross
#     diagonally (a left node won't link to a right next-row node
#     when the right node already linked from a more-central
#     position).
#   * Cross-act linking: each non-final act's BOSS points to the
#     next act's row-0 single node, so the run is one connected
#     graph.

const KIND_WEIGHTS: Dictionary = {
	MapNode.Kind.BATTLE: 50,
	MapNode.Kind.EVENT: 15,
	MapNode.Kind.SHOP: 10,
	MapNode.Kind.CAMP: 10,
	MapNode.Kind.ELITE: 10,
	MapNode.Kind.SHRINE: 5,
}

const MID_ROW_WIDTH_MIN: int = 2
const MID_ROW_WIDTH_MAX: int = 3

static func build(config: RunConfig, seed: int) -> Array[MapNode]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed

	var map: Array[MapNode] = []
	var act_starts: Array[int] = []

	for act_idx in config.act_count:
		act_starts.append(map.size())
		# Number of rows in this act. nodes_per_act counts total
		# nodes loosely; we treat it as row-count guidance.
		var row_count: int = rng.randi_range(config.nodes_per_act.x, config.nodes_per_act.y)
		if row_count < 3:
			row_count = 3  # need at least start, one middle, boss

		# Track the start index of every row so we can wire edges.
		var rows_start: Array[int] = []
		var rows_width: Array[int] = []

		for d in row_count:
			rows_start.append(map.size())
			var width: int
			if d == 0 or d == row_count - 1:
				width = 1  # single start, single boss
			else:
				width = rng.randi_range(MID_ROW_WIDTH_MIN, MID_ROW_WIDTH_MAX)
			rows_width.append(width)
			for col in width:
				var kind: MapNode.Kind
				if d == 0:
					kind = MapNode.Kind.BATTLE
				elif d == row_count - 1:
					kind = MapNode.Kind.BOSS
				else:
					kind = _pick_weighted(rng)
				map.append(MapNode.new(kind, act_idx, d, col))

		# Wire edges between consecutive rows in this act.
		for d in range(row_count - 1):
			_wire_row_edges(map, rng, rows_start[d], rows_width[d], rows_start[d + 1], rows_width[d + 1])

	# Cross-act: each non-final act's boss links to the next act's row-0 node.
	for a in range(act_starts.size() - 1):
		var boss_idx: int = act_starts[a + 1] - 1
		map[boss_idx].next_indices.append(act_starts[a + 1])

	return map

# Connect every node in row r to 1-2 nodes in row r+1. Biases
# toward keeping the column when possible, allows one-step
# diagonals (left or right neighbour), and avoids crossings by
# letting later edges only target columns >= the previous
# node's targets.
static func _wire_row_edges(
	map: Array[MapNode],
	rng: RandomNumberGenerator,
	row_start: int,
	row_width: int,
	next_start: int,
	next_width: int
) -> void:
	# Convergence row (next_width == 1): every node points at the single next.
	if next_width == 1:
		var only: int = next_start
		for i in row_width:
			map[row_start + i].next_indices.append(only)
		return

	# Divergence row (row_width == 1, next_width > 1): single
	# start node points to all next-row nodes (gives the player a
	# branch choice from the very first decision).
	if row_width == 1:
		for j in next_width:
			map[row_start].next_indices.append(next_start + j)
		return

	# Multi-to-multi. For each node, pick 1-2 targets in [col-1, col, col+1].
	# Non-crossing rule: source nodes traversed left-to-right, the next
	# node's MIN target column must be >= the previous node's MAX target
	# column (sharing a target column is allowed and doesn't cross).
	var min_allowed_col: int = 0
	for i in row_width:
		var node: MapNode = map[row_start + i]
		var candidates: Array[int] = []
		for offset in [-1, 0, 1]:
			var t: int = i + offset
			if t < 0 or t >= next_width:
				continue
			if t < min_allowed_col:
				continue
			candidates.append(t)
		if candidates.is_empty():
			# Fallback: snap to the most-central legal column.
			var fallback: int = clampi(i, min_allowed_col, next_width - 1)
			candidates.append(fallback)

		var primary: int = candidates[rng.randi() % candidates.size()]
		node.next_indices.append(next_start + primary)
		var max_used: int = primary

		# 35% chance to add a second edge (drawn from remaining candidates).
		if rng.randf() < 0.35 and candidates.size() > 1:
			var secondary: int = primary
			var tries: int = 0
			while secondary == primary and tries < 8:
				secondary = candidates[rng.randi() % candidates.size()]
				tries += 1
			if secondary != primary:
				node.next_indices.append(next_start + secondary)
				max_used = max(max_used, secondary)

		min_allowed_col = max_used

static func _pick_weighted(rng: RandomNumberGenerator) -> MapNode.Kind:
	var total: int = 0
	for w in KIND_WEIGHTS.values():
		total += w
	var roll: int = rng.randi_range(1, total)
	var cumulative: int = 0
	for kind in KIND_WEIGHTS:
		cumulative += KIND_WEIGHTS[kind]
		if roll <= cumulative:
			return kind
	return MapNode.Kind.BATTLE
