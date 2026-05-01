extends SceneTree

# Headless smoke test for the four ThemePack .tres files.
# Verifies that:
#
#   * Each pack loads as a ThemePack.
#   * Every path the pack declares actually loads (no typos).
#   * Booting Main with each pack reaches the Hub state without
#     errors or null fields.
#
# Run: godot --headless --script res://tests/smoke_themes.gd

const PACK_PATHS: Array[String] = [
	"res://games/sengoku/sengoku_pack.tres",
	"res://games/crystal/crystal_pack.tres",
	"res://games/pocketkin/pocketkin_pack.tres",
	"res://games/datapact/datapact_pack.tres",
]

const SAVE_PATH := "user://meta.json"
const MAIN_SCENE_PATH := "res://core/ui/main.tscn"

func _initialize() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

	var main_scene: PackedScene = load(MAIN_SCENE_PATH)
	if main_scene == null:
		_fail("could not load main.tscn")
		return

	for path in PACK_PATHS:
		var pack: ThemePack = load(path)
		if pack == null:
			_fail("failed to load %s" % path)
			return
		if pack.id == &"":
			_fail("%s has empty id" % path)
			return
		# Validate every declared path actually loads.
		if not _validate_pack_paths(pack):
			return

		# Boot Main with this pack and verify Hub is visible.
		var main: Main = main_scene.instantiate()
		main.set_theme_pack(pack)
		root.add_child(main)
		await self.process_frame

		if main._hub == null:
			_fail("[%s] main._hub null after boot" % pack.id)
			return
		if not main._hub.visible:
			_fail("[%s] hub not visible after boot" % pack.id)
			return
		if main._meta == null:
			_fail("[%s] main._meta null after boot" % pack.id)
			return
		if main._encounter_pool == null:
			_fail("[%s] encounter pool null after boot" % pack.id)
			return
		if main._event_pool == null:
			_fail("[%s] event pool null after boot" % pack.id)
			return
		if main._relic_pool == null:
			_fail("[%s] relic pool null after boot" % pack.id)
			return
		if main._run_configs.is_empty():
			_fail("[%s] no RunConfigs loaded" % pack.id)
			return

		main.queue_free()
		await self.process_frame

	# Cleanup save the test created.
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

	print("smoke_themes: ok. all %d theme packs load + boot to hub cleanly." % PACK_PATHS.size())
	quit(0)

func _validate_pack_paths(pack: ThemePack) -> bool:
	for path in pack.run_config_paths:
		if load(path) == null:
			_fail("[%s] run_config_paths entry failed to load: %s" % [pack.id, path])
			return false
	for path in [pack.encounter_pool_path, pack.event_pool_path, pack.relic_pool_path,
		pack.player_class_path, pack.enemy_class_path]:
		if load(path) == null:
			_fail("[%s] required path failed to load: %s" % [pack.id, path])
			return false
	for path in pack.map_paths:
		if load(path) == null:
			_fail("[%s] map path failed to load: %s" % [pack.id, path])
			return false
	for path in pack.template_paths:
		if load(path) == null:
			_fail("[%s] template path failed to load: %s" % [pack.id, path])
			return false
	return true

func _fail(msg: String) -> void:
	push_error("smoke_themes: %s" % msg)
	quit(1)
