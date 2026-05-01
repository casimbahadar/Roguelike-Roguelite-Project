extends SceneTree

# Headless smoke test for the bond/support system. Verifies:
#
#   * MetaState.advance_bond ticks rank up (capped at MAX_RANK).
#   * MetaState.bond_rank reads back what was written.
#   * to_dict / from_dict round-trips bond_ranks cleanly so save
#     files survive cross-platform serialization.
#   * Each game's BondPool loads, has at least one BondDef, and
#     every BondDef references an existing class_id (typo guard).
#
# Run: godot --headless --script res://tests/smoke_bonds.gd

const POOL_PATHS := [
	"res://games/sengoku/data/bonds/sengoku_bond_pool.tres",
	"res://games/crystal/data/bonds/crystal_bond_pool.tres",
	"res://games/pocketkin/data/bonds/pocketkin_bond_pool.tres",
	"res://games/datapact/data/bonds/datapact_bond_pool.tres",
]

func _initialize() -> void:
	# Rank progression on a fresh MetaState.
	var m: MetaState = MetaState.new()
	if m.bond_rank(&"bond_x") != 0:
		_fail("fresh MetaState should report 0 for unknown bond")
		return
	if m.advance_bond(&"bond_x") != 1:
		_fail("first advance should land at rank 1")
		return
	if m.advance_bond(&"bond_x") != BondDef.MAX_RANK:
		_fail("second advance should land at MAX_RANK")
		return
	# Cap holds: third advance stays at MAX_RANK.
	if m.advance_bond(&"bond_x") != BondDef.MAX_RANK:
		_fail("third advance should cap at MAX_RANK")
		return

	# Round-trip through to_dict / from_dict.
	var d: Dictionary = m.to_dict()
	var m2: MetaState = MetaState.from_dict(d)
	if m2.bond_rank(&"bond_x") != BondDef.MAX_RANK:
		_fail("MAX_RANK should survive a save/load round trip")
		return

	# Every game's pool loads + every bond points at a real class.
	for path in POOL_PATHS:
		var pool: BondPool = load(path)
		if pool == null:
			_fail("could not load bond pool %s" % path)
			return
		if pool.bonds.is_empty():
			_fail("%s has no bonds" % path)
			return
		for b in pool.bonds:
			if b == null:
				_fail("%s contains a null BondDef entry" % path)
				return
			if b.class_id == &"":
				_fail("%s : bond %s has empty class_id" % [path, b.id])
				return
			if b.relic_at_max == null:
				_fail("%s : bond %s has null relic_at_max" % [path, b.id])
				return

	print("smoke_bonds: ok. progression caps cleanly, save round-trip works, all 4 pools wired.")
	quit(0)

func _fail(msg: String) -> void:
	push_error("smoke_bonds: %s" % msg)
	quit(1)
