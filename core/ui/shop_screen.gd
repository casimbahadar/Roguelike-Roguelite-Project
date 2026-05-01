class_name ShopScreen
extends Control

# Slay-the-Spire-style shop: three random relics drawn from the
# theme's RelicPool, each priced by rarity. Player buys one (or
# leaves) and Main returns to the campaign map.
#
# Pricing:
#   COMMON    →  6 gold
#   UNCOMMON  → 12 gold
#   RARE      → 22 gold
#   LEGENDARY → 40 gold
#
# Out-of-budget items render greyed-out; clicking does nothing.
# The Leave button is always available so the player isn't stuck
# at a node they can't afford.

signal shop_left

const PRICES: Dictionary = {
	RelicDef.Rarity.COMMON: 6,
	RelicDef.Rarity.UNCOMMON: 12,
	RelicDef.Rarity.RARE: 22,
	RelicDef.Rarity.LEGENDARY: 40,
}

var _run_state: RunState

var _gold_label: Label
var _items: VBoxContainer
var _leave_btn: Button

func _ready() -> void:
	_ensure_nodes()

func _ensure_nodes() -> void:
	if _gold_label == null:
		_gold_label = get_node_or_null("Margin/VBox/Gold") as Label
	if _items == null:
		_items = get_node_or_null("Margin/VBox/Items") as VBoxContainer
	if _leave_btn == null:
		_leave_btn = get_node_or_null("Margin/VBox/LeaveBtn") as Button

func bind_shop(p_run: RunState, offered: Array[RelicDef]) -> void:
	_ensure_nodes()
	_run_state = p_run
	if not _leave_btn.pressed.is_connected(_on_leave_pressed):
		_leave_btn.pressed.connect(_on_leave_pressed)
	_render(offered)

func _render(offered: Array[RelicDef]) -> void:
	_gold_label.text = "Gold: %d" % _run_state.gold
	while _items.get_child_count() > 0:
		var stale: Node = _items.get_child(0)
		_items.remove_child(stale)
		stale.queue_free()
	for relic in offered:
		_items.add_child(_make_item_row(relic))

func _make_item_row(relic: RelicDef) -> Control:
	var row: HBoxContainer = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 56)
	row.add_theme_constant_override("separation", 12)

	var price: int = price_of(relic)
	var btn: Button = Button.new()
	btn.text = "%s — %d gold" % [relic.display_name, price]
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if price > _run_state.gold:
		btn.disabled = true
		btn.modulate = Color(1, 1, 1, 0.5)
	else:
		btn.pressed.connect(_on_buy_pressed.bind(relic, price))
	row.add_child(btn)

	var desc: Label = Label.new()
	desc.text = relic.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc.size_flags_stretch_ratio = 2.0
	row.add_child(desc)

	return row

func _on_buy_pressed(relic: RelicDef, price: int) -> void:
	if _run_state.gold < price:
		return
	_run_state.gold -= price
	_run_state.relics.append(relic)
	shop_left.emit()

func _on_leave_pressed() -> void:
	shop_left.emit()

static func price_of(relic: RelicDef) -> int:
	return PRICES.get(relic.rarity, 10)
