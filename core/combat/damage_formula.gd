class_name DamageFormula
extends RefCounted

# Pure math for combat resolution. No state, no side effects.
# Stays a static-style helper so the resolver can call it without
# instantiating anything per-attack.
#
# Triangle (FE classic): SWORD > AXE, AXE > LANCE, LANCE > SWORD.
# BOW and MAGIC sit outside the triangle for now; ranged archery
# and magical defense get their own treatment when those layer on.
# Triangle bonus: ±2 to attacker's effective atk.

const TRIANGLE_BONUS: int = 2
const ELEMENT_BONUS: int = 1  # smaller than the weapon triangle so weapons stay primary

# Returns (min, max) Manhattan attack range for a weapon.
# Melee weapons can only strike adjacent (1..1). FE archers
# attack at 2..3 — they can't shoot point-blank. Magic is 1..2.
# A NONE weapon has no offensive range; we mark that with (0, 0).
static func weapon_range(weapon: String) -> Vector2i:
	match weapon:
		"BOW":
			return Vector2i(2, 3)
		"MAGIC":
			return Vector2i(1, 2)
		"SWORD", "LANCE", "AXE":
			return Vector2i(1, 1)
		_:
			return Vector2i(0, 0)

# Returns +TRIANGLE_BONUS if attacker_weapon beats defender_weapon,
# -TRIANGLE_BONUS if it's the other way around, 0 otherwise.
static func triangle_modifier(attacker_weapon: String, defender_weapon: String) -> int:
	if _beats(attacker_weapon, defender_weapon):
		return TRIANGLE_BONUS
	if _beats(defender_weapon, attacker_weapon):
		return -TRIANGLE_BONUS
	return 0

static func _beats(a: String, b: String) -> bool:
	if a == "SWORD" and b == "AXE":
		return true
	if a == "AXE" and b == "LANCE":
		return true
	if a == "LANCE" and b == "SWORD":
		return true
	return false

# Element-triangle modifier (G3 hook). Layered on top of the
# weapon triangle. NEUTRAL on either side returns 0 unless the
# other side is LIGHT/DARK, which beat NEUTRAL.
static func element_modifier(attacker_element: String, defender_element: String) -> int:
	if _element_beats(attacker_element, defender_element):
		return ELEMENT_BONUS
	if _element_beats(defender_element, attacker_element):
		return -ELEMENT_BONUS
	return 0

static func _element_beats(a: String, b: String) -> bool:
	if a == "FIRE" and b == "WIND":
		return true
	if a == "WIND" and b == "EARTH":
		return true
	if a == "EARTH" and b == "WATER":
		return true
	if a == "WATER" and b == "FIRE":
		return true
	if a == "LIGHT" and (b == "NEUTRAL" or b == "DARK"):
		return true
	if a == "DARK" and (b == "NEUTRAL" or b == "LIGHT"):
		return true
	return false

# Damage = max(1, attacker.atk + triangle_mod + element_mod - defender.defense).
# Floor of 1 keeps battles from stalemating; FE does the same.
# Element params default to "NEUTRAL" so existing callers compile;
# G3 unit-vs-unit attacks pass real elements via TurnManager.
static func resolve_damage(
	attacker_atk: int,
	attacker_weapon: String,
	defender_defense: int,
	defender_weapon: String,
	attacker_element: String = "NEUTRAL",
	defender_element: String = "NEUTRAL"
) -> int:
	var modded_atk: int = attacker_atk
	modded_atk += triangle_modifier(attacker_weapon, defender_weapon)
	modded_atk += element_modifier(attacker_element, defender_element)
	return maxi(1, modded_atk - defender_defense)

# Ability damage. Layers ability.power on top of attacker.atk.
# PHYSICAL abilities still get the weapon-triangle modifier;
# MAGICAL abilities sit outside the triangle (matches FE: tomes
# vs swords doesn't read off the weapon triangle). Element triangle
# applies to both PHYSICAL and MAGICAL — the element of the unit
# always matters even when the weapon doesn't.
static func resolve_ability_damage(
	attacker_atk: int,
	attacker_weapon: String,
	defender_defense: int,
	defender_weapon: String,
	ability_kind: String,
	ability_power: int,
	attacker_element: String = "NEUTRAL",
	defender_element: String = "NEUTRAL"
) -> int:
	var modded_atk: int = attacker_atk + ability_power
	if ability_kind == "PHYSICAL":
		modded_atk += triangle_modifier(attacker_weapon, defender_weapon)
	modded_atk += element_modifier(attacker_element, defender_element)
	return maxi(1, modded_atk - defender_defense)
