class_name AiDefensive
extends RefCounted

# Holds position. Only acts on enemies that walk into range. If
# the actor has a signature ability with remaining uses and an
# enemy is in ability range, prefer the ability — defensive
# units don't waste their precious limited-use moves on bad
# matchups, but a free shot still gets taken.

static func take_turn(actor: CombatUnit, tm: TurnManager) -> void:
	var target: CombatUnit = tm._nearest_enemy(actor)
	if target == null:
		return
	var d: int = tm.grid.distance(actor.pos, target.pos)
	var ability: AbilityDef = actor.signature_ability()
	if ability != null and actor.ability_uses_remaining(ability) > 0:
		if d >= ability.range_min and d <= ability.range_max:
			tm._cast_ability(actor, target, ability)
			return
	if d == 1:
		tm._attack(actor, target)
