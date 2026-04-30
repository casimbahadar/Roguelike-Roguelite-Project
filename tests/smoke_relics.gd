extends SceneTree

# Headless smoke test for the relic buff hook. Builds a CombatUnit
# from a UnitDef, applies relics one by one, and verifies the
# atk / defense / max_hp accessors update accordingly.
#
# Run: godot --headless --script res://tests/smoke_relics.gd

const SAMURAI_PATH := "res://games/sengoku/data/classes/samurai.tres"
const BANNER_PATH := "res://games/sengoku/data/relics/banner_of_ash.tres"
const HAORI_PATH := "res://games/sengoku/data/relics/iron_haori.tres"
const RESIN_PATH := "res://games/sengoku/data/relics/comets_resin.tres"

func _initialize() -> void:
	var samurai_class: ClassDef = load(SAMURAI_PATH)
	var banner: RelicDef = load(BANNER_PATH)
	var haori: RelicDef = load(HAORI_PATH)
	var resin: RelicDef = load(RESIN_PATH)
	if samurai_class == null or banner == null or haori == null or resin == null:
		_fail("failed to load class or relic .tres files")
		return

	var def: UnitDef = UnitDef.new()
	def.id = &"smoke_hero"
	def.display_name = "Hero"
	def.class_def = samurai_class
	def.level = 1
	def.side = 0

	var unit: CombatUnit = CombatUnit.new(def, Vector2i(0, 0))

	var base_atk: int = unit.atk()
	var base_def: int = unit.defense()
	var base_hp: int = unit.max_hp()
	if base_atk != samurai_class.base_atk:
		_fail("base atk mismatch: %d vs %d" % [base_atk, samurai_class.base_atk])
		return

	# Apply Banner of Ash (+1 atk).
	unit.apply_buffs(banner.value, 0, 0)
	if unit.atk() != base_atk + banner.value:
		_fail("after banner: expected atk %d, got %d" % [base_atk + banner.value, unit.atk()])
		return
	if unit.defense() != base_def:
		_fail("banner shouldn't change defense: %d vs base %d" % [unit.defense(), base_def])
		return

	# Apply all three: +1 atk, +2 def, +3 max_hp.
	unit.apply_buffs(banner.value, haori.value, resin.value)
	if unit.atk() != base_atk + banner.value:
		_fail("combined atk wrong: expected %d, got %d" % [base_atk + banner.value, unit.atk()])
		return
	if unit.defense() != base_def + haori.value:
		_fail("combined defense wrong: expected %d, got %d" % [base_def + haori.value, unit.defense()])
		return
	if unit.max_hp() != base_hp + resin.value:
		_fail("combined max_hp wrong: expected %d, got %d" % [base_hp + resin.value, unit.max_hp()])
		return
	if unit.hp != unit.max_hp():
		_fail("apply_buffs should refill HP to new max: hp=%d max=%d" % [unit.hp, unit.max_hp()])
		return

	# Reset to zero buffs.
	unit.apply_buffs(0, 0, 0)
	if unit.atk() != base_atk or unit.defense() != base_def or unit.max_hp() != base_hp:
		_fail("zero buffs should restore base stats; got atk=%d def=%d hp=%d" % [unit.atk(), unit.defense(), unit.max_hp()])
		return

	print("smoke_relics: ok. base atk=%d def=%d max_hp=%d; buffs +%d/+%d/+%d apply cleanly." % [
		base_atk, base_def, base_hp, banner.value, haori.value, resin.value,
	])
	quit(0)

func _fail(msg: String) -> void:
	push_error("smoke_relics: %s" % msg)
	quit(1)
