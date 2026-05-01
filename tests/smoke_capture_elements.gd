extends SceneTree

# Headless smoke test for the G3 capture/recruit hook + element
# triangle.
#
#   * DamageFormula.element_modifier returns +1 / -1 / 0 for the
#     advantage chart described on UnitDef.element.
#   * resolve_damage applies element_modifier alongside the weapon
#     triangle.
#   * resolve_ability_damage applies element_modifier even for
#     MAGICAL abilities (which bypass the weapon triangle).
#   * The three Pocketkin enemies (wild_emberkit, wind_galefinch,
#     crag_stoneclad) carry recruit_on_defeat relics + element
#     tags, so the data side is wired.
#
# Run: godot --headless --script res://tests/smoke_capture_elements.gd

func _initialize() -> void:
	_test_element_modifier()
	_test_resolve_damage_with_element()
	_test_resolve_ability_with_element()
	_test_pocketkin_enemy_data()
	print("smoke_capture_elements: ok. element math correct, capture data wired on all 3 enemies.")
	quit(0)

func _test_element_modifier() -> void:
	# FIRE beats WIND.
	if DamageFormula.element_modifier("FIRE", "WIND") != DamageFormula.ELEMENT_BONUS:
		_fail("FIRE > WIND should be +1")
		return
	if DamageFormula.element_modifier("WIND", "FIRE") != -DamageFormula.ELEMENT_BONUS:
		_fail("WIND vs FIRE should be -1")
		return
	# WATER beats FIRE.
	if DamageFormula.element_modifier("WATER", "FIRE") != DamageFormula.ELEMENT_BONUS:
		_fail("WATER > FIRE should be +1")
		return
	# Same elements cancel.
	if DamageFormula.element_modifier("FIRE", "FIRE") != 0:
		_fail("FIRE vs FIRE should be 0")
		return
	# NEUTRAL vs NEUTRAL is 0.
	if DamageFormula.element_modifier("NEUTRAL", "NEUTRAL") != 0:
		_fail("NEUTRAL vs NEUTRAL should be 0")
		return
	# LIGHT beats NEUTRAL.
	if DamageFormula.element_modifier("LIGHT", "NEUTRAL") != DamageFormula.ELEMENT_BONUS:
		_fail("LIGHT > NEUTRAL should be +1")
		return
	# DARK beats LIGHT.
	if DamageFormula.element_modifier("DARK", "LIGHT") != DamageFormula.ELEMENT_BONUS:
		_fail("DARK > LIGHT should be +1")
		return

func _test_resolve_damage_with_element() -> void:
	# WATER FIRE: atk 5, weapons NONE/NONE, def 2.
	# weapon triangle: 0. element: +1. damage: 5 + 1 - 2 = 4.
	var dmg: int = DamageFormula.resolve_damage(5, "NONE", 2, "NONE", "WATER", "FIRE")
	if dmg != 4:
		_fail("WATER vs FIRE on bare stats should be 4, got %d" % dmg)
		return
	# Same fight without elements: atk 5, no element bonus, dmg 3.
	var dmg_neutral: int = DamageFormula.resolve_damage(5, "NONE", 2, "NONE")
	if dmg_neutral != 3:
		_fail("NEUTRAL vs NEUTRAL on same stats should be 3, got %d" % dmg_neutral)
		return

func _test_resolve_ability_with_element() -> void:
	# MAGICAL ability bypasses weapon triangle but should still
	# pick up element. atk 5 + power 4 + element +1 - def 2 = 8.
	var dmg: int = DamageFormula.resolve_ability_damage(5, "MAGIC", 2, "SWORD", "MAGICAL", 4, "FIRE", "WIND")
	if dmg != 8:
		_fail("MAGICAL FIRE > WIND should be 8, got %d" % dmg)
		return

func _test_pocketkin_enemy_data() -> void:
	var paths: Array = [
		"res://games/pocketkin/data/units/enemies/wild_emberkit.tres",
		"res://games/pocketkin/data/units/enemies/wind_galefinch.tres",
		"res://games/pocketkin/data/units/enemies/crag_stoneclad.tres",
	]
	for p in paths:
		var u: UnitDef = load(p)
		if u == null:
			_fail("could not load %s" % p)
			return
		if u.element == "NEUTRAL":
			_fail("%s should have a non-NEUTRAL element" % p)
			return
		if u.recruit_on_defeat == null:
			_fail("%s should have a recruit_on_defeat relic wired" % p)
			return

func _fail(msg: String) -> void:
	push_error("smoke_capture_elements: %s" % msg)
	quit(1)
