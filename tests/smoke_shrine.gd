extends SceneTree

# Headless smoke test for ShrineScreen. Verifies:
#
#   * bind_shrine renders the offer text and enables Accept iff
#     the player has enough gold for the sacrifice.
#   * Accepting deducts SACRIFICE_COST and adds the relic.
#   * Declining leaves state unchanged.
#   * Both paths reveal the outcome label and the Continue
#     button; pressing Continue emits shrine_left.
#
# Run: godot --headless --script res://tests/smoke_shrine.gd

const SKIRMISH_PATH := "res://games/sengoku/data/runs/skirmish.tres"
const RESIN_PATH := "res://games/sengoku/data/relics/comets_resin.tres"

var _left_seen: bool = false

func _initialize() -> void:
	var config: RunConfig = load(SKIRMISH_PATH)
	var resin: RelicDef = load(RESIN_PATH)
	if config == null or resin == null:
		_fail("failed to load test fixtures")
		return

	var party: Array[UnitDef] = []
	var run: RunState = RunState.new(config, 5678, party)

	var scene: PackedScene = load("res://core/ui/shrine_screen.tscn")
	var screen: ShrineScreen = scene.instantiate()
	root.add_child(screen)
	screen.shrine_left.connect(_on_shrine_left)

	# Path A: gold below cost — Accept disabled, Decline works.
	run.gold = 5
	run.relics.clear()
	screen.bind_shrine(run, resin)
	if not screen._accept_btn.disabled:
		_fail("Accept should be disabled at gold=5 (cost=18)")
		return
	if screen._continue_btn.visible:
		_fail("Continue should be hidden before resolution")
		return

	screen._decline_btn.emit_signal("pressed")
	if not screen._outcome.visible:
		_fail("decline should reveal outcome")
		return
	if not screen._continue_btn.visible:
		_fail("decline should reveal Continue")
		return
	if run.gold != 5 or not run.relics.is_empty():
		_fail("decline should leave state unchanged; gold=%d relics=%d" % [run.gold, run.relics.size()])
		return

	screen._continue_btn.emit_signal("pressed")
	if not _left_seen:
		_fail("Continue after decline should emit shrine_left")
		return

	# Path B: gold above cost — Accept works.
	_left_seen = false
	run.gold = 30
	run.relics.clear()
	screen.bind_shrine(run, resin)
	if screen._accept_btn.disabled:
		_fail("Accept should be enabled at gold=30 (cost=18)")
		return

	screen._accept_btn.emit_signal("pressed")
	if run.gold != 30 - ShrineScreen.SACRIFICE_COST:
		_fail("after accept: expected gold=%d, got %d" % [30 - ShrineScreen.SACRIFICE_COST, run.gold])
		return
	if run.relics.size() != 1 or run.relics[0].id != resin.id:
		_fail("after accept: expected relics=[resin], got %s" % str(run.relics))
		return
	if not screen._outcome.visible:
		_fail("accept should reveal outcome")
		return

	screen._continue_btn.emit_signal("pressed")
	if not _left_seen:
		_fail("Continue after accept should emit shrine_left")
		return

	print("smoke_shrine: ok. accept deducts gold, decline is no-op, both paths reveal Continue.")
	quit(0)

func _on_shrine_left() -> void:
	_left_seen = true

func _fail(msg: String) -> void:
	push_error("smoke_shrine: %s" % msg)
	quit(1)
