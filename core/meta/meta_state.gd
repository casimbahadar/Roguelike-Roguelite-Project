class_name MetaState
extends RefCounted

# Cross-run progression. Lives in user://meta.json; the schema is
# whatever to_dict() emits and from_dict() reads. Strings/ints/
# arrays/dicts only — JSON-clean, per CLAUDE.md.
#
# Field rationale:
#   runs_completed / runs_attempted: tracked per run-format id so
#     unlock rules can ask "have they cleared standard?" cheaply.
#   meta_currency: a single generic counter; theme packs decide
#     whether it surfaces as gold, honor, or crystals in the UI.
#   best_runs: per-format dictionaries (seed, time_seconds, score)
#     to drive the hub's "personal best" display and the daily
#     leaderboard payload.

var unlocked_run_formats: Array[StringName] = [&"skirmish"]
var unlocked_classes: Array[StringName] = []
var unlocked_commanders: Array[StringName] = []
var meta_currency: int = 0
var runs_completed: Dictionary = {}  # run_format_id (String) -> int
var runs_attempted: Dictionary = {}
var best_runs: Dictionary = {}       # run_format_id (String) -> { seed, time_seconds, score }
var cosmetics_owned: Array[StringName] = []

func to_dict() -> Dictionary:
	return {
		"unlocked_run_formats": _string_names_to_strings(unlocked_run_formats),
		"unlocked_classes": _string_names_to_strings(unlocked_classes),
		"unlocked_commanders": _string_names_to_strings(unlocked_commanders),
		"meta_currency": meta_currency,
		"runs_completed": runs_completed,
		"runs_attempted": runs_attempted,
		"best_runs": best_runs,
		"cosmetics_owned": _string_names_to_strings(cosmetics_owned),
	}

static func from_dict(d: Dictionary) -> MetaState:
	var m: MetaState = MetaState.new()
	if d.is_empty():
		return m  # fresh save
	m.unlocked_run_formats = _strings_to_string_names(d.get("unlocked_run_formats", []))
	m.unlocked_classes = _strings_to_string_names(d.get("unlocked_classes", []))
	m.unlocked_commanders = _strings_to_string_names(d.get("unlocked_commanders", []))
	m.meta_currency = int(d.get("meta_currency", 0))
	m.runs_completed = d.get("runs_completed", {})
	m.runs_attempted = d.get("runs_attempted", {})
	m.best_runs = d.get("best_runs", {})
	m.cosmetics_owned = _strings_to_string_names(d.get("cosmetics_owned", []))
	return m

func has_run_format(id: StringName) -> bool:
	return unlocked_run_formats.has(id)

func record_run_attempted(run_id: StringName) -> void:
	var key: String = String(run_id)
	runs_attempted[key] = int(runs_attempted.get(key, 0)) + 1

func record_run_completed(run_id: StringName) -> void:
	var key: String = String(run_id)
	runs_completed[key] = int(runs_completed.get(key, 0)) + 1

func completed_count(run_id: StringName) -> int:
	return int(runs_completed.get(String(run_id), 0))

static func _string_names_to_strings(arr: Array) -> Array:
	var out: Array = []
	for n in arr:
		out.append(String(n))
	return out

static func _strings_to_string_names(arr: Array) -> Array[StringName]:
	var out: Array[StringName] = []
	for s in arr:
		out.append(StringName(s))
	return out
