class_name RelicDef
extends Resource

# A run-long passive that buffs the player's party. Awarded on
# boss kills (and later on shrine picks / event payoffs). Stays
# in RunState.relics for the duration of the run; effects re-
# apply at every battle setup.
#
# Effects are intentionally narrow at first — atk / defense /
# max_hp / gold-on-victory bonuses. Custom effect kinds (per-
# class buffs, conditional triggers, weapon-triangle overrides)
# layer on as the slice matures.

enum Kind {
	ATK_BONUS,
	DEFENSE_BONUS,
	MAX_HP_BONUS,
	GOLD_PER_VICTORY,
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
}

@export var id: StringName
@export var display_name: String
@export_multiline var description: String

@export_group("Effect")
@export var kind: Kind = Kind.ATK_BONUS
@export var value: int = 1

@export_group("Availability")
@export var rarity: Rarity = Rarity.COMMON
@export var weight: int = 10  # picker weight relative to peers in the pool
