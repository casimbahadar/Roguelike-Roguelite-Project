class_name EncounterPool
extends Resource

# A theme pack's encounter library, indexed by encounter kind
# and act. The Main glue scene asks the pool for an encounter
# matching the current MapNode.Kind + current act, and the pool
# returns one — chosen by EncounterDef.weight, biased toward
# what's available in the requested act window.
#
# Theme packs ship one EncounterPool .tres per game, listing
# every encounter that game supports. The picker in pick() is
# pure-data + RNG; encounter selection is fully driven by the
# .tres files.

@export var id: StringName
@export var battle_encounters: Array[EncounterDef] = []
@export var elite_encounters: Array[EncounterDef] = []
@export var boss_encounters: Array[EncounterDef] = []

# Returns an encounter for the given node kind + act, or null
# if no encounter matches (caller should treat that as a
# non-combat node and skip starting a battle).
func pick(rng: RandomNumberGenerator, node_kind: int, act: int) -> EncounterDef:
	var pool: Array[EncounterDef] = _pool_for_kind(node_kind)
	if pool.is_empty():
		return null

	var available: Array[EncounterDef] = []
	for e in pool:
		if e.is_available_in_act(act):
			available.append(e)
	if available.is_empty():
		# Fall back to the full pool so the run is never bricked
		# by a missing-act rule. Designers should fix the data,
		# but the player still gets a fight.
		available = pool

	var total_weight: int = 0
	for e in available:
		total_weight += maxi(1, e.weight)

	var roll: int = rng.randi_range(1, total_weight)
	var cumulative: int = 0
	for e in available:
		cumulative += maxi(1, e.weight)
		if roll <= cumulative:
			return e
	return available[available.size() - 1]

func _pool_for_kind(node_kind: int) -> Array[EncounterDef]:
	match node_kind:
		MapNode.Kind.BATTLE:
			return battle_encounters
		MapNode.Kind.ELITE:
			return elite_encounters
		MapNode.Kind.BOSS:
			return boss_encounters
		_:
			var empty: Array[EncounterDef] = []
			return empty
