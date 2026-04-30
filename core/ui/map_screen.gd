class_name MapScreen
extends Control

# Vertical list view of every node in the current run. The active
# node is marked, prior nodes are dimmed, future nodes show the
# kind so the player can plan ahead. Branching maps will replace
# this with a graph layout, but for the linear MVP a list is
# enough — and stays touch-friendly on phones.

signal node_advanced(idx: int)
signal run_complete

var run_state: RunState

@onready var _list: VBoxContainer = $Margin/VBox/Scroll/List
@onready var _continue_btn: Button = $Margin/VBox/ContinueBtn
@onready var _status_label: Label = $Margin/VBox/Status

func bind_run(p_run: RunState) -> void:
	run_state = p_run
	if not _continue_btn.pressed.is_connected(_on_continue_pressed):
		_continue_btn.pressed.connect(_on_continue_pressed)
	_refresh()

func _refresh() -> void:
	for child in _list.get_children():
		child.queue_free()

	for i in run_state.map.size():
		var node: MapNode = run_state.map[i]
		var lbl: Label = Label.new()
		lbl.custom_minimum_size = Vector2(0, 32)
		var marker: String = ""
		if i == run_state.current_node_index:
			marker = "▶  "
		elif i < run_state.current_node_index:
			marker = "•  "
			lbl.modulate = Color(1, 1, 1, 0.4)
		else:
			marker = "   "
		lbl.text = "%sAct %d  —  %s" % [marker, node.act + 1, _kind_name(node.kind)]
		_list.add_child(lbl)

	_status_label.text = "Revive tokens: %d   Gold: %d" % [run_state.revive_tokens, run_state.gold]

	if run_state.is_run_complete():
		_continue_btn.disabled = true
		_continue_btn.text = "Run complete"
		run_complete.emit()
		return

	var nexts: Array[int] = run_state.next_options()
	if nexts.is_empty():
		_continue_btn.disabled = true
		_continue_btn.text = "(no next node)"
		return

	_continue_btn.disabled = false
	var next_node: MapNode = run_state.map[nexts[0]]
	_continue_btn.text = "Continue → %s" % _kind_name(next_node.kind)

func _on_continue_pressed() -> void:
	var nexts: Array[int] = run_state.next_options()
	if nexts.is_empty():
		return
	var idx: int = nexts[0]
	if run_state.advance_to(idx):
		node_advanced.emit(idx)
		_refresh()

func _kind_name(k: int) -> String:
	match k:
		MapNode.Kind.BATTLE:
			return "Battle"
		MapNode.Kind.ELITE:
			return "Elite"
		MapNode.Kind.EVENT:
			return "Event"
		MapNode.Kind.SHOP:
			return "Shop"
		MapNode.Kind.CAMP:
			return "Camp"
		MapNode.Kind.SHRINE:
			return "Shrine"
		MapNode.Kind.BOSS:
			return "Boss"
		_:
			return "?"
