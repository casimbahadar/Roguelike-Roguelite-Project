class_name HubScreen
extends Control

# Hub screen — landing page after the title splash. Lists every
# known run format; unlocked ones are buttons, locked ones are
# greyed-out labels showing the unlock condition. Theme packs
# colour the look via a Theme resource; this script only knows
# about the data and which control type each row needs.

signal run_format_chosen(format_id: StringName)

@onready var _list: VBoxContainer = $Margin/VBox/List

func populate(meta: MetaState, run_configs: Array[RunConfig]) -> void:
	for child in _list.get_children():
		child.queue_free()
	for cfg in run_configs:
		_list.add_child(_make_row(meta, cfg))

func _make_row(meta: MetaState, cfg: RunConfig) -> Control:
	if MetaUnlocks.is_unlocked(meta, cfg.id):
		var btn: Button = Button.new()
		btn.text = cfg.display_name
		btn.custom_minimum_size = Vector2(0, 56)  # touch-friendly tap target
		btn.pressed.connect(_on_format_pressed.bind(cfg.id))
		return btn
	var lbl: Label = Label.new()
	lbl.text = "%s — locked (clear %s first)" % [cfg.display_name, _prereq_label(cfg.id)]
	lbl.modulate = Color(1, 1, 1, 0.5)
	lbl.custom_minimum_size = Vector2(0, 56)
	return lbl

func _prereq_label(format_id: StringName) -> String:
	if MetaUnlocks.PREREQUISITES.has(format_id):
		var prereq: StringName = MetaUnlocks.PREREQUISITES[format_id]
		return String(prereq)
	return "?"

func _on_format_pressed(format_id: StringName) -> void:
	run_format_chosen.emit(format_id)
