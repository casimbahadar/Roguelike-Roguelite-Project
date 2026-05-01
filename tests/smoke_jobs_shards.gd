extends SceneTree

# Headless smoke test for the G2-flavored job system + crystal
# shard currency.
#
#   * UnitDef.job_class adds +1 atk and +1 defense (one tier today;
#     designed to be data-driven later).
#   * Without job_class, atk and defense match the class baselines.
#   * RunState.crystal_shards starts at 0; spend rejects when
#     insufficient and decrements when it succeeds.
#
# Run: godot --headless --script res://tests/smoke_jobs_shards.gd

const SAMURAI_PATH := "res://games/sengoku/data/classes/samurai.tres"
const ASHIGARU_PATH := "res://games/sengoku/data/classes/ashigaru.tres"

func _initialize() -> void:
	_test_jobs()
	_test_shards()
	print("smoke_jobs_shards: ok. job class adds +1/+1; shard spend gates correctly.")
	quit(0)

func _test_jobs() -> void:
	var samurai_class: ClassDef = load(SAMURAI_PATH)
	var ashigaru_class: ClassDef = load(ASHIGARU_PATH)
	if samurai_class == null or ashigaru_class == null:
		_fail("could not load class .tres for jobs test")
		return

	# Bare unit: stats = class baselines (level 1).
	var bare: UnitDef = UnitDef.new()
	bare.id = &"bare"
	bare.class_def = samurai_class
	bare.level = 1
	if bare.atk() != samurai_class.base_atk:
		_fail("bare atk should equal class.base_atk %d, got %d" % [samurai_class.base_atk, bare.atk()])
		return
	if bare.defense() != samurai_class.base_defense:
		_fail("bare defense should equal class.base_defense %d, got %d" % [samurai_class.base_defense, bare.defense()])
		return

	# Same unit with a job_class set: +1 atk, +1 defense.
	var jobbed: UnitDef = UnitDef.new()
	jobbed.id = &"jobbed"
	jobbed.class_def = samurai_class
	jobbed.level = 1
	jobbed.job_class = ashigaru_class
	if jobbed.atk() != samurai_class.base_atk + 1:
		_fail("jobbed atk should be base+1; got %d (base %d)" % [jobbed.atk(), samurai_class.base_atk])
		return
	if jobbed.defense() != samurai_class.base_defense + 1:
		_fail("jobbed defense should be base+1; got %d" % jobbed.defense())
		return

func _test_shards() -> void:
	var cfg: RunConfig = RunConfig.new()
	cfg.id = &"shard_smoke"
	cfg.act_count = 1
	cfg.nodes_per_act = Vector2i(3, 3)
	var seed: int = 1
	# Build a tiny runstate. We only need crystal_shards/spend.
	var rs: RunState = RunState.new(cfg, seed, [])
	if rs.crystal_shards != 0:
		_fail("fresh RunState should have 0 crystal shards")
		return
	if rs.spend_crystal_shards(1):
		_fail("spend should fail when shards == 0")
		return
	rs.crystal_shards = 3
	if not rs.spend_crystal_shards(2):
		_fail("spend(2) should succeed when shards == 3")
		return
	if rs.crystal_shards != 1:
		_fail("after spend(2), shards should be 1, got %d" % rs.crystal_shards)
		return
	if rs.spend_crystal_shards(0):
		_fail("spend(0) should be a no-op (return false)")
		return

func _fail(msg: String) -> void:
	push_error("smoke_jobs_shards: %s" % msg)
	quit(1)
