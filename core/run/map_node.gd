class_name MapNode
extends RefCounted

# One node on the campaign map. Slay-the-Spire-style: each node is
# typed (battle, elite, event, shop, camp, shrine, boss) and lives
# at a specific (act, depth, column) coordinate. Edges point
# forward — into the next depth row of the same act, or for the
# last row of an act, into the next act's first row.
#
# Column is the horizontal lane within the row. Single-node rows
# (start, boss) sit at column 0. Multi-node rows have columns
# 0..N-1 where N depends on the row's width chosen at generation.

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
var column: int = 0  # lane within the row (0..row_width-1)
var next_indices: Array[int] = []  # indices into RunState.map of nodes this connects to

func _init(p_kind: Kind, p_act: int, p_depth: int, p_column: int = 0) -> void:
	kind = p_kind
	act = p_act
	depth = p_depth
	column = p_column
