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

@export_group("Base stats (level 1)")
@export var base_hp: int = 20
@export var base_atk: int = 5
@export var base_defense: int = 4
@export var base_speed: int = 5

@export_group("Promotion")
@export var promotes_to: ClassDef
