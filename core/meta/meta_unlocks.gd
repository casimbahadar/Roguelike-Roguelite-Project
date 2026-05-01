class_name MetaUnlocks
extends RefCounted

# Encodes the run-format unlock graph from
# docs/design/run_formats.md.  Pure functions over MetaState —
# no IO, no side effects beyond the meta_state mutation in
# on_run_completed().
#
# Format gates (must match the design doc):
#   skirmish   -> always available
#   standard   -> clear skirmish 1+ time
#   long       -> clear standard 1+ time
#   saga       -> clear long 1+ time
#   endless    -> clear long 1+ time
#   boss_rush  -> clear standard 1+ time
#   daily      -> always (it's the meta-hub draw card)
#   iron       -> clear standard 1+ time

const ALWAYS_OPEN: Array[StringName] = [&"tutorial", &"skirmish", &"daily"]

const PREREQUISITES: Dictionary = {
	&"standard":  &"skirmish",
	&"long":      &"standard",
	&"saga":      &"long",
	&"endless":   &"long",
	&"boss_rush": &"standard",
	&"iron":      &"standard",
}

# True if this format should currently appear available on the hub.
static func is_unlocked(meta: MetaState, format_id: StringName) -> bool:
	if format_id in ALWAYS_OPEN:
		return true
	if not PREREQUISITES.has(format_id):
		# Unknown format — treat as locked so a typo doesn't accidentally unlock something.
		return false
	var prereq: StringName = PREREQUISITES[format_id]
	return meta.completed_count(prereq) > 0

# Updates meta.unlocked_run_formats based on what is now unlocked
# given current completion counts. Returns the list of formats
# that flipped from locked to unlocked on this call.
static func recompute_unlocks(meta: MetaState) -> Array[StringName]:
	var newly: Array[StringName] = []
	# Always-open first (covers the very first launch).
	for f in ALWAYS_OPEN:
		if not meta.unlocked_run_formats.has(f):
			meta.unlocked_run_formats.append(f)
			newly.append(f)
	# Prereq-gated.
	for f in PREREQUISITES.keys():
		if meta.unlocked_run_formats.has(f):
			continue
		if is_unlocked(meta, f):
			meta.unlocked_run_formats.append(f)
			newly.append(f)
	return newly

# Convenience: record completion + recompute unlocks in one call.
# Returns newly unlocked formats (often empty).
static func on_run_completed(meta: MetaState, run_id: StringName) -> Array[StringName]:
	meta.record_run_completed(run_id)
	return recompute_unlocks(meta)
