extends SceneTree

# Headless smoke test for the meta layer. Exercises:
#   * fresh MetaState defaults (skirmish + daily already open)
#   * SaveSystem.save -> SaveSystem.load round-trip
#   * MetaUnlocks.on_run_completed flips standard / boss_rush / iron
#     open after a skirmish... wait, no — the prereq for those is
#     standard, not skirmish. After clearing skirmish, only
#     standard should newly unlock. After clearing standard,
#     long / boss_rush / iron should follow.
#
# Test path:
#   1. Build a fresh MetaState.
#   2. Save it, load it, assert round-trip preserves defaults.
#   3. Complete skirmish — assert standard unlocks.
#   4. Complete standard — assert long, boss_rush, iron unlock.
#   5. Save, reload, assert unlocks persisted.
#
# Run: godot --headless --script res://tests/smoke_meta.gd

const TEST_SAVE_PATH := "user://smoke_meta_test.json"

func _initialize() -> void:
	# Clean up any previous test save.
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))

	# 1. Fresh state.
	var meta: MetaState = MetaState.new()
	MetaUnlocks.recompute_unlocks(meta)
	if not meta.has_run_format(&"skirmish"):
		_fail("skirmish should be unlocked by default")
		return
	if not meta.has_run_format(&"daily"):
		_fail("daily should be unlocked by default")
		return
	if meta.has_run_format(&"standard"):
		_fail("standard should NOT be unlocked before any clears")
		return

	# 2. Save / load round-trip on the default state.
	if not SaveSystem.save(meta.to_dict(), TEST_SAVE_PATH):
		_fail("SaveSystem.save returned false")
		return
	var loaded_dict: Dictionary = SaveSystem.load(TEST_SAVE_PATH)
	var loaded: MetaState = MetaState.from_dict(loaded_dict)
	if not loaded.has_run_format(&"skirmish") or not loaded.has_run_format(&"daily"):
		_fail("round-trip lost default unlocks")
		return
	if loaded.meta_currency != 0:
		_fail("round-trip changed meta_currency: got %d" % loaded.meta_currency)
		return

	# 3. Clearing skirmish unlocks standard (and only standard).
	var newly_after_skirmish: Array[StringName] = MetaUnlocks.on_run_completed(loaded, &"skirmish")
	if not loaded.has_run_format(&"standard"):
		_fail("standard should unlock after clearing skirmish; got %s" % str(loaded.unlocked_run_formats))
		return
	if loaded.has_run_format(&"long") or loaded.has_run_format(&"iron"):
		_fail("long/iron should still be locked after only skirmish")
		return
	if not (&"standard" in newly_after_skirmish):
		_fail("on_run_completed should report standard as newly unlocked; got %s" % str(newly_after_skirmish))
		return

	# 4. Clearing standard unlocks long, boss_rush, iron.
	var newly_after_standard: Array[StringName] = MetaUnlocks.on_run_completed(loaded, &"standard")
	for expected in [&"long", &"boss_rush", &"iron"]:
		if not loaded.has_run_format(expected):
			_fail("%s should unlock after clearing standard; got %s" % [expected, str(loaded.unlocked_run_formats)])
			return
		if not (expected in newly_after_standard):
			_fail("on_run_completed should report %s as newly unlocked" % expected)
			return

	# 5. Persistence of post-clears save.
	if not SaveSystem.save(loaded.to_dict(), TEST_SAVE_PATH):
		_fail("SaveSystem.save (second) returned false")
		return
	var reloaded: MetaState = MetaState.from_dict(SaveSystem.load(TEST_SAVE_PATH))
	for expected in [&"skirmish", &"daily", &"standard", &"long", &"boss_rush", &"iron"]:
		if not reloaded.has_run_format(expected):
			_fail("reloaded state missing %s" % expected)
			return
	if reloaded.completed_count(&"skirmish") != 1:
		_fail("reloaded skirmish completed_count != 1")
		return
	if reloaded.completed_count(&"standard") != 1:
		_fail("reloaded standard completed_count != 1")
		return

	# Clean up so reruns start fresh.
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))

	print("smoke_meta: ok. final unlocks=%s" % str(reloaded.unlocked_run_formats))
	quit(0)

func _fail(msg: String) -> void:
	push_error("smoke_meta: %s" % msg)
	quit(1)
