class_name AbilityDef
extends Resource

# A unit's active ability — basic attacks, ranged shots, spells,
# heals, AoE bursts, support buffs. The combat resolver consumes
# these; abilities themselves are pure data.
#
# Range is min/max in tiles (Manhattan). A melee swing is 1..1,
# a longbow shot is 2..3, a fireball might be 1..3, a heal is 1..1.

enum Kind {
	PHYSICAL,  # consumes weapon stats; subject to weapon triangle
	MAGICAL,   # ignores weapon triangle; uses magic defense (added later)
	HEAL,      # restores hp on a friendly target
	BUFF,      # applies a status to a friendly target
}

@export var id: StringName
@export var display_name: String
@export var description: String

@export_group("Targeting")
@export var range_min: int = 1
@export var range_max: int = 1
@export var aoe_radius: int = 0  # 0 = single target

@export_group("Effect")
@export_enum("PHYSICAL", "MAGICAL", "HEAL", "BUFF") var kind: String = "PHYSICAL"
@export var power: int = 0  # damage or heal amount; 0 means "use weapon/base atk"
@export var uses_per_battle: int = -1  # -1 = unlimited (basic attack); positive = limited
