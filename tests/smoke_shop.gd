extends SceneTree

# Headless smoke test for ShopScreen. Verifies:
#
#   * bind_shop renders one Items row per offered relic plus a
#     Leave button.
#   * Pressing a buyable item deducts the price, adds the relic
#     to RunState.relics, and emits shop_left.
#   * Pressing Leave emits shop_left without changing state.
#   * Items priced above the player's current gold render
#     disabled.
#
# Run: godot --headless --script res://tests/smoke_shop.gd

const SKIRMISH_PATH := "res://games/sengoku/data/runs/skirmish.tres"
const BANNER_PATH := "res://games/sengoku/data/relics/banner_of_ash.tres"
const RESIN_PATH := "res://games/sengoku/data/relics/comets_resin.tres"

var _left_seen: bool = false

func _initialize() -> void:
	var config: RunConfig = load(SKIRMISH_PATH)
	if config == null:
		_fail("failed to load run config")
		return
	var banner: RelicDef = load(BANNER_PATH)  # COMMON, 6 gold
	var resin: RelicDef = load(RESIN_PATH)    # RARE,   22 gold
	if banner == null or resin == null:
		_fail("failed to load relic .tres")
		return

	var party: Array[UnitDef] = []
	var run: RunState = RunState.new(config, 1234, party)
	run.gold = 10  # enough for banner, not enough for resin

	var scene: PackedScene = load("res://core/ui/shop_screen.tscn")
	var screen: ShopScreen = scene.instantiate()
	root.add_child(screen)
	screen.shop_left.connect(_on_shop_left)

	var offered: Array[RelicDef] = [banner, resin]
	screen.bind_shop(run, offered)

	# Two item rows + leave button (handled separately in tscn).
	if screen._items.get_child_count() != offered.size():
		_fail("expected %d item rows, got %d" % [offered.size(), screen._items.get_child_count()])
		return

	# First row = banner (affordable). Find the button inside.
	var banner_btn: Button = _find_button_in_row(screen._items.get_child(0))
	if banner_btn == null:
		_fail("banner row should contain a Button")
		return
	if banner_btn.disabled:
		_fail("banner button should be enabled at 10 gold (price 6)")
		return
	if not banner_btn.text.contains("Banner of Ash"):
		_fail("banner button text should mention the relic name; got '%s'" % banner_btn.text)
		return

	# Second row = resin (out of budget). Button should be disabled.
	var resin_btn: Button = _find_button_in_row(screen._items.get_child(1))
	if resin_btn == null:
		_fail("resin row should contain a Button")
		return
	if not resin_btn.disabled:
		_fail("resin button should be disabled at 10 gold (price 22)")
		return

	# Pressing the banner button should deduct 6 gold and add the relic.
	banner_btn.emit_signal("pressed")
	if not _left_seen:
		_fail("buy should emit shop_left")
		return
	if run.gold != 4:
		_fail("after buy: expected gold=4 (10-6), got %d" % run.gold)
		return
	if run.relics.size() != 1 or run.relics[0].id != banner.id:
		_fail("after buy: expected relics=[banner], got %s" % str(run.relics))
		return

	# Now test the Leave path on a fresh shop state.
	_left_seen = false
	run.gold = 50
	run.relics.clear()
	screen.bind_shop(run, [banner])
	screen._leave_btn.emit_signal("pressed")
	if not _left_seen:
		_fail("leave should emit shop_left")
		return
	if run.gold != 50 or not run.relics.is_empty():
		_fail("leave should not change state; gold=%d relics=%d" % [run.gold, run.relics.size()])
		return

	print("smoke_shop: ok. buy deducts gold, leave is no-op, out-of-budget rows disabled.")
	quit(0)

func _find_button_in_row(row: Node) -> Button:
	for child in row.get_children():
		if child is Button:
			return child
	return null

func _on_shop_left() -> void:
	_left_seen = true

func _fail(msg: String) -> void:
	push_error("smoke_shop: %s" % msg)
	quit(1)
