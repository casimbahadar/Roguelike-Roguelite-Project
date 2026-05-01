class_name AiRanged
extends RefCounted

# Tries to attack from inside the unit's weapon range band, with
# a signature ability taking priority when in ability range and
# uses remain. Kites away if too close, closes if too far.

static func take_turn(actor: CombatUnit, tm: TurnManager) -> void:
	var target: CombatUnit = tm._nearest_enemy(actor)
	if target == null:
		return
	var ability: AbilityDef = actor.signature_ability()
	var weapon_rng: Vector2i = DamageFormula.weapon_range(actor.weapon_type())
	if weapon_rng == Vector2i(0, 0) and ability == null:
		return  # nothing to do without a weapon or ability

	var d: int = tm.grid.distance(actor.pos, target.pos)

	# Prefer ability when in ability range with uses remaining.
	if _try_cast(actor, target, tm, ability, d):
		return

	# Weapon-range basic attack.
	if d >= weapon_rng.x and d <= weapon_rng.y and weapon_rng != Vector2i(0, 0):
		tm._attack(actor, target)
		return

	# Move to fix range. Too close → kite away. Too far → close.
	if d < weapon_rng.x:
		tm._step_away(actor, target.pos)
	else:
		tm._step_toward(actor, target.pos)

	var d2: int = tm.grid.distance(actor.pos, target.pos)
	if _try_cast(actor, target, tm, ability, d2):
		return
	if d2 >= weapon_rng.x and d2 <= weapon_rng.y and weapon_rng != Vector2i(0, 0):
		tm._attack(actor, target)

static func _try_cast(actor: CombatUnit, target: CombatUnit, tm: TurnManager, ability: AbilityDef, dist: int) -> bool:
	if ability == null:
		return false
	if actor.ability_uses_remaining(ability) <= 0:
		return false
	if dist < ability.range_min or dist > ability.range_max:
		return false
	tm._cast_ability(actor, target, ability)
	return true
