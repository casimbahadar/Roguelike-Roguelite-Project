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
const ENCOUNTER_POOL_PATH := "res://games/sengoku/data/encounters/sengoku_pool.tres"
const EVENT_POOL_PATH := "res://games/sengoku/data/events/sengoku_event_pool.tres"
const RELIC_POOL_PATH := "res://games/sengoku/data/relics/sengoku_relic_pool.tres"

var _meta: MetaState
var _run_configs: Array[RunConfig] = []
var _run_state: RunState
var _player_class: ClassDef
var _enemy_class: ClassDef
var _encounter_pool: EncounterPool
var _event_pool: EventPool
var _relic_pool: RelicPool
var _battle_rng: RandomNumberGenerator

@onready var _hub: HubScreen = $Hub
@onready var _map: MapScreen = $MapScreen
@onready var _battle: BattleScreen = $BattleScreen
@onready var _result: ResultScreen = $ResultScreen
@onready var _event: EventScreen = $EventScreen
@onready var _shop: ShopScreen = $ShopScreen
@onready var _camp: CampScreen = $CampScreen
@onready var _shrine: ShrineScreen = $ShrineScreen

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
	_encounter_pool = load(ENCOUNTER_POOL_PATH)
	_event_pool = load(EVENT_POOL_PATH)
	_relic_pool = load(RELIC_POOL_PATH)
	_battle_rng = RandomNumberGenerator.new()
	_battle_rng.randomize()

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
	_event.event_resolved.connect(_on_event_resolved)
	_shop.shop_left.connect(_on_node_screen_left)
	_camp.camp_left.connect(_on_node_screen_left)
	_shrine.shrine_left.connect(_on_node_screen_left)
	_result.continue_pressed.connect(_show_hub)

func _show_only(node: Control) -> void:
	for child in [_hub, _map, _battle, _result, _event, _shop, _camp, _shrine]:
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
	var kind: int = _run_state.current_node().kind
	if _is_combat_kind(kind):
		_start_battle_for_current_node()
		return
	if kind == MapNode.Kind.EVENT:
		_start_event_for_current_node()
		return
	if kind == MapNode.Kind.SHOP:
		_start_shop_for_current_node()
		return
	if kind == MapNode.Kind.CAMP:
		_start_camp_for_current_node()
		return
	if kind == MapNode.Kind.SHRINE:
		_start_shrine_for_current_node()
		return
	# Unknown node kind — keep the map showing and let the player
	# advance manually.

func _start_shop_for_current_node() -> void:
	if _relic_pool == null:
		return
	var offered: Array[RelicDef] = []
	for i in 3:
		var picked: RelicDef = _relic_pool.pick(_battle_rng)
		if picked != null:
			offered.append(picked)
	_shop.bind_shop(_run_state, offered)
	_show_only(_shop)

func _start_camp_for_current_node() -> void:
	_camp.bind_camp(_run_state)
	_show_only(_camp)

func _start_shrine_for_current_node() -> void:
	if _relic_pool == null:
		return
	var picked: RelicDef = _relic_pool.pick(_battle_rng, RelicDef.Rarity.UNCOMMON)
	if picked == null:
		return
	_shrine.bind_shrine(_run_state, picked)
	_show_only(_shrine)

func _on_node_screen_left() -> void:
	# After Shop / Camp / Shrine, return to the map and refresh
	# the status line so any gold / relic changes show up.
	_show_only(_map)
	_map.bind_run(_run_state)

func _start_event_for_current_node() -> void:
	if _event_pool == null:
		return
	var picked: EventDef = _event_pool.pick(_battle_rng, _run_state.current_act())
	if picked == null:
		return
	_event.bind_event(picked)
	_show_only(_event)

func _on_event_resolved(chosen: EventChoice) -> void:
	# Apply effects to the active run / meta state.
	_run_state.gold += chosen.gold_delta
	if _run_state.gold < 0:
		_run_state.gold = 0
	_meta.meta_currency += chosen.meta_currency_delta
	if _meta.meta_currency < 0:
		_meta.meta_currency = 0
	# party_hp_delta is a future hook (party isn't yet a persistent
	# CombatUnit roster across nodes); apply it once that lands.
	_show_only(_map)
	_map.bind_run(_run_state)  # refresh status line

func _is_combat_kind(k: int) -> bool:
	return k == MapNode.Kind.BATTLE or k == MapNode.Kind.ELITE or k == MapNode.Kind.BOSS

func _start_battle_for_current_node() -> void:
	var grid: CombatGrid = CombatGrid.new(6, 6)
	var hero: CombatUnit = CombatUnit.new(_make_player_unit_def(), Vector2i(0, 0))
	_apply_relic_buffs(hero)
	var players: Array[CombatUnit] = [hero]
	var enemies: Array[CombatUnit] = _spawn_enemies_for_current_node()
	_battle.bind_battle(grid, players, enemies)
	_show_only(_battle)

func _apply_relic_buffs(unit: CombatUnit) -> void:
	var atk_b: int = 0
	var def_b: int = 0
	var hp_b: int = 0
	for r in _run_state.relics:
		match r.kind:
			RelicDef.Kind.ATK_BONUS:
				atk_b += r.value
			RelicDef.Kind.DEFENSE_BONUS:
				def_b += r.value
			RelicDef.Kind.MAX_HP_BONUS:
				hp_b += r.value
			# GOLD_PER_VICTORY is applied at battle end, not here.
	unit.apply_buffs(atk_b, def_b, hp_b)

func _spawn_enemies_for_current_node() -> Array[CombatUnit]:
	var enemies: Array[CombatUnit] = []
	var encounter: EncounterDef = null
	if _encounter_pool != null:
		encounter = _encounter_pool.pick(_battle_rng, _run_state.current_node().kind, _run_state.current_act())
	if encounter == null or encounter.enemies.is_empty():
		# Fallback: a single ashigaru-class bandit so the run never hits a
		# dead battle node. Designers should add encounters covering every
		# combat kind for every act.
		enemies.append(CombatUnit.new(_make_enemy_unit_def(), Vector2i(5, 5)))
		return enemies
	# Spread enemies across the right column so they don't pile on one tile.
	var positions: Array[Vector2i] = [Vector2i(5, 5), Vector2i(5, 4), Vector2i(5, 3), Vector2i(4, 5)]
	for i in encounter.enemies.size():
		var pos: Vector2i = positions[i % positions.size()]
		enemies.append(CombatUnit.new(encounter.enemies[i], pos))
	return enemies

func _on_battle_resolved(winning_side: int) -> void:
	if winning_side != 0:
		_finish_run(ResultScreen.Outcome.DEFEAT)
		return
	# Won. Award gold from any GOLD_PER_VICTORY relics held.
	for r in _run_state.relics:
		if r.kind == RelicDef.Kind.GOLD_PER_VICTORY:
			_run_state.gold += r.value
	# Boss victory: pull a fresh relic into the run before
	# resolving the screen so the player feels the upgrade
	# immediately if they hit a follow-up battle.
	if _run_state.current_node().kind == MapNode.Kind.BOSS and _relic_pool != null:
		var picked: RelicDef = _relic_pool.pick(_battle_rng)
		if picked != null:
			_run_state.relics.append(picked)
	# If that was the final-act boss, finish the run.
	if _run_state.is_run_complete():
		_finish_run(ResultScreen.Outcome.VICTORY)
		return
	_show_only(_map)
	_map.bind_run(_run_state)  # refresh status line (gold may have changed)

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
