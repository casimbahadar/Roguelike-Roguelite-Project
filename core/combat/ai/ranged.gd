class_name AiRanged
extends RefCounted

# Tries to attack from inside the unit's weapon range band.
# AiAbilityPicker scans the full kit each turn and prefers the
# strongest in-range option with uses remaining. Kites away if
# too close, closes if too far.

static func take_turn(actor: CombatUnit, tm: TurnManager) -> void:
	var target: CombatUnit = tm._nearest_enemy(actor)
	if target == null:
		return
	var weapon_rng: Vector2i = DamageFormula.weapon_range(actor.weapon_type())
	var has_offensive_kit: bool = false
	for a in actor.abilities():
		if a != null and (a.kind == "PHYSICAL" or a.kind == "MAGICAL"):
			has_offensive_kit = true
			break
	if weapon_rng == Vector2i(0, 0) and not has_offensive_kit:
		return  # nothing to do without a weapon or offensive ability

	var d: int = tm.grid.distance(actor.pos, target.pos)

	# Prefer kit when in range with uses remaining.
	if AiAbilityPicker.try_best(actor, target, tm, d):
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
	if AiAbilityPicker.try_best(actor, target, tm, d2):
		return
	if d2 >= weapon_rng.x and d2 <= weapon_rng.y and weapon_rng != Vector2i(0, 0):
		tm._attack(actor, target)
