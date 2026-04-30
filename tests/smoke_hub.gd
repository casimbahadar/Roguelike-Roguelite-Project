extends SceneTree

# Headless smoke test for the Hub screen. Instances the .tscn,
# populates it from a fresh MetaState, and verifies the row mix
# matches the unlock graph: with no clears yet, only skirmish
# should be a Button — standard / long / iron should be Labels.
#
# Run: godot --headless --script res://tests/smoke_hub.gd

const RUN_CONFIG_PATHS: Array[String] = [
	"res://games/sengoku/data/runs/skirmish.tres",
	"res://games/sengoku/data/runs/standard.tres",
	"res://games/sengoku/data/runs/long.tres",
	"res://games/sengoku/data/runs/iron.tres",
]

func _initialize() -> void:
	var configs: Array[RunConfig] = []
	for path in RUN_CONFIG_PATHS:
		var cfg: RunConfig = load(path)
		if cfg == null:
			push_error("smoke_hub: failed to load %s" % path)
			quit(1)
			return
		configs.append(cfg)

	var hub_scene: PackedScene = load("res://core/ui/hub.tscn")
	if hub_scene == null:
		push_error("smoke_hub: failed to load hub.tscn")
		quit(1)
		return

	var meta: MetaState = MetaState.new()
	MetaUnlocks.recompute_unlocks(meta)

	var hub: HubScreen = hub_scene.instantiate()
	root.add_child(hub)  # triggers _ready, resolves @onready paths
	hub.populate(meta, configs)

	var list: VBoxContainer = hub._list
	if list.get_child_count() != configs.size():
		push_error("smoke_hub: expected %d rows, got %d" % [configs.size(), list.get_child_count()])
		quit(1)
		return

	# Skirmish row (index 0) should be a Button — it's the only unlocked format here.
	var first_row: Node = list.get_child(0)
	if not (first_row is Button):
		push_error("smoke_hub: first row should be Button (unlocked skirmish), got %s" % first_row.get_class())
		quit(1)
		return

	# The other three should be Labels (locked).
	for i in range(1, configs.size()):
		var row: Node = list.get_child(i)
		if not (row is Label):
			push_error("smoke_hub: row %d should be Label (locked), got %s" % [i, row.get_class()])
			quit(1)
			return

	print("smoke_hub: ok. %d rows, 1 unlocked + %d locked" % [list.get_child_count(), list.get_child_count() - 1])
	quit(0)
