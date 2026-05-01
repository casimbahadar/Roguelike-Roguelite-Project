extends SceneTree

# Headless smoke test for the AiAbilityPicker. The samurai class
# now carries two abilities — signature crescent_strike (+4 power,
# 2 uses) and extra iaijutsu_draw (+8 power, 1 use). The picker
# should:
#
#   * Return both abilities from CombatUnit.abilities().
#   * Pick iaijutsu_draw on its first cast (higher power).
#   * Fall back to crescent_strike once iaijutsu_draw is spent.
#   * Fall back to nothing once the kit is fully spent (the
#     aggressive AI's basic-attack path then kicks in; we only
#     test the picker here).
#
# Run: godot --headless --script res://tests/smoke_kit_picker.gd

const SAMURAI_PATH := "res://games/sengoku/data/classes/samurai.tres"
const ASHIGARU_PATH := "res://games/sengoku/data/classes/ashigaru.tres"

func _initialize() -> void:
	var samurai_class: ClassDef = load(SAMURAI_PATH)
	var ashigaru_class: ClassDef = load(ASHIGARU_PATH)
	if samurai_class == null or ashigaru_class == null:
		_fail("could not load class .tres")
		return
	if samurai_class.extra_abilities.is_empty():
		_fail("samurai.tres should now carry extra_abilities (iaijutsu_draw)")
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
	# Ashigaru has plenty of HP for several casts.
	var foe: CombatUnit = CombatUnit.new(foe_def, Vector2i(1, 0))
	# Boost the foe so it survives multiple casts.
	foe.apply_buffs(0, 0, 50)
	var tm: TurnManager = TurnManager.new(grid, [hero, foe])

	var kit: Array[AbilityDef] = hero.abilities()
	if kit.size() != 2:
		_fail("expected 2 abilities in samurai kit, got %d" % kit.size())
		return

	# First cast: picker should pick iaijutsu_draw (highest power).
	var foe_hp_before: int = foe.hp
	if not AiAbilityPicker.try_best(hero, foe, tm, 1):
		_fail("picker should fire an in-range ability on first cast")
		return
	var dmg_first: int = foe_hp_before - foe.hp
	# iaijutsu_draw: 7 + 8 - 2 (triangle) - 3 = 10.
	if dmg_first != 10:
		_fail("first cast should be iaijutsu_draw for 10 damage, got %d" % dmg_first)
		return

	# iaijutsu_draw exhausted (1 use). Next pick should be crescent_strike.
	foe_hp_before = foe.hp
	if not AiAbilityPicker.try_best(hero, foe, tm, 1):
		_fail("picker should still fire — crescent_strike has uses left")
		return
	var dmg_second: int = foe_hp_before - foe.hp
	# crescent_strike: 7 + 4 - 2 - 3 = 6.
	if dmg_second != 6:
		_fail("second cast should be crescent_strike for 6 damage, got %d" % dmg_second)
		return

	# Crescent_strike still has 1 use left.
	foe_hp_before = foe.hp
	if not AiAbilityPicker.try_best(hero, foe, tm, 1):
		_fail("picker should still fire crescent_strike's second use")
		return
	if foe_hp_before - foe.hp != 6:
		_fail("third cast should also be crescent_strike for 6 damage")
		return

	# Kit fully spent. Picker returns false; basic attack handled by
	# the AI archetype, not this test.
	if AiAbilityPicker.try_best(hero, foe, tm, 1):
		_fail("picker should return false when all kit uses are spent")
		return

	print("smoke_kit_picker: ok. picker burned iaijutsu first then crescent_strike, returned false when spent.")
	quit(0)

func _fail(msg: String) -> void:
	push_error("smoke_kit_picker: %s" % msg)
	quit(1)
