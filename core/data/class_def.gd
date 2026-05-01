class_name ClassDef
extends Resource

# Stat baseline for a unit class. Concrete classes live as .tres
# Resources under games/<theme>/data/classes/. Code reads numbers
# from these — never bakes them. (CLAUDE.md: data over code.)

@export var id: StringName
@export var display_name: String
@export var theme: StringName  # "sengoku" / "crystal" / "shared"

@export_group("Movement")
@export_enum("foot", "mounted", "flying", "transforming") var movement_type: String = "foot"
@export var move_range: int = 5

@export_group("Combat")
@export_enum("NONE", "SWORD", "LANCE", "AXE", "BOW", "MAGIC") var weapon_type: String = "NONE"

@export_group("Base stats (level 1)")
@export var base_hp: int = 20
@export var base_atk: int = 5
@export var base_defense: int = 4
@export var base_speed: int = 5

@export_group("Promotion")
@export var promotes_to: ClassDef

@export_group("Signature ability")
# The class's defining active. Optional — many starter classes
# will have null and just use basic attacks. Slice goal is one
# signature per class; full launch will add personal abilities
# on top.
@export var signature_ability: AbilityDef

@export_group("Extra abilities")
# Class-level secondary kit. Loaded at battle setup alongside the
# signature; AI picks the best in-range option with remaining uses
# each turn. Authoring convention: signature is the headline kit
# entry, extras are flavour and breadth.
@export var extra_abilities: Array[AbilityDef] = []
