class_name TitleScreen
extends Control

# The first screen the player sees on launch. Lists every
# ThemePack the project ships with; clicking a button calls
# Main.set_theme_pack() and switches to the Main scene under the
# selected theme. The four games share one engine, so the title
# screen IS the entry point for picking which game.

signal theme_chosen(pack: ThemePack)

const PACK_PATHS: Array[String] = [
	"res://games/sengoku/sengoku_pack.tres",
	"res://games/crystal/crystal_pack.tres",
	"res://games/pocketkin/pocketkin_pack.tres",
	"res://games/datapact/datapact_pack.tres",
]

var _list: VBoxContainer

func _ready() -> void:
	_ensure_nodes()
	populate()

func _ensure_nodes() -> void:
	if _list == null:
		_list = get_node_or_null("Margin/VBox/PackList") as VBoxContainer

func populate() -> void:
	if _list == null:
		_list = get_node_or_null("Margin/VBox/PackList") as VBoxContainer
	if _list == null:
		push_error("TitleScreen.populate: PackList node not found")
		return
	while _list.get_child_count() > 0:
		var stale: Node = _list.get_child(0)
		_list.remove_child(stale)
		stale.queue_free()
	for path in PACK_PATHS:
		var pack: ThemePack = load(path)
		if pack == null:
			continue
		_list.add_child(_make_pack_row(pack))

func _make_pack_row(pack: ThemePack) -> Control:
	var row: VBoxContainer = VBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 84)
	row.add_theme_constant_override("separation", 4)

	var btn: Button = Button.new()
	btn.text = pack.display_name
	btn.custom_minimum_size = Vector2(0, 56)
	btn.pressed.connect(_on_pack_chosen.bind(pack))
	row.add_child(btn)

	if pack.tagline != "":
		var tagline_lbl: Label = Label.new()
		tagline_lbl.text = pack.tagline
		tagline_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tagline_lbl.modulate = Color(1, 1, 1, 0.7)
		row.add_child(tagline_lbl)

	return row

func _on_pack_chosen(pack: ThemePack) -> void:
	theme_chosen.emit(pack)
