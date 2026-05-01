extends SceneTree

# Headless smoke test for the Hub screen. Instances the .tscn,
# populates it from a fresh MetaState, and verifies the section
# layout: with no clears yet, exactly one Button (Skirmish, the
# unlocked format) and three Labels naming the locked formats
# (Standard / Long / Iron) plus two section headers.
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
			_fail("failed to load %s" % path)
			return
		configs.append(cfg)

	var hub_scene: PackedScene = load("res://core/ui/hub.tscn")
	if hub_scene == null:
		_fail("failed to load hub.tscn")
		return

	var meta: MetaState = MetaState.new()
	MetaUnlocks.recompute_unlocks(meta)

	var hub: HubScreen = hub_scene.instantiate()
	root.add_child(hub)
	hub.populate(meta, configs)

	if hub._list == null:
		_fail("hub._list is null after populate (scene path Margin/VBox/List didn't resolve)")
		return

	# Buttons should appear only for unlocked formats. With a fresh
	# MetaState the only unlocked one in our config list is Skirmish.
	var buttons: Array[Button] = []
	var label_texts: Array[String] = []
	for child in hub._list.get_children():
		if child is Button:
			buttons.append(child)
		elif child is Label:
			label_texts.append(child.text)

	if buttons.size() != 1:
		_fail("expected exactly 1 Button (Skirmish), got %d" % buttons.size())
		return
	if buttons[0].text != "Skirmish":
		_fail("the unlocked button should say Skirmish, got %s" % buttons[0].text)
		return

	# Locked labels should mention each locked format by name.
	var locked_format_names: Array[String] = ["Standard Campaign", "Long Campaign", "Iron Run"]
	for needle in locked_format_names:
		var found: bool = false
		for txt in label_texts:
			if txt.contains(needle):
				found = true
				break
		if not found:
			_fail("expected a label mentioning %s, got %s" % [needle, str(label_texts)])
			return

	print("smoke_hub: ok. 1 unlocked button, %d label rows including section headers" % label_texts.size())
	quit(0)

func _fail(msg: String) -> void:
	push_error("smoke_hub: %s" % msg)
	quit(1)
