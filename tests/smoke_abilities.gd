extends SceneTree

# Headless smoke test for signature abilities. Builds a samurai
# (signature crescent_strike: PHYSICAL, 1-1 range, +4 power,
# 2 uses) vs an ashigaru, and verifies:
#
#   * Samurai starts with 2 ability uses.
#   * _cast_ability deals more damage than a basic attack.
#     Math: samurai atk 7 + ability +4 + triangle (LANCE beats
#     SWORD = -2) - ashigaru def 3 = 6 damage. Basic attack
#     would be max(1, 7 - 2 - 3) = 2.
#   * Each cast decrements the use counter.
#   * Trying to cast after exhausting uses leaves the target
#     unharmed (try_consume returns false; _cast_ability is a
#     no-op when consume fails).
#
# Run: godot --headless --script res://tests/smoke_abilities.gd

const SAMURAI_PATH := "res://games/sengoku/data/classes/samurai.tres"
const ASHIGARU_PATH := "res://games/sengoku/data/classes/ashigaru.tres"

func _initialize() -> void:
	var samurai_class: ClassDef = load(SAMURAI_PATH)
	var ashigaru_class: ClassDef = load(ASHIGARU_PATH)
	if samurai_class == null or ashigaru_class == null:
		_fail("could not load class .tres")
		return
	if samurai_class.signature_ability == null:
		_fail("samurai.tres should reference crescent_strike as signature_ability")
		return

	var hero_def: UnitDef = UnitDef.new()
	hero_def.id = &"smoke_hero"
	hero_def.display_name = "Hero"
	hero_def.class_def = samurai_class
	hero_def.level = 1
	hero_def.side = 0

	var foe_def: UnitDef = UnitDef.new()
	foe_def.id = &"smoke_foe"
	foe_def.display_name = "Bandit"
	foe_def.class_def = ashigaru_class
	foe_def.level = 1
	foe_def.side = 1

	var grid: CombatGrid = CombatGrid.new(6, 6)
	var hero: CombatUnit = CombatUnit.new(hero_def, Vector2i(0, 0))
	var foe: CombatUnit = CombatUnit.new(foe_def, Vector2i(1, 0))
	var roster: Array[CombatUnit] = [hero, foe]
	var tm: TurnManager = TurnManager.new(grid, roster)

	var ability: AbilityDef = hero.signature_ability()
	if ability == null:
		_fail("hero should have a signature ability")
		return

	# Initial use count should match the ability's uses_per_battle.
	if hero.ability_uses_remaining(ability) != ability.uses_per_battle:
		_fail("expected %d uses, got %d" % [ability.uses_per_battle, hero.ability_uses_remaining(ability)])
		return

	# Sanity: basic attack damage = 7 - 2 (triangle) - 3 = 2.
	# Ability damage = 7 + 4 - 2 - 3 = 6.
	var foe_max_hp: int = foe.max_hp()

	tm._cast_ability(hero, foe, ability)
	var dmg_first: int = foe_max_hp - foe.hp
	if dmg_first != 6:
		_fail("first ability cast: expected 6 damage, got %d" % dmg_first)
		return
	if hero.ability_uses_remaining(ability) != ability.uses_per_battle - 1:
		_fail("after one cast: expected %d uses, got %d" % [ability.uses_per_battle - 1, hero.ability_uses_remaining(ability)])
		return

	tm._cast_ability(hero, foe, ability)
	var dmg_total_after_two: int = foe_max_hp - foe.hp
	if dmg_total_after_two != 12:
		_fail("after two casts: expected 12 total damage, got %d" % dmg_total_after_two)
		return
	if hero.ability_uses_remaining(ability) != 0:
		_fail("after two casts: expected 0 uses, got %d" % hero.ability_uses_remaining(ability))
		return

	# Third cast should be a no-op (no uses left).
	tm._cast_ability(hero, foe, ability)
	var dmg_total_after_three: int = foe_max_hp - foe.hp
	if dmg_total_after_three != 12:
		_fail("third cast (no uses) should be a no-op; got %d total damage" % dmg_total_after_three)
		return

	# Direct try_consume call should also report false now.
	if hero.try_consume_ability_use(ability):
		_fail("try_consume_ability_use should return false when no uses remain")
		return

	print("smoke_abilities: ok. crescent_strike fired twice for 6 dmg each, then exhausted cleanly.")
	quit(0)

func _fail(msg: String) -> void:
	push_error("smoke_abilities: %s" % msg)
	quit(1)
