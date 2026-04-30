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

# Damage = max(1, attacker.atk + triangle_mod - defender.defense).
# Floor of 1 keeps battles from stalemating; FE does the same.
static func resolve_damage(
	attacker_atk: int,
	attacker_weapon: String,
	defender_defense: int,
	defender_weapon: String
) -> int:
	var modded_atk: int = attacker_atk + triangle_modifier(attacker_weapon, defender_weapon)
	return maxi(1, modded_atk - defender_defense)
