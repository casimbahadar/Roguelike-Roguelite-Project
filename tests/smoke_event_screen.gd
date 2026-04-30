extends SceneTree

# Headless smoke test for EventScreen. Loads wandering_monk.tres,
# instances the screen, binds the event, and verifies:
#
#   * Title and body match the EventDef.
#   * One Button per choice is rendered.
#   * Pressing a choice hides the choice list, reveals the
#     outcome text and Continue button.
#   * Pressing Continue emits event_resolved with the chosen
#     EventChoice (matching gold_delta etc.).
#
# Run: godot --headless --script res://tests/smoke_event_screen.gd

const EVENT_PATH := "res://games/sengoku/data/events/wandering_monk.tres"

var _resolved_choice: EventChoice
var _resolved_seen: bool = false

func _initialize() -> void:
	var event_def: EventDef = load(EVENT_PATH)
	if event_def == null:
		_fail("failed to load %s" % EVENT_PATH)
		return

	var scene: PackedScene = load("res://core/ui/event_screen.tscn")
	if scene == null:
		_fail("failed to load event_screen.tscn")
		return

	var screen: EventScreen = scene.instantiate()
	root.add_child(screen)
	screen.event_resolved.connect(_on_event_resolved)
	screen.bind_event(event_def)

	if screen._title.text != event_def.display_name:
		_fail("title mismatch: %s vs %s" % [screen._title.text, event_def.display_name])
		return
	if screen._body.text != event_def.body:
		_fail("body mismatch")
		return
	if screen._choices.get_child_count() != event_def.choices.size():
		_fail("expected %d choice buttons, got %d" % [event_def.choices.size(), screen._choices.get_child_count()])
		return
	if screen._outcome.visible:
		_fail("outcome should be hidden before a choice")
		return
	if screen._continue_btn.visible:
		_fail("ContinueBtn should be hidden before a choice")
		return

	# Press the first choice ("Offer rice" — gold_delta -5, meta_currency_delta +6).
	var first_btn: Node = screen._choices.get_child(0)
	first_btn.emit_signal("pressed")

	if screen._choices.visible:
		_fail("choices should be hidden after a pick")
		return
	if not screen._outcome.visible:
		_fail("outcome should be visible after a pick")
		return
	if not screen._continue_btn.visible:
		_fail("ContinueBtn should be visible after a pick")
		return
	if screen._outcome.text != event_def.choices[0].outcome_text:
		_fail("outcome text mismatch")
		return

	# Press Continue and verify the resolved signal.
	screen._continue_btn.emit_signal("pressed")
	if not _resolved_seen:
		_fail("event_resolved signal did not fire")
		return
	if _resolved_choice == null:
		_fail("event_resolved fired with null choice")
		return
	if _resolved_choice.gold_delta != event_def.choices[0].gold_delta:
		_fail("resolved choice gold_delta mismatch: %d vs %d" % [_resolved_choice.gold_delta, event_def.choices[0].gold_delta])
		return

	print("smoke_event_screen: ok. resolved %s (gold=%d, meta=%d)" % [
		_resolved_choice.label, _resolved_choice.gold_delta, _resolved_choice.meta_currency_delta,
	])
	quit(0)

func _on_event_resolved(chosen: EventChoice) -> void:
	_resolved_seen = true
	_resolved_choice = chosen

func _fail(msg: String) -> void:
	push_error("smoke_event_screen: %s" % msg)
	quit(1)
