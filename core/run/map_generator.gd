class_name MapGenerator
extends RefCounted

# Builds a campaign map (Array[MapNode]) from a RunConfig + seed.
# Linear within each act for now — branching layouts come later.
# First node of each act is a fair BATTLE; last is a BOSS; the
# rest are weighted random across event/shop/camp/elite/shrine.
# Each act's boss points to the next act's first node so the
# whole run is one connected graph.

const KIND_WEIGHTS: Dictionary = {
	MapNode.Kind.BATTLE: 50,
	MapNode.Kind.EVENT: 15,
	MapNode.Kind.SHOP: 10,
	MapNode.Kind.CAMP: 10,
	MapNode.Kind.ELITE: 10,
	MapNode.Kind.SHRINE: 5,
}

static func build(config: RunConfig, seed: int) -> Array[MapNode]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed

	var map: Array[MapNode] = []
	var act_starts: Array[int] = []

	for act_idx in config.act_count:
		act_starts.append(map.size())
		var act_size: int = rng.randi_range(config.nodes_per_act.x, config.nodes_per_act.y)
		if act_size < 2:
			act_size = 2  # always at least one battle + a boss

		var act_start: int = map.size()
		for d in act_size:
			var kind: MapNode.Kind
			if d == act_size - 1:
				kind = MapNode.Kind.BOSS
			elif d == 0:
				kind = MapNode.Kind.BATTLE
			else:
				kind = _pick_weighted(rng)
			map.append(MapNode.new(kind, act_idx, d))

		# Linear edges within this act.
		for i in range(act_start, map.size() - 1):
			map[i].next_indices.append(i + 1)

	# Cross-act: each non-final act's boss links to next act's first node.
	for a in range(act_starts.size() - 1):
		var boss_idx: int = act_starts[a + 1] - 1
		map[boss_idx].next_indices.append(act_starts[a + 1])

	return map

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
