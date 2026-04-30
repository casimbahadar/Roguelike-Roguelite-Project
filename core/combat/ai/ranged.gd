class_name AiRanged
extends RefCounted

# Tries to attack from inside the unit's weapon range band. If
# adjacent or otherwise too close, kites away from the threat.
# If too far, closes one tile and shoots if the step put it in
# range. Designed for archers and casters.

static func take_turn(actor: CombatUnit, tm: TurnManager) -> void:
	var target: CombatUnit = tm._nearest_enemy(actor)
	if target == null:
		return
	var rng: Vector2i = DamageFormula.weapon_range(actor.weapon_type())
	if rng == Vector2i(0, 0):
		return  # no weapon — can't act this turn
	var d: int = tm.grid.distance(actor.pos, target.pos)
	if d >= rng.x and d <= rng.y:
		tm._attack(actor, target)
		return
	if d < rng.x:
		tm._step_away(actor, target.pos)
		var d2: int = tm.grid.distance(actor.pos, target.pos)
		if d2 >= rng.x and d2 <= rng.y:
			tm._attack(actor, target)
		return
	tm._step_toward(actor, target.pos)
	var d3: int = tm.grid.distance(actor.pos, target.pos)
	if d3 >= rng.x and d3 <= rng.y:
		tm._attack(actor, target)
