class_name CampScreen
extends Control

# Camp node: a quiet rest beat between battles. The full
# implementation (party HP restore, support-rank ticks, optional
# upgrade choices) lands when HP-persistence and the support
# system are wired. For the slice this is a placeholder offering
# a flat +3 gold to mark progress through the node, plus a
# Continue button.
#
# Camp is intentionally low-mechanical-impact in the slice — its
# weight in the encounter map is small (~10%), so making it a
# narrative breather rather than a power node fits the pacing.

signal camp_left

const REST_GOLD_BONUS: int = 3

var _run_state: RunState
var _used: bool = false

var _gold_label: Label
var _rest_btn: Button
var _outcome: Label
var _continue_btn: Button

func _ready() -> void:
	_ensure_nodes()

func _ensure_nodes() -> void:
	if _gold_label == null:
		_gold_label = get_node_or_null("Margin/VBox/Gold") as Label
	if _rest_btn == null:
		_rest_btn = get_node_or_null("Margin/VBox/RestBtn") as Button
	if _outcome == null:
		_outcome = get_node_or_null("Margin/VBox/Outcome") as Label
	if _continue_btn == null:
		_continue_btn = get_node_or_null("Margin/VBox/ContinueBtn") as Button

func bind_camp(p_run: RunState) -> void:
	_ensure_nodes()
	_run_state = p_run
	_used = false
	_outcome.text = ""
	_outcome.visible = false
	_rest_btn.disabled = false
	_rest_btn.text = "Rest by the fire (+%d gold from foragers)" % REST_GOLD_BONUS
	_continue_btn.disabled = false
	if not _rest_btn.pressed.is_connected(_on_rest_pressed):
		_rest_btn.pressed.connect(_on_rest_pressed)
	if not _continue_btn.pressed.is_connected(_on_continue_pressed):
		_continue_btn.pressed.connect(_on_continue_pressed)
	_refresh()

func _refresh() -> void:
	_gold_label.text = "Gold: %d" % _run_state.gold

func _on_rest_pressed() -> void:
	if _used:
		return
	_used = true
	_run_state.gold += REST_GOLD_BONUS
	_outcome.text = "Your foragers return with three coppers and a heel of dried fish. The men sleep an hour."
	_outcome.visible = true
	_rest_btn.disabled = true
	_refresh()

func _on_continue_pressed() -> void:
	camp_left.emit()
