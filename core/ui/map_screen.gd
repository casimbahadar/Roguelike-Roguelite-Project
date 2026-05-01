class_name MapScreen
extends Control

# Vertical list view of every node in the current run plus a
# branch picker showing the next-step options. With the
# branching MapGenerator a node can have 1-2 outgoing edges; the
# picker renders one Button per edge so the player can pick a
# lane. Linear runs (or convergence rows) just get a single
# button. Run completion replaces the picker with a status note.

signal node_advanced(idx: int)
signal run_complete

var run_state: RunState

var _list: VBoxContainer
var _choices: VBoxContainer
var _choices_label: Label
var _status_label: Label

func _ready() -> void:
	_ensure_nodes()

# Resolves all child node references. Idempotent. Called from
# _ready and from the top of every public method so timing
# differences in headless smoke-test environments (where
# @onready can resolve later than expected) never leave a
# null field at access time.
func _ensure_nodes() -> void:
	if _list == null:
		_list = get_node_or_null("Margin/VBox/Scroll/List") as VBoxContainer
	if _choices == null:
		_choices = get_node_or_null("Margin/VBox/Choices") as VBoxContainer
	if _choices_label == null:
		_choices_label = get_node_or_null("Margin/VBox/ChoicesLabel") as Label
	if _status_label == null:
		_status_label = get_node_or_null("Margin/VBox/Status") as Label

func bind_run(p_run: RunState) -> void:
	_ensure_nodes()
	run_state = p_run
	_refresh()

func _refresh() -> void:
	_ensure_nodes()
	_render_list()
	_render_status()
	_render_choices()

func _render_list() -> void:
	for child in _list.get_children():
		child.queue_free()
	for i in run_state.map.size():
		var node: MapNode = run_state.map[i]
		var lbl: Label = Label.new()
		lbl.custom_minimum_size = Vector2(0, 28)
		var marker: String = "   "
		if i == run_state.current_node_index:
			marker = "▶  "
		elif i < run_state.current_node_index:
			marker = "•  "
			lbl.modulate = Color(1, 1, 1, 0.4)
		lbl.text = "%sAct %d  row %d  col %d  —  %s" % [
			marker, node.act + 1, node.depth, node.column, _kind_name(node.kind),
		]
		_list.add_child(lbl)

func _render_status() -> void:
	_status_label.text = "Revive tokens: %d   Gold: %d" % [run_state.revive_tokens, run_state.gold]

func _render_choices() -> void:
	for child in _choices.get_children():
		child.queue_free()

	if run_state.is_run_complete():
		_choices_label.text = "Run complete"
		run_complete.emit()
		return

	var nexts: Array[int] = run_state.next_options()
	if nexts.is_empty():
		_choices_label.text = "(no next node)"
		return

	if nexts.size() == 1:
		_choices_label.text = "Next path"
	else:
		_choices_label.text = "Choose your path"

	for idx in nexts:
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(0, 56)
		var dest: MapNode = run_state.map[idx]
		btn.text = _format_choice_label(nexts.size(), dest)
		btn.pressed.connect(_on_choice_pressed.bind(idx))
		_choices.add_child(btn)

func _format_choice_label(option_count: int, dest: MapNode) -> String:
	if option_count == 1:
		return "Continue  →  %s" % _kind_name(dest.kind)
	return "Lane %d  →  %s" % [dest.column, _kind_name(dest.kind)]

func _on_choice_pressed(idx: int) -> void:
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
