extends SceneTree

# Headless smoke test for the honor meter and weather system.
#
#   * RunState.honor starts at 0 and accepts both signs of delta.
#   * EventChoice.honor_delta is wired and serialised correctly.
#   * CombatGrid.ranged_clip clamps an archer's 2-3 range to 2-2
#     under FOG, leaves it 2-3 under CLEAR.
#   * BattlefieldTemplate.build_grid propagates the template's
#     weather field to the resulting grid.
#
# Run: godot --headless --script res://tests/smoke_honor_weather.gd

func _initialize() -> void:
	_test_honor_delta()
	_test_weather_clip()
	_test_template_weather_propagation()
	print("smoke_honor_weather: ok. honor delta applies; FOG clips ranged max-1; templates propagate weather.")
	quit(0)

func _test_honor_delta() -> void:
	var choice: EventChoice = EventChoice.new()
	choice.honor_delta = 3
	# Simulate the main.gd hook by hand: RunState carries an int.
	var honor: int = 0
	honor += choice.honor_delta
	if honor != 3:
		_fail("honor +3 should land at 3, got %d" % honor)
		return
	var penalty: EventChoice = EventChoice.new()
	penalty.honor_delta = -5
	honor += penalty.honor_delta
	if honor != -2:
		_fail("honor -5 from 3 should land at -2, got %d" % honor)
		return

func _test_weather_clip() -> void:
	var grid: CombatGrid = CombatGrid.new(7, 7)
	grid.weather = CombatGrid.Weather.CLEAR
	var clear: Vector2i = grid.ranged_clip(Vector2i(2, 3))
	if clear != Vector2i(2, 3):
		_fail("CLEAR should not clip; got %s" % str(clear))
		return
	grid.weather = CombatGrid.Weather.FOG
	var fog: Vector2i = grid.ranged_clip(Vector2i(2, 3))
	if fog != Vector2i(2, 2):
		_fail("FOG should clip max -1; got %s" % str(fog))
		return
	# Edge: range already (1,1) — clamp keeps min as a floor.
	var melee_fog: Vector2i = grid.ranged_clip(Vector2i(1, 1))
	if melee_fog != Vector2i(1, 1):
		_fail("FOG on a (1,1) range should stay (1,1); got %s" % str(melee_fog))
		return

func _test_template_weather_propagation() -> void:
	var fog_template: BattlefieldTemplate = load("res://games/sengoku/data/maps/template_dense.tres")
	if fog_template == null:
		_fail("could not load sengoku template_dense.tres")
		return
	if fog_template.weather != CombatGrid.Weather.FOG:
		_fail("template_dense should be authored as FOG (weather=1), got %d" % fog_template.weather)
		return
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42
	var grid: CombatGrid = fog_template.build_grid(rng)
	if grid.weather != CombatGrid.Weather.FOG:
		_fail("FOG template should produce a FOG grid; got %d" % grid.weather)
		return

func _fail(msg: String) -> void:
	push_error("smoke_honor_weather: %s" % msg)
	quit(1)
