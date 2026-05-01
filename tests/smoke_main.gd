extends SceneTree

# End-to-end smoke test for the Main glue scene. Walks:
#   delete prior save -> instance Main -> press Tutorial on
#   the Hub -> walk the run, pressing Resolve on battles,
#   first choice on map, the rest button on camp, the first
#   choice on events -> arrive at Result with VICTORY ->
#   press Result Continue -> back at Hub.
#
# Uses the tutorial RunConfig — deterministic scripted layout
# (BATTLE, EVENT, CAMP, BATTLE, BOSS), short, fixed seed.
#
# Frame yields: between every screen transition we await one
# process_frame. Several of the screens use queue_free to clear
# children, and queue_free is deferred — without yielding to a
# frame tick, the deletions never complete and stale buttons
# linger. The yield gives Godot a chance to drain the deletion
# queue between iterations.
#
# Run: godot --headless --script res://tests/smoke_main.gd

const MAIN_SCENE_PATH := "res://core/ui/main.tscn"
const SAVE_PATH := "user://meta.json"
const STEP_CAP := 30

func _initialize() -> void:
	# Start fresh.
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

	var scene: PackedScene = load(MAIN_SCENE_PATH)
	if scene == null:
		_fail("could not load main.tscn")
		return

	var main: Main = scene.instantiate()
	root.add_child(main)
	# Yield one frame so _ready, @onready resolution, and any
	# initial layout work all complete before we start poking.
	await self.process_frame

	if main._hub == null:
		_fail("main._hub is null after add_child + frame yield")
		return
	if not main._hub.visible:
		_fail("hub should be visible after _ready (got visible=%s)" % str(main._hub.visible))
		return

	# Find the Tutorial button on the hub.
	var tutorial_btn: Button = _find_hub_button(main, "Tutorial: First March")
	if tutorial_btn == null:
		_fail("Tutorial button not found on hub")
		return

	tutorial_btn.emit_signal("pressed")
	await self.process_frame  # let the screen transition + auto-battle settle

	if not main._battle.visible:
		_fail("battle screen should auto-show on node 0 (BATTLE), but visible=%s" % str(main._battle.visible))
		return

	# Walk the run. Each iteration drives whichever screen is
	# currently visible, then awaits a frame so deferred deletions
	# and visibility flips fully settle before the next iteration.
	var steps: int = 0
	while not main._result.visible and steps < STEP_CAP:
		if main._battle.visible:
			main._battle._resolve_btn.emit_signal("pressed")
		elif main._event.visible:
			var first_choice: Button = _first_button_in(main._event._choices)
			if first_choice == null:
				_fail("event has no choice buttons at step %d" % steps)
				return
			first_choice.emit_signal("pressed")
			await self.process_frame
			main._event._continue_btn.emit_signal("pressed")
		elif main._camp.visible:
			main._camp._rest_btn.emit_signal("pressed")
			await self.process_frame
			main._camp._continue_btn.emit_signal("pressed")
		elif main._shop.visible:
			main._shop._leave_btn.emit_signal("pressed")
		elif main._shrine.visible:
			main._shrine._decline_btn.emit_signal("pressed")
			await self.process_frame
			main._shrine._continue_btn.emit_signal("pressed")
		elif main._map.visible:
			var first_choice: Button = _first_button_in(main._map._choices)
			if first_choice == null:
				_fail("map has no choice buttons at step %d (current node index=%d)" % [steps, main._run_state.current_node_index])
				return
			first_choice.emit_signal("pressed")
		else:
			_fail("no screen visible at step %d — broken state" % steps)
			return
		await self.process_frame
		steps += 1

	if not main._result.visible:
		_fail("result screen never reached after %d steps" % STEP_CAP)
		return

	# Press Result Continue → back to Hub.
	main._result._continue_btn.emit_signal("pressed")
	await self.process_frame

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
