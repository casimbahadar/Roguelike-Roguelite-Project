class_name AiDefensive
extends RefCounted

# Holds position. Only swings at enemies who walk into melee
# range. Suits sentries, garrison troops, and bosses pinned to a
# throne or relic — the kind of unit that reacts rather than
# pursues.

static func take_turn(actor: CombatUnit, tm: TurnManager) -> void:
	var target: CombatUnit = tm._nearest_enemy(actor)
	if target == null:
		return
	if tm.grid.distance(actor.pos, target.pos) == 1:
		tm._attack(actor, target)
