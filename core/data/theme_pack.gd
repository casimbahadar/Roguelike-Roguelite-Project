class_name ThemePack
extends Resource

# Bundles every per-theme content path the Main glue scene
# needs. One ThemePack .tres per game: sengoku, crystal,
# pocketkin, datapact. Main loads a ThemePack at startup (the
# title screen picks which one) and reads all its content
# pools, classes, maps, etc. through this object — no
# hardcoded "res://games/<theme>/..." paths in code.
#
# Adding a fifth game means authoring one new .tres ThemePack
# plus its content tree. The engine doesn't change.

@export var id: StringName
@export var display_name: String
@export_multiline var tagline: String  # short pitch shown on title screen

@export_group("Run formats")
@export var run_config_paths: Array[String] = []

@export_group("Content pools")
@export var encounter_pool_path: String
@export var event_pool_path: String
@export var relic_pool_path: String

@export_group("Default classes")
# The class loaded for the player when no Lord/UnitDef has been
# selected yet (Slice 1 player path). Theme packs override.
@export var player_class_path: String
@export var enemy_class_path: String  # used as fallback enemy

@export_group("Battlefields")
@export var map_paths: Array[String] = []
@export var template_paths: Array[String] = []
