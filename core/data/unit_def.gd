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

@export_group("Per-level growths (added per level past 1)")
@export var hp_growth: int = 2
@export var atk_growth: int = 1
@export var defense_growth: int = 1
@export var speed_growth: int = 1

func max_hp() -> int:
	return class_def.base_hp + (level - 1) * hp_growth

func atk() -> int:
	return class_def.base_atk + (level - 1) * atk_growth

func defense() -> int:
	return class_def.base_defense + (level - 1) * defense_growth

func speed() -> int:
	return class_def.base_speed + (level - 1) * speed_growth
