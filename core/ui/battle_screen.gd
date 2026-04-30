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

@onready var _player_list: VBoxContainer = $Margin/VBox/HBox/PlayerSide/List
@onready var _enemy_list: VBoxContainer = $Margin/VBox/HBox/EnemySide/List
@onready var _resolve_btn: Button = $Margin/VBox/ResolveBtn
@onready var _result_label: Label = $Margin/VBox/Result

func bind_battle(grid: CombatGrid, player_units: Array[CombatUnit], enemy_units: Array[CombatUnit]) -> void:
	_grid = grid
	_player_units = player_units
	_enemy_units = enemy_units
	_resolved = false
	_result_label.text = ""
	if not _resolve_btn.pressed.is_connected(_on_resolve_pressed):
		_resolve_btn.pressed.connect(_on_resolve_pressed)
	_refresh()

func _refresh() -> void:
	_populate_unit_list(_player_list, _player_units)
	_populate_unit_list(_enemy_list, _enemy_units)
	if _resolved:
		_resolve_btn.disabled = true
		_resolve_btn.text = "Battle complete"
	else:
		_resolve_btn.disabled = false
		_resolve_btn.text = "Resolve battle"

func _populate_unit_list(list: VBoxContainer, units: Array[CombatUnit]) -> void:
	for child in list.get_children():
		child.queue_free()
	for u in units:
		var lbl: Label = Label.new()
		lbl.custom_minimum_size = Vector2(0, 32)
		var status: String = "alive"
		if not u.is_alive():
			status = "DOWN"
			lbl.modulate = Color(1, 0.4, 0.4)
		lbl.text = "%s  hp %d/%d  (%s)" % [u.unit_name(), u.hp, u.max_hp(), status]
		list.add_child(lbl)

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

func _format_outcome(winning_side: int) -> String:
	match winning_side:
		0:
			return "Victory"
		1:
			return "Defeat"
		_:
			return "Stalemate"
