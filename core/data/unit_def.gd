class_name UnitDef
extends Resource

# A specific unit: identity + class + level. Stats derive from the
# referenced ClassDef and the level. UnitDef instances are the
# "characters" — each named NPC/recruitable lives in a .tres file
# under games/<theme>/data/units/.
#
# Stats per level above 1 are simple linear-additive in this first
# pass: base + (level - 1) * growth. Growth lives on the UnitDef
# (per-character) rather than on the class because different units
# of the same class should feel different — that's an FE staple.

@export var id: StringName
@export var display_name: String
@export var portrait_path: String
@export var class_def: ClassDef
@export var level: int = 1
@export var side: int = 0  # 0 = player, 1+ = enemy factions
@export_enum("aggressive", "defensive", "ranged") var ai_kind: String = "aggressive"

# Optional secondary class (G2-flavoured "job system" hook). When
# set, the unit picks up a small passive carry-bonus at battle
# setup — the simplest expression of "this unit has trained as a
# second class on the side". Per-class passive specifics layer on
# later; the engine credits +1 atk / +1 defense today.
@export var job_class: ClassDef

# Element triangle (G3-flavoured creature collection hook). Layered
# on top of the weapon triangle in DamageFormula. NEUTRAL is the
# default and applies no bonus. Element advantage chart:
#   FIRE  beats WIND
#   WIND  beats EARTH
#   EARTH beats WATER
#   WATER beats FIRE
#   LIGHT beats NEUTRAL and DARK
#   DARK  beats NEUTRAL and LIGHT
@export_enum("NEUTRAL", "FIRE", "WATER", "WIND", "EARTH", "LIGHT", "DARK") var element: String = "NEUTRAL"

# Optional recruit-on-defeat relic (G3 capture/recruit hook). When
# the player KOs this UnitDef in battle, the engine rolls a small
# chance to add this relic to the run. Other themes leave null.
@export var recruit_on_defeat: RelicDef
@export_range(0.0, 1.0) var recruit_chance: float = 0.25

@export_group("Per-level growths (added per level past 1)")
@export var hp_growth: int = 2
@export var atk_growth: int = 1
@export var defense_growth: int = 1
@export var speed_growth: int = 1

func max_hp() -> int:
	return class_def.base_hp + (level - 1) * hp_growth

func atk() -> int:
	return class_def.base_atk + (level - 1) * atk_growth + job_atk_bonus()

func defense() -> int:
	return class_def.base_defense + (level - 1) * defense_growth + job_defense_bonus()

func speed() -> int:
	return class_def.base_speed + (level - 1) * speed_growth

# Job carry-bonuses. Single tier today (+1/+1 if any job is set);
# later iterations can derive bonuses from job_class properties
# without changing callers.
func job_atk_bonus() -> int:
	return 1 if job_class != null else 0

func job_defense_bonus() -> int:
	return 1 if job_class != null else 0
