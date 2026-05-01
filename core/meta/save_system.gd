class_name SaveSystem
extends RefCounted

# JSON-only persistence (per CLAUDE.md: cross-platform cloud sync,
# no engine-specific binary blobs). Saves go to user:// — Godot
# resolves that to a per-user app-data directory on every platform
# we ship to.
#
# Callers pass plain Dictionaries (or arrays of dicts) — anything
# that round-trips through JSON.stringify / JSON.parse. The Save
# system itself doesn't know about MetaState; that mapping lives
# on MetaState.to_dict() / from_dict().

const DEFAULT_PATH := "user://meta.json"

# Returns true on success.
static func save(data: Dictionary, path: String = DEFAULT_PATH) -> bool:
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("SaveSystem.save: could not open %s for writing (err=%d)" % [path, FileAccess.get_open_error()])
		return false
	f.store_string(JSON.stringify(data, "  "))
	f.close()
	return true

# Returns the parsed Dictionary, or an empty Dictionary if the
# file is missing or corrupt. Callers can distinguish the two
# cases with FileAccess.file_exists(path) before calling.
static func load(path: String = DEFAULT_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("SaveSystem.load: could not open %s (err=%d)" % [path, FileAccess.get_open_error()])
		return {}
	var raw: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveSystem.load: %s did not parse to a Dictionary" % path)
		return {}
	return parsed
