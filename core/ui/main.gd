class_name Main
extends Node

# Glue scene that owns persistent state (MetaState, the run-config
# library, the player's chosen Lord) and switches between Hub,
# Map, Battle, and Result screens. One scene tree at a time —
# whichever child is visible is the active screen.
#
# Theme-aware: Main reads all per-game content paths from a
# ThemePack Resource. Three ways the pack can be set, in priority
# order:
#   1. Test/harness code calls set_theme_pack() before add_child.
#   2. The build has a feature tag matching one of FEATURE_TAG_TO_PACK
#      (the four shipped products each export with one such tag).
#   3. Neither — show the dev title screen so the developer can pick.
#
# The title screen is a dev-only harness; shipped builds always boot
# straight to their tagged pack and never see it.

const FEATURE_TAG_TO_PACK := {
	"sengoku": "res://games/sengoku/sengoku_pack.tres",
	"crystal": "res://games/crystal/crystal_pack.tres",
	"pocketkin": "res://games/pocketkin/pocketkin_pack.tres",
	"datapact": "res://games/datapact/datapact_pack.tres",
}

var _theme_pack: ThemePack

var _meta: MetaState
var _run_configs: Array[RunConfig] = []
var _run_state: RunState
var _player_class: ClassDef
var _enemy_class: ClassDef
var _encounter_pool: EncounterPool
var _event_pool: EventPool
var _relic_pool: RelicPool
var _maps: Array[MapDef] = []
var _templates: Array[BattlefieldTemplate] = []
var _battle_rng: RandomNumberGenerator

var _title: TitleScreen
var _hub: HubScreen
var _map: MapScreen
var _battle: BattleScreen
var _result: ResultScreen
var _event: EventScreen
var _shop: ShopScreen
var _camp: CampScreen
var _shrine: ShrineScreen

# Harness/test code can call this before add_child to skip the
# title screen and boot directly into the chosen theme. If unset,
# _ready shows the title screen and waits for the player to pick.
func set_theme_pack(pack: ThemePack) -> void:
	_theme_pack = pack

func _ready() -> void:
	_ensure_nodes()
	_title.theme_chosen.connect(_on_theme_chosen)
	if _theme_pack == null:
		_theme_pack = _resolve_pack_from_feature_tags()
	if _theme_pack != null:
		_boot_with_theme()
	else:
		_show_only(_title)

# Shipped builds export with exactly one of the four feature tags
# (sengoku/crystal/pocketkin/datapact), each in its own export
# preset. Dev/editor builds have none, which is how the title screen
# stays reachable for in-engine testing.
func _resolve_pack_from_feature_tags() -> ThemePack:
	for tag in FEATURE_TAG_TO_PACK:
		if OS.has_feature(tag):
			return load(FEATURE_TAG_TO_PACK[tag])
	return null

func _on_theme_chosen(pack: ThemePack) -> void:
	_theme_pack = pack
	_boot_with_theme()

func _boot_with_theme() -> void:
	_load_data()
	_wire_signals()
	_show_hub()

# Resolve all child screen references. Idempotent. Same pattern
# as the individual screens — the UI scripts have learned that
# @onready can fail to fire in headless smoke harnesses, so the
# Main glue node uses lazy lookup with a one-shot _ready hook.
func _ensure_nodes() -> void:
	if _title == null:
		_title = get_node_or_null("TitleScreen") as TitleScreen
	if _hub == null:
		_hub = get_node_or_null("Hub") as HubScreen
	if _map == null:
		_map = get_node_or_null("MapScreen") as MapScreen
	if _battle == null:
		_battle = get_node_or_null("BattleScreen") as BattleScreen
	if _result == null:
		_result = get_node_or_null("ResultScreen") as ResultScreen
	if _event == null:
		_event = get_node_or_null("EventScreen") as EventScreen
	if _shop == null:
		_shop = get_node_or_null("ShopScreen") as ShopScreen
	if _camp == null:
		_camp = get_node_or_null("CampScreen") as CampScreen
	if _shrine == null:
		_shrine = get_node_or_null("ShrineScreen") as ShrineScreen

func _load_data() -> void:
	var save_dict: Dictionary = SaveSystem.load()
	_meta = MetaState.from_dict(save_dict)
	MetaUnlocks.recompute_unlocks(_meta)

	for path in _theme_pack.run_config_paths:
		var cfg: RunConfig = load(path)
		if cfg != null:
			_run_configs.append(cfg)

	_player_class = load(_theme_pack.player_class_path)
	_enemy_class = load(_theme_pack.enemy_class_path)
	_encounter_pool = load(_theme_pack.encounter_pool_path)
	_event_pool = load(_theme_pack.event_pool_path)
	_relic_pool = load(_theme_pack.relic_pool_path)
	for p in _theme_pack.map_paths:
		var m: MapDef = load(p)
		if m != null:
			_maps.append(m)
	for p in _theme_pack.template_paths:
		var t: BattlefieldTemplate = load(p)
		if t != null:
			_templates.append(t)
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
	for child in [_title, _hub, _map, _battle, _result, _event, _shop, _camp, _shrine]:
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
	var setup: Dictionary = _build_battlefield_for_current_node()
	var grid: CombatGrid = setup["grid"]
	var hero: CombatUnit = CombatUnit.new(_make_player_unit_def(), setup["player_pos"])
	_apply_relic_buffs(hero)
	var players: Array[CombatUnit] = [hero]
	var enemies: Array[CombatUnit] = _spawn_enemies_for_current_node(setup["enemy_positions"])
	_battle.bind_battle(grid, players, enemies)
	_show_only(_battle)

# Returns { grid, player_pos, enemy_positions } picked from
# either a hand-crafted MapDef or a procedural BattlefieldTemplate.
# 60% chance to use a hand-crafted map, 40% procedural — keeps
# the slice feeling authored without making every battle the
# same six layouts.
func _build_battlefield_for_current_node() -> Dictionary:
	var use_handcrafted: bool = (not _maps.is_empty()) and (_templates.is_empty() or _battle_rng.randf() < 0.6)
	if use_handcrafted:
		var m: MapDef = _maps[_battle_rng.randi() % _maps.size()]
		var grid: CombatGrid = m.build_grid()
		var player_pos: Vector2i = Vector2i(0, grid.height - 1)
		if not m.player_spawns.is_empty():
			player_pos = m.player_spawns[0]
		return {
			"grid": grid,
			"player_pos": player_pos,
			"enemy_positions": m.enemy_spawns.duplicate(),
		}
	# Procedural path.
	if _templates.is_empty():
		# No templates loaded — fall back to a blank grid.
		var grid: CombatGrid = CombatGrid.new(6, 6)
		return {
			"grid": grid,
			"player_pos": Vector2i(0, 5),
			"enemy_positions": [Vector2i(5, 0), Vector2i(4, 0), Vector2i(5, 1), Vector2i(3, 0)],
		}
	var t: BattlefieldTemplate = _templates[_battle_rng.randi() % _templates.size()]
	var grid: CombatGrid = t.build_grid(_battle_rng)
	var p_spawns: Array[Vector2i] = t.default_player_spawns(1)
	var e_spawns: Array[Vector2i] = t.default_enemy_spawns(4)
	return {
		"grid": grid,
		"player_pos": p_spawns[0] if not p_spawns.is_empty() else Vector2i(0, t.height - 1),
		"enemy_positions": e_spawns,
	}

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

func _spawn_enemies_for_current_node(positions: Array) -> Array[CombatUnit]:
	var enemies: Array[CombatUnit] = []
	var encounter: EncounterDef = null
	if _encounter_pool != null:
		encounter = _encounter_pool.pick(_battle_rng, _run_state.current_node().kind, _run_state.current_act())
	if encounter == null or encounter.enemies.is_empty():
		# Fallback: a single ashigaru-class bandit so the run never hits a
		# dead battle node. Designers should add encounters covering every
		# combat kind for every act.
		var fallback_pos: Vector2i = positions[0] if not positions.is_empty() else Vector2i(5, 5)
		enemies.append(CombatUnit.new(_make_enemy_unit_def(), fallback_pos))
		return enemies
	# Use the map's enemy_spawns where possible; fall back to a generic right-column
	# spread when the encounter has more enemies than the map declared spawns for.
	var generic_positions: Array[Vector2i] = [Vector2i(5, 5), Vector2i(5, 4), Vector2i(5, 3), Vector2i(4, 5)]
	for i in encounter.enemies.size():
		var pos: Vector2i
		if i < positions.size():
			pos = positions[i]
		else:
			pos = generic_positions[(i - positions.size()) % generic_positions.size()]
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
