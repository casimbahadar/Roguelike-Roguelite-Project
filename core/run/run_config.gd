class_name RunConfig
extends Resource

# Parameterizes any run format. Skirmish, Standard, Long, Saga,
# Endless, Boss Rush, Daily, Iron — all built by varying these
# fields. There is one run-loop codepath; new formats are content
# additions, not engine changes. (CLAUDE.md: locked rule.)
#
# Fields beyond this MVP — narrative_track for Saga, endless_curve
# for Endless, unlock_requirement for the hub gate — layer on
# when those systems exist. Adding them here today would be the
# kind of speculative scaffolding CLAUDE.md tells us to avoid.

enum RevivePolicy {
	NONE,           # Iron Run
	ONE_PER_RUN,    # Standard / Long
	ONE_PER_ACT,    # softer mobile-friendly variant
}

enum SeedSource {
	RANDOM,    # fresh seed every run
	DAILY_UTC, # all players on the same UTC day share a seed
	FIXED,     # deterministic — used for tests and replays
}

@export var id: StringName
@export var display_name: String

@export_group("Shape")
@export var act_count: int = 3
@export var nodes_per_act: Vector2i = Vector2i(7, 8)

@export_group("Rules")
@export var revive_policy: RevivePolicy = RevivePolicy.ONE_PER_RUN
@export var seed_source: SeedSource = SeedSource.RANDOM
@export var fixed_seed: int = 0  # consulted only when seed_source == FIXED
@export var leaderboard_key: StringName  # empty = no leaderboard
