class_name AiAggressive
extends RefCounted

# Closes distance to the nearest enemy and attacks if it ends
# the turn adjacent. AiAbilityPicker scans the full kit
# (signature + extras) and picks the strongest in-range option
# with remaining uses; otherwise falls back to a basic attack.

static func take_turn(actor: CombatUnit, tm: TurnManager) -> void:
	var target: CombatUnit = tm._nearest_enemy(actor)
	if target == null:
		return

	var d: int = tm.grid.distance(actor.pos, target.pos)

	# Already in striking range? Cast or swing without moving.
	if d == 1:
		if AiAbilityPicker.try_best(actor, target, tm, d):
			return
		tm._attack(actor, target)
		return

	# Maybe a kit ability has a range advantage and we can fire from here.
	if AiAbilityPicker.try_best(actor, target, tm, d):
		return

	# Otherwise close in.
	tm._step_toward(actor, target.pos)
	var d2: int = tm.grid.distance(actor.pos, target.pos)
	if AiAbilityPicker.try_best(actor, target, tm, d2):
		return
	if d2 == 1:
		tm._attack(actor, target)
