class_name BattleScreen
extends Control

# Smallest viable battle view: two columns of unit HP rows and a
# Resolve button. Visual grid rendering layers on later — this
# exists so the run loop can transition into a battle scene,
# fight, and return a result without anyone needing sprites yet.

signal battle_resolved(winning_side: int)

var _grid: CombatGrid
var _player_units: Array[CombatUnit] = []
var _enemy_units: Array[CombatUnit] = []
var _resolved: bool = false

var _player_list: VBoxContainer
var _enemy_list: VBoxContainer
var _resolve_btn: Button
var _result_label: Label

func _ready() -> void:
	_ensure_nodes()

func _ensure_nodes() -> void:
	if _player_list == null:
		_player_list = get_node_or_null("Margin/VBox/HBox/PlayerSide/List") as VBoxContainer
	if _enemy_list == null:
		_enemy_list = get_node_or_null("Margin/VBox/HBox/EnemySide/List") as VBoxContainer
	if _resolve_btn == null:
		_resolve_btn = get_node_or_null("Margin/VBox/ResolveBtn") as Button
	if _result_label == null:
		_result_label = get_node_or_null("Margin/VBox/Result") as Label

func bind_battle(grid: CombatGrid, player_units: Array[CombatUnit], enemy_units: Array[CombatUnit]) -> void:
	_ensure_nodes()
	_grid = grid
	_player_units = player_units
	_enemy_units = enemy_units
	_resolved = false
	_result_label.text = ""
	if not _resolve_btn.pressed.is_connected(_on_resolve_pressed):
		_resolve_btn.pressed.connect(_on_resolve_pressed)
	_refresh()

const PLAYER_BAR_COLOR := Color(0.40, 0.78, 0.50)  # green
const ENEMY_BAR_COLOR := Color(0.85, 0.42, 0.42)   # red
const DOWN_TINT := Color(0.6, 0.6, 0.6, 0.55)

func _refresh() -> void:
	_populate_unit_list(_player_list, _player_units, PLAYER_BAR_COLOR)
	_populate_unit_list(_enemy_list, _enemy_units, ENEMY_BAR_COLOR)
	if _resolved:
		_resolve_btn.disabled = true
		_resolve_btn.text = "Battle complete"
	else:
		_resolve_btn.disabled = false
		_resolve_btn.text = "Resolve battle"

func _populate_unit_list(list: VBoxContainer, units: Array[CombatUnit], bar_color: Color) -> void:
	while list.get_child_count() > 0:
		var stale: Node = list.get_child(0)
		list.remove_child(stale)
		stale.queue_free()
	for u in units:
		list.add_child(_build_unit_row(u, bar_color))

func _build_unit_row(u: CombatUnit, bar_color: Color) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 36)
	row.add_theme_constant_override("separation", 8)

	var name_lbl: Label = Label.new()
	name_lbl.text = u.unit_name()
	name_lbl.custom_minimum_size = Vector2(110, 0)
	row.add_child(name_lbl)

	var hp_bar: ProgressBar = ProgressBar.new()
	hp_bar.min_value = 0
	hp_bar.max_value = max(1, u.max_hp())
	hp_bar.value = u.hp
	hp_bar.show_percentage = false
	hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_bar.custom_minimum_size = Vector2(0, 22)
	hp_bar.modulate = bar_color
	row.add_child(hp_bar)

	var hp_lbl: Label = Label.new()
	hp_lbl.text = "%d/%d" % [u.hp, u.max_hp()]
	hp_lbl.custom_minimum_size = Vector2(64, 0)
	hp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(hp_lbl)

	if not u.is_alive():
		row.modulate = DOWN_TINT
		var down_lbl: Label = Label.new()
		down_lbl.text = "DOWN"
		down_lbl.custom_minimum_size = Vector2(56, 0)
		row.add_child(down_lbl)

	return row

func _on_resolve_pressed() -> void:
	if _resolved:
		return
	var roster: Array[CombatUnit] = []
	for u in _player_units:
		roster.append(u)
	for u in _enemy_units:
		roster.append(u)
	var tm: TurnManager = TurnManager.new(_grid, roster)
	var winning_side: int = tm.resolve(100)
	_resolved = true
	_result_label.text = _format_outcome(winning_side)
	_refresh()
	battle_resolved.emit(winning_side)

# Public accessor used by Main after a victory to read which
# enemy UnitDefs were defeated. Lets G3 capture/recruit roll for
# each KO'd beast without battle_screen owning the recruit logic.
func defeated_enemy_defs() -> Array[UnitDef]:
	var out: Array[UnitDef] = []
	for u in _enemy_units:
		if not u.is_alive():
			out.append(u.unit_def)
	return out

func _format_outcome(winning_side: int) -> String:
	match winning_side:
		0:
			return "Victory"
		1:
			return "Defeat"
		_:
			return "Stalemate"
