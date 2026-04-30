class_name TurnManager
extends RefCounted

# Drives the per-side turn loop. Each turn, every living unit on the
# active side takes one action: if an enemy is adjacent, attack it;
# otherwise step one tile toward the nearest enemy and, if that step
# made the unit adjacent, attack — FE-style move-then-attack.
#
# This is the smallest thing that resolves a battle. Initiative,
# weapon triangle, abilities, supports, terrain effects, and proper
# AI archetypes all layer on later.

var grid: CombatGrid
var units: Array[CombatUnit] = []
var current_side: int = 0

func _init(p_grid: CombatGrid, p_units: Array[CombatUnit]) -> void:
	grid = p_grid
	units = p_units

func living_units(side: int) -> Array[CombatUnit]:
	var out: Array[CombatUnit] = []
	for u in units:
		if u.side == side and u.is_alive():
			out.append(u)
	return out

func is_battle_over() -> bool:
	var sides_with_living: Dictionary = {}
	for u in units:
		if u.is_alive():
			sides_with_living[u.side] = true
	return sides_with_living.size() <= 1

func winning_side() -> int:
	# -1 = no winner yet, or mutual KO.
	if not is_battle_over():
		return -1
	for u in units:
		if u.is_alive():
			return u.side
	return -1

func run_turn() -> void:
	for actor in living_units(current_side):
		if not actor.is_alive():
			continue
		match actor.unit_def.ai_kind:
			"defensive":
				AiDefensive.take_turn(actor, self)
			"ranged":
				AiRanged.take_turn(actor, self)
			_:
				AiAggressive.take_turn(actor, self)
	current_side = 1 - current_side

func resolve(turn_cap: int = 100) -> int:
	# Returns the winning side, or -1 if the cap was hit without a winner.
	# Cap prevents an infinite loop if AI ever stalemates.
	var turns: int = 0
	while not is_battle_over() and turns < turn_cap:
		run_turn()
		turns += 1
	return winning_side()

func _nearest_enemy(actor: CombatUnit) -> CombatUnit:
	var best: CombatUnit = null
	var best_dist: int = 1 << 30
	for u in units:
		if u.side == actor.side or not u.is_alive():
			continue
		var d: int = grid.distance(actor.pos, u.pos)
		if d < best_dist:
			best_dist = d
			best = u
	return best

func _step_toward(actor: CombatUnit, target_pos: Vector2i) -> void:
	var occ: Dictionary = _occupied_positions()
	occ.erase(actor.pos)
	var best_pos: Vector2i = actor.pos
	var best_dist: int = grid.distance(actor.pos, target_pos)
	for n in grid.neighbors(actor.pos):
		if occ.has(n):
			continue
		var d: int = grid.distance(n, target_pos)
		if d < best_dist:
			best_dist = d
			best_pos = n
	actor.pos = best_pos

func _step_away(actor: CombatUnit, target_pos: Vector2i) -> void:
	var occ: Dictionary = _occupied_positions()
	occ.erase(actor.pos)
	var best_pos: Vector2i = actor.pos
	var best_dist: int = grid.distance(actor.pos, target_pos)
	for n in grid.neighbors(actor.pos):
		if occ.has(n):
			continue
		var d: int = grid.distance(n, target_pos)
		if d > best_dist:
			best_dist = d
			best_pos = n
	actor.pos = best_pos

func _attack(attacker: CombatUnit, defender: CombatUnit) -> void:
	var dmg: int = DamageFormula.resolve_damage(
		attacker.atk(), attacker.weapon_type(),
		defender.defense(), defender.weapon_type()
	)
	defender.take_damage(dmg)

# Casts an ability; assumes the caller already verified the
# target is in range and the attacker has remaining uses. Damage
# resolution lives in DamageFormula; HEAL / BUFF kinds are no-ops
# in the slice (their support systems aren't wired yet — they'll
# fire here once the supporting hooks land).
func _cast_ability(attacker: CombatUnit, defender: CombatUnit, ability: AbilityDef) -> void:
	if not attacker.try_consume_ability_use(ability):
		return
	if ability.kind == "PHYSICAL" or ability.kind == "MAGICAL":
		var dmg: int = DamageFormula.resolve_ability_damage(
			attacker.atk(), attacker.weapon_type(),
			defender.defense(), defender.weapon_type(),
			ability.kind, ability.power
		)
		defender.take_damage(dmg)
	# HEAL / BUFF intentionally fall through as no-ops for now.

func _occupied_positions() -> Dictionary:
	var occ: Dictionary = {}
	for u in units:
		if u.is_alive():
			occ[u.pos] = u
	return occ
