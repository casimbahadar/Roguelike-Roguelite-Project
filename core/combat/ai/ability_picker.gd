class_name AiAbilityPicker
extends RefCounted

# Shared ability-pick helper for the AI archetypes. Scans the
# actor's full kit (signature + class extras) and casts the
# highest-power offensive ability that's in range and has
# remaining uses. Returns true if an ability was cast.
#
# Heal and buff abilities are skipped here — those target
# friendlies and don't fit "swing at the nearest enemy" AI.
# Once a real heal/support AI archetype lands, it will use a
# parallel friendly-target picker.

static func try_best(actor: CombatUnit, target: CombatUnit, tm: TurnManager, dist: int) -> bool:
	var best: AbilityDef = null
	var best_power: int = -1
	for a in actor.abilities():
		if a == null:
			continue
		if a.kind != "PHYSICAL" and a.kind != "MAGICAL":
			continue
		if dist < a.range_min or dist > a.range_max:
			continue
		if actor.ability_uses_remaining(a) <= 0:
			continue
		# Tie-break by listing order (signature first), so positive
		# strict-greater here leaves the signature ahead on ties.
		if a.power > best_power:
			best_power = a.power
			best = a
	if best == null:
		return false
	tm._cast_ability(actor, target, best)
	return true
