class_name RelicPool
extends Resource

# Theme-pack relic library. Picks a RelicDef weighted by
# RelicDef.weight, optionally filtered to a minimum rarity.
# Theme packs ship one RelicPool .tres listing every relic the
# game supports; designers add relics by appending .tres files
# without touching code.

@export var id: StringName
@export var relics: Array[RelicDef] = []

func pick(rng: RandomNumberGenerator, min_rarity: int = 0) -> RelicDef:
	var available: Array[RelicDef] = []
	for r in relics:
		if r.rarity >= min_rarity:
			available.append(r)
	if available.is_empty():
		# Fall back to the full list so a misconfigured min_rarity
		# never bricks the run.
		available = relics
	if available.is_empty():
		return null

	var total_weight: int = 0
	for r in available:
		total_weight += maxi(1, r.weight)

	var roll: int = rng.randi_range(1, total_weight)
	var cumulative: int = 0
	for r in available:
		cumulative += maxi(1, r.weight)
		if roll <= cumulative:
			return r
	return available[available.size() - 1]
