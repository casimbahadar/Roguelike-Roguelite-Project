extends SceneTree

# End-to-end smoke test for the Main glue scene. Walks:
#   delete prior save -> instance Main -> press Skirmish on the Hub
#   -> walk the run alternating battle Resolve and map Continue
#   presses -> arrive at Result with VICTORY -> press Result Continue
#   -> back at Hub with Standard now unlocked.
#
# Run: godot --headless --script res://tests/smoke_main.gd

const MAIN_SCENE_PATH := "res://core/ui/main.tscn"
const SAVE_PATH := "user://meta.json"
const STEP_CAP := 200

func _initialize() -> void:
	# Start fresh.
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

	var scene: PackedScene = load(MAIN_SCENE_PATH)
	if scene == null:
		_fail("could not load main.tscn")
		return

	var main: Main = scene.instantiate()
	root.add_child(main)  # triggers _ready -> _load_data -> _show_hub

	if not main._hub.visible:
		_fail("hub should be visible after _ready")
		return

	# Find the Skirmish button on the hub.
	var skirmish_btn: Button = null
	for child in main._hub._list.get_children():
		if child is Button and child.text == "Skirmish":
			skirmish_btn = child
			break
	if skirmish_btn == null:
		_fail("Skirmish button not found on hub")
		return

	skirmish_btn.emit_signal("pressed")

	# Node 0 should auto-trigger a battle.
	if not main._battle.visible:
		_fail("battle screen should auto-show on node 0 (BATTLE)")
		return

	# Walk the run.
	var steps: int = 0
	while not main._result.visible and steps < STEP_CAP:
		if main._battle.visible:
			main._battle._resolve_btn.emit_signal("pressed")
		elif main._map.visible:
			if main._map._continue_btn.disabled:
				_fail("map Continue is disabled but no result/battle showing — stuck")
				return
			main._map._continue_btn.emit_signal("pressed")
		else:
			_fail("no screen visible at step %d — broken state" % steps)
			return
		steps += 1

	if not main._result.visible:
		_fail("result screen never reached after %d steps" % STEP_CAP)
		return

	# Press Result Continue → back to Hub.
	main._result._continue_btn.emit_signal("pressed")

	if not main._hub.visible:
		_fail("hub should be visible after result continue")
		return

	# After clearing skirmish, standard must be unlocked.
	if not main._meta.has_run_format(&"standard"):
		_fail("standard should be unlocked after winning skirmish; got %s" % str(main._meta.unlocked_run_formats))
		return

	# Cleanup.
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

	print("smoke_main: completed full hub -> map -> battle -> result -> hub loop. steps=%d" % steps)
	quit(0)

func _fail(msg: String) -> void:
	push_error("smoke_main: %s" % msg)
	quit(1)
