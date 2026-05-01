extends SceneTree

# Headless smoke test for the G4 Restored-Pact vs Permabond
# toggle on RunConfig.
#
#   * RESTORED_PACT (default) grants +1 starting revive token on
#     top of revive_policy.
#   * PERMABOND grants no bonus.
#   * datapact_iron.tres is authored as PERMABOND (vessel_mortality=1).
#   * datapact_standard.tres defaults to RESTORED_PACT.
#
# Run: godot --headless --script res://tests/smoke_pact_toggle.gd

func _initialize() -> void:
	_test_restored_grants_extra_token()
	_test_permabond_keeps_policy_strict()
	_test_iron_is_permabond()
	_test_standard_is_restored()
	print("smoke_pact_toggle: ok. RESTORED gives +1 token, PERMABOND strict, iron=PERMABOND, standard=RESTORED.")
	quit(0)

func _test_restored_grants_extra_token() -> void:
	var cfg: RunConfig = RunConfig.new()
	cfg.id = &"smoke_restored"
	cfg.act_count = 1
	cfg.nodes_per_act = Vector2i(3, 3)
	cfg.revive_policy = RunConfig.RevivePolicy.NONE  # baseline 0 tokens
	cfg.vessel_mortality = RunConfig.VesselMortality.RESTORED_PACT
	var rs: RunState = RunState.new(cfg, 1, [])
	if rs.revive_tokens != 1:
		_fail("RESTORED + NONE policy should give 0+1 = 1 token, got %d" % rs.revive_tokens)
		return

	# RESTORED + ONE_PER_RUN → 1 + 1 = 2 tokens.
	cfg.revive_policy = RunConfig.RevivePolicy.ONE_PER_RUN
	var rs2: RunState = RunState.new(cfg, 1, [])
	if rs2.revive_tokens != 2:
		_fail("RESTORED + ONE_PER_RUN should give 1+1 = 2 tokens, got %d" % rs2.revive_tokens)
		return

func _test_permabond_keeps_policy_strict() -> void:
	var cfg: RunConfig = RunConfig.new()
	cfg.id = &"smoke_permabond"
	cfg.act_count = 1
	cfg.nodes_per_act = Vector2i(3, 3)
	cfg.revive_policy = RunConfig.RevivePolicy.NONE
	cfg.vessel_mortality = RunConfig.VesselMortality.PERMABOND
	var rs: RunState = RunState.new(cfg, 1, [])
	if rs.revive_tokens != 0:
		_fail("PERMABOND + NONE policy should give 0 tokens, got %d" % rs.revive_tokens)
		return

	# PERMABOND + ONE_PER_RUN keeps the policy's 1, no bonus.
	cfg.revive_policy = RunConfig.RevivePolicy.ONE_PER_RUN
	var rs2: RunState = RunState.new(cfg, 1, [])
	if rs2.revive_tokens != 1:
		_fail("PERMABOND + ONE_PER_RUN should give 1 token, got %d" % rs2.revive_tokens)
		return

func _test_iron_is_permabond() -> void:
	var cfg: RunConfig = load("res://games/datapact/data/runs/iron.tres")
	if cfg == null:
		_fail("could not load datapact iron.tres")
		return
	if cfg.vessel_mortality != RunConfig.VesselMortality.PERMABOND:
		_fail("datapact_iron should be authored as PERMABOND")
		return
	var rs: RunState = RunState.new(cfg, 1, [])
	if rs.revive_tokens != 0:
		_fail("PERMABOND iron should produce 0 starting tokens, got %d" % rs.revive_tokens)
		return

func _test_standard_is_restored() -> void:
	var cfg: RunConfig = load("res://games/datapact/data/runs/standard.tres")
	if cfg == null:
		_fail("could not load datapact standard.tres")
		return
	if cfg.vessel_mortality != RunConfig.VesselMortality.RESTORED_PACT:
		_fail("datapact_standard should default to RESTORED_PACT")
		return

func _fail(msg: String) -> void:
	push_error("smoke_pact_toggle: %s" % msg)
	quit(1)
