class_name MapNode
extends RefCounted

# One node on the campaign map. Slay-the-Spire-style: each node is
# typed (battle, elite, event, shop, camp, shrine, boss) and lives
# at a specific (act, depth) coordinate. Edges point forward, into
# the next depth row of the same act, or — for the last row of an
# act — into the next act's first row.

enum Kind {
	BATTLE,
	ELITE,
	EVENT,
	SHOP,
	CAMP,
	SHRINE,
	BOSS,
}

var kind: Kind
var act: int
var depth: int  # row within the act, 0 = first
var next_indices: Array[int] = []  # indices into RunState.map of nodes this connects to

func _init(p_kind: Kind, p_act: int, p_depth: int) -> void:
	kind = p_kind
	act = p_act
	depth = p_depth
