class_name HubScreen
extends Control

# Hub screen — landing page after the title splash. Lists every
# known run format; unlocked ones are buttons, locked ones are
# greyed-out labels showing the unlock condition. Theme packs
# colour the look via a Theme resource; this script only knows
# about the data and which control type each row needs.

signal run_format_chosen(format_id: StringName)

var _list: VBoxContainer

func _ready() -> void:
	_list = get_node_or_null("Margin/VBox/List") as VBoxContainer
	if _list == null:
		push_error("HubScreen._ready: $Margin/VBox/List not found")

func populate(meta: MetaState, run_configs: Array[RunConfig]) -> void:
	# Defensive: if _ready hasn't fired yet (possible in some
	# headless smoke harnesses where add_child + populate can
	# fall before _ready in unusual cases), resolve _list now.
	if _list == null:
		_list = get_node_or_null("Margin/VBox/List") as VBoxContainer
	if _list == null:
		push_error("HubScreen.populate: $Margin/VBox/List not found")
		return
	for child in _list.get_children():
		child.queue_free()

	var unlocked: Array[RunConfig] = []
	var locked: Array[RunConfig] = []
	for cfg in run_configs:
		if MetaUnlocks.is_unlocked(meta, cfg.id):
			unlocked.append(cfg)
		else:
			locked.append(cfg)

	_list.add_child(_make_section_header("Available  (%d)" % unlocked.size()))
	for cfg in unlocked:
		_list.add_child(_make_unlocked_row(cfg))

	if not locked.is_empty():
		_list.add_child(_make_spacer(12))
		_list.add_child(_make_section_header("Locked  (%d)" % locked.size()))
		for cfg in locked:
			_list.add_child(_make_locked_row(cfg))

func _make_section_header(text: String) -> Label:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.theme_type_variation = "HeaderLarge"
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.modulate = Color(1, 1, 1, 0.85)
	return lbl

func _make_spacer(height: int) -> Control:
	var c: Control = Control.new()
	c.custom_minimum_size = Vector2(0, height)
	return c

func _make_unlocked_row(cfg: RunConfig) -> Button:
	var btn: Button = Button.new()
	btn.text = cfg.display_name
	btn.custom_minimum_size = Vector2(0, 56)  # touch-friendly tap target
	btn.pressed.connect(_on_format_pressed.bind(cfg.id))
	return btn

func _make_locked_row(cfg: RunConfig) -> Label:
	var lbl: Label = Label.new()
	lbl.text = "%s — clear %s first" % [cfg.display_name, _prereq_label(cfg.id)]
	lbl.modulate = Color(1, 1, 1, 0.45)
	lbl.custom_minimum_size = Vector2(0, 48)
	return lbl

func _prereq_label(format_id: StringName) -> String:
	if MetaUnlocks.PREREQUISITES.has(format_id):
		var prereq: StringName = MetaUnlocks.PREREQUISITES[format_id]
		return String(prereq)
	return "?"

func _on_format_pressed(format_id: StringName) -> void:
	run_format_chosen.emit(format_id)
