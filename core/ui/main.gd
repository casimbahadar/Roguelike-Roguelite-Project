class_name Main
extends Node

# Glue scene that owns persistent state (MetaState, the run-config
# library, the player's chosen Lord) and switches between Hub,
# Map, Battle, and Result screens. One scene tree at a time —
# whichever child is visible is the active screen.
#
# Battle resolution at non-battle nodes is intentionally a no-op
# in the slice: SHOP / CAMP / EVENT / SHRINE auto-advance. They
# get their own UI when content authoring lands.

const RUN_CONFIG_PATHS: Array[String] = [
	"res://games/sengoku/data/runs/skirmish.tres",
	"res://games/sengoku/data/runs/standard.tres",
	"res://games/sengoku/data/runs/long.tres",
	"res://games/sengoku/data/runs/iron.tres",
]
const PLAYER_CLASS_PATH := "res://games/sengoku/data/classes/samurai.tres"
const ENEMY_CLASS_PATH := "res://games/sengoku/data/classes/ashigaru.tres"

var _meta: MetaState
var _run_configs: Array[RunConfig] = []
var _run_state: RunState
var _player_class: ClassDef
var _enemy_class: ClassDef

@onready var _hub: HubScreen = $Hub
@onready var _map: MapScreen = $MapScreen
@onready var _battle: BattleScreen = $BattleScreen
@onready var _result: ResultScreen = $ResultScreen

func _ready() -> void:
	_load_data()
	_wire_signals()
	_show_hub()

func _load_data() -> void:
	var save_dict: Dictionary = SaveSystem.load()
	_meta = MetaState.from_dict(save_dict)
	MetaUnlocks.recompute_unlocks(_meta)

	for path in RUN_CONFIG_PATHS:
		var cfg: RunConfig = load(path)
		if cfg != null:
			_run_configs.append(cfg)

	_player_class = load(PLAYER_CLASS_PATH)
	_enemy_class = load(ENEMY_CLASS_PATH)

func _wire_signals() -> void:
	_hub.run_format_chosen.connect(_on_run_format_chosen)
	_map.node_advanced.connect(_on_node_advanced)
	# Note: we deliberately don't connect _map.run_complete. The
	# Map emits it during _refresh — i.e. inside _on_continue_pressed,
	# *before* the boss battle even starts — so wiring it would race
	# the battle screen and end the run with a victory before the
	# fight happens. Run completion is decided in _on_battle_resolved
	# instead.
	_battle.battle_resolved.connect(_on_battle_resolved)
	_result.continue_pressed.connect(_show_hub)

func _show_only(node: Control) -> void:
	for child in [_hub, _map, _battle, _result]:
		child.visible = (child == node)

func _show_hub() -> void:
	_hub.populate(_meta, _run_configs)
	_show_only(_hub)

func _on_run_format_chosen(format_id: StringName) -> void:
	var config: RunConfig = _config_by_id(format_id)
	if config == null:
		return
	_meta.record_run_attempted(format_id)
	var seed: int = _seed_for(config)
	var party: Array[UnitDef] = [_make_player_unit_def()]
	_run_state = RunState.new(config, seed, party)
	_map.bind_run(_run_state)
	_show_only(_map)
	# Node 0 is always BATTLE per MapGenerator; trigger the opening
	# fight so the player isn't given a free pass past it.
	if _is_combat_kind(_run_state.current_node().kind):
		_start_battle_for_current_node()

func _on_node_advanced(_idx: int) -> void:
	if _is_combat_kind(_run_state.current_node().kind):
		_start_battle_for_current_node()
	# Non-combat nodes (SHOP/CAMP/EVENT/SHRINE) are placeholder no-ops
	# in the slice; the Map screen already updated state, so just keep
	# showing it.

func _is_combat_kind(k: int) -> bool:
	return k == MapNode.Kind.BATTLE or k == MapNode.Kind.ELITE or k == MapNode.Kind.BOSS

func _start_battle_for_current_node() -> void:
	var grid: CombatGrid = CombatGrid.new(6, 6)
	var hero: CombatUnit = CombatUnit.new(_make_player_unit_def(), Vector2i(0, 0))
	var foe: CombatUnit = CombatUnit.new(_make_enemy_unit_def(), Vector2i(5, 5))
	_battle.bind_battle(grid, [hero], [foe])
	_show_only(_battle)

func _on_battle_resolved(winning_side: int) -> void:
	if winning_side != 0:
		_finish_run(ResultScreen.Outcome.DEFEAT)
		return
	# Won. If that was the final-act boss, finish the run.
	if _run_state.is_run_complete():
		_finish_run(ResultScreen.Outcome.VICTORY)
		return
	_show_only(_map)

func _finish_run(outcome: ResultScreen.Outcome) -> void:
	var newly: Array[StringName] = []
	if outcome == ResultScreen.Outcome.VICTORY:
		newly = MetaUnlocks.on_run_completed(_meta, _run_state.run_config.id)
	SaveSystem.save(_meta.to_dict())
	_result.bind_result(outcome, _run_state, newly)
	_show_only(_result)

func _config_by_id(id: StringName) -> RunConfig:
	for c in _run_configs:
		if c.id == id:
			return c
	return null

func _seed_for(config: RunConfig) -> int:
	match config.seed_source:
		RunConfig.SeedSource.FIXED:
			return config.fixed_seed
		RunConfig.SeedSource.DAILY_UTC:
			# Daily seed = days since unix epoch (UTC).
			return int(Time.get_unix_time_from_system() / 86400)
		_:
			return randi()

func _make_player_unit_def() -> UnitDef:
	var d: UnitDef = UnitDef.new()
	d.id = &"slice_player"
	d.display_name = "Hero"
	d.class_def = _player_class
	d.level = 1
	d.side = 0
	return d

func _make_enemy_unit_def() -> UnitDef:
	var d: UnitDef = UnitDef.new()
	d.id = &"slice_enemy"
	d.display_name = "Bandit"
	d.class_def = _enemy_class
	d.level = 1
	d.side = 1
	return d
