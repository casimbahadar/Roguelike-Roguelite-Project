class_name RunState
extends RefCounted

# Live state for one in-progress run. Owns the generated map and
# tracks where the player is, what their party looks like, and
# the few resources that span nodes (revive tokens, gold).
# Battle resolution itself lives in core/combat/ — RunState only
# knows about nodes, not what happens inside a fight.

var run_config: RunConfig
var seed_used: int
var map: Array[MapNode] = []
var current_node_index: int = 0
var party: Array[UnitDef] = []
var revive_tokens: int = 0
var gold: int = 0
var relics: Array[RelicDef] = []

func _init(p_config: RunConfig, p_seed: int, p_party: Array[UnitDef]) -> void:
	run_config = p_config
	seed_used = p_seed
	party = p_party
	map = MapGenerator.build(p_config, p_seed)
	current_node_index = 0
	revive_tokens = _initial_revive_tokens(p_config)

func current_node() -> MapNode:
	return map[current_node_index]

func current_act() -> int:
	return current_node().act

func next_options() -> Array[int]:
	return current_node().next_indices

# Move to one of the indices listed in current_node().next_indices.
# Returns false if the index isn't a legal next step.
# ONE_PER_ACT revive policy refills one token when crossing into a new act.
func advance_to(idx: int) -> bool:
	if not current_node().next_indices.has(idx):
		return false
	var prev_act: int = current_act()
	current_node_index = idx
	if run_config.revive_policy == RunConfig.RevivePolicy.ONE_PER_ACT and current_act() != prev_act:
		revive_tokens += 1
	return true

# True once we've arrived at the final-act boss with no further nodes.
func is_run_complete() -> bool:
	var n: MapNode = current_node()
	return n.kind == MapNode.Kind.BOSS and n.act == run_config.act_count - 1 and n.next_indices.is_empty()

static func _initial_revive_tokens(c: RunConfig) -> int:
	match c.revive_policy:
		RunConfig.RevivePolicy.NONE:
			return 0
		RunConfig.RevivePolicy.ONE_PER_RUN:
			return 1
		RunConfig.RevivePolicy.ONE_PER_ACT:
			return 1  # refilled on act change in advance_to()
		_:
			return 0
