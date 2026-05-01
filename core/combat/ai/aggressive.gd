class_name AiAggressive
extends RefCounted

# Closes distance to the nearest enemy and attacks if it ends
# the turn adjacent. Now considers a class signature ability:
# if the actor has uses remaining and the target is in ability
# range, fire the ability instead of (or alongside) the basic
# attack. Ability use is preferred since it's strictly better
# damage when available.

static func take_turn(actor: CombatUnit, tm: TurnManager) -> void:
	var target: CombatUnit = tm._nearest_enemy(actor)
	if target == null:
		return

	var ability: AbilityDef = actor.signature_ability()
	var d: int = tm.grid.distance(actor.pos, target.pos)

	# Already in striking range? Cast or swing without moving.
	if d == 1:
		if _try_cast(actor, target, tm, ability, d):
			return
		tm._attack(actor, target)
		return

	# Maybe the ability has a range advantage and we can fire from here.
	if _try_cast(actor, target, tm, ability, d):
		return

	# Otherwise close in.
	tm._step_toward(actor, target.pos)
	var d2: int = tm.grid.distance(actor.pos, target.pos)
	if _try_cast(actor, target, tm, ability, d2):
		return
	if d2 == 1:
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
