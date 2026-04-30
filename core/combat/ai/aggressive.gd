class_name AiAggressive
extends RefCounted

# Closes distance to the nearest enemy and attacks if it ends the
# turn adjacent. This was the inline logic in TurnManager.run_turn
# and remains the default for every class in the slice — the
# straightforward FE behavior most opening units exhibit.

static func take_turn(actor: CombatUnit, tm: TurnManager) -> void:
	var target: CombatUnit = tm._nearest_enemy(actor)
	if target == null:
		return
	if tm.grid.distance(actor.pos, target.pos) == 1:
		tm._attack(actor, target)
		return
	tm._step_toward(actor, target.pos)
	if tm.grid.distance(actor.pos, target.pos) == 1:
		tm._attack(actor, target)
