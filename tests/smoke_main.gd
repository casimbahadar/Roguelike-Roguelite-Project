extends SceneTree

# End-to-end smoke test for the Main glue scene. Walks:
#   delete prior save -> instance Main -> press Tutorial on
#   the Hub -> walk the run, pressing Resolve on battles,
#   first choice on map, the rest button on camp, the first
#   choice on events -> arrive at Result with VICTORY ->
#   press Result Continue -> back at Hub.
#
# The tutorial is used because it has a deterministic scripted
# layout (BATTLE, EVENT, CAMP, BATTLE, BOSS) — every node kind
# is covered, the run is short, and the seed is fixed.
#
# Run: godot --headless --script res://tests/smoke_main.gd

const MAIN_SCENE_PATH := "res://core/ui/main.tscn"
const SAVE_PATH := "user://meta.json"
const STEP_CAP := 60

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

	# Find the Tutorial button on the hub.
	var tutorial_btn: Button = _find_hub_button(main, "Tutorial: First March")
	if tutorial_btn == null:
		_fail("Tutorial button not found on hub")
		return

	tutorial_btn.emit_signal("pressed")

	# Node 0 of the tutorial is BATTLE — auto-trigger.
	if not main._battle.visible:
		_fail("battle screen should auto-show on node 0 (BATTLE)")
		return

	# Walk the run.
	var steps: int = 0
	while not main._result.visible and steps < STEP_CAP:
		if main._battle.visible:
			main._battle._resolve_btn.emit_signal("pressed")
		elif main._event.visible:
			# Pick the first choice, then the Continue.
			var first_choice: Button = _first_button_in(main._event._choices)
			if first_choice == null:
				_fail("event has no choice buttons")
				return
			first_choice.emit_signal("pressed")
			main._event._continue_btn.emit_signal("pressed")
		elif main._camp.visible:
			main._camp._rest_btn.emit_signal("pressed")
			main._camp._continue_btn.emit_signal("pressed")
		elif main._shop.visible:
			main._shop._leave_btn.emit_signal("pressed")
		elif main._shrine.visible:
			main._shrine._decline_btn.emit_signal("pressed")
			main._shrine._continue_btn.emit_signal("pressed")
		elif main._map.visible:
			var first_choice: Button = _first_button_in(main._map._choices)
			if first_choice == null:
				_fail("map has no choice buttons at step %d" % steps)
				return
			first_choice.emit_signal("pressed")
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

	# Cleanup.
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

	print("smoke_main: completed full hub -> map -> battle -> event -> camp -> result -> hub loop. steps=%d" % steps)
	quit(0)

func _find_hub_button(main: Main, text: String) -> Button:
	for child in main._hub._list.get_children():
		if child is Button and child.text == text:
			return child
	return null

func _first_button_in(container: Node) -> Button:
	for child in container.get_children():
		if child is Button:
			return child
	return null

func _fail(msg: String) -> void:
	push_error("smoke_main: %s" % msg)
	quit(1)
