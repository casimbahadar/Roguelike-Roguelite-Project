class_name AiDefensive
extends RefCounted

# Holds position. Only acts on enemies that walk into range. If
# any kit ability is in range with remaining uses, AiAbilityPicker
# fires the strongest one — defensive units happily take a free
# shot. Otherwise melees an adjacent target.

static func take_turn(actor: CombatUnit, tm: TurnManager) -> void:
	var target: CombatUnit = tm._nearest_enemy(actor)
	if target == null:
		return
	var d: int = tm.grid.distance(actor.pos, target.pos)
	if AiAbilityPicker.try_best(actor, target, tm, d):
		return
	if d == 1:
		tm._attack(actor, target)
