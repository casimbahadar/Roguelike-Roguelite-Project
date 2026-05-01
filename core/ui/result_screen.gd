class_name ResultScreen
extends Control

# Shown after a run ends — either by clearing the final-act boss,
# by losing a battle (no revives left), or by abandoning. Shows
# the outcome, headline numbers, and a single action button.
# The parent scene listens for continue_pressed to return to the
# Hub.

signal continue_pressed

enum Outcome { VICTORY, DEFEAT, ABANDONED }

const VICTORY_COLOR := Color(0.55, 0.90, 0.60)
const DEFEAT_COLOR := Color(0.95, 0.45, 0.45)
const ABANDONED_COLOR := Color(0.78, 0.78, 0.78)

var _outcome_label: Label
var _details_label: Label
var _continue_btn: Button

func _ready() -> void:
	_ensure_nodes()

func _ensure_nodes() -> void:
	if _outcome_label == null:
		_outcome_label = get_node_or_null("Margin/VBox/Outcome") as Label
	if _details_label == null:
		_details_label = get_node_or_null("Margin/VBox/Details") as Label
	if _continue_btn == null:
		_continue_btn = get_node_or_null("Margin/VBox/ContinueBtn") as Button

func bind_result(outcome: Outcome, run_state: RunState, newly_unlocked: Array[StringName]) -> void:
	_ensure_nodes()
	_outcome_label.text = _outcome_text(outcome)
	_outcome_label.modulate = _outcome_color(outcome)
	_details_label.text = _build_details(run_state, newly_unlocked)
	if not _continue_btn.pressed.is_connected(_on_continue_pressed):
		_continue_btn.pressed.connect(_on_continue_pressed)
	_continue_btn.text = "Return to hub"

func _outcome_text(o: Outcome) -> String:
	match o:
		Outcome.VICTORY:
			return "Victory"
		Outcome.DEFEAT:
			return "Defeat"
		Outcome.ABANDONED:
			return "Run abandoned"
		_:
			return "?"

func _outcome_color(o: Outcome) -> Color:
	match o:
		Outcome.VICTORY:
			return VICTORY_COLOR
		Outcome.DEFEAT:
			return DEFEAT_COLOR
		Outcome.ABANDONED:
			return ABANDONED_COLOR
		_:
			return Color.WHITE

func _build_details(run_state: RunState, newly_unlocked: Array[StringName]) -> String:
	var lines: Array[String] = []
	lines.append("Run: %s" % String(run_state.run_config.id))
	lines.append("Acts cleared: %d / %d" % [run_state.current_act() + 1, run_state.run_config.act_count])
	lines.append("Gold earned: %d" % run_state.gold)
	if not newly_unlocked.is_empty():
		var names: Array[String] = []
		for n in newly_unlocked:
			names.append(String(n))
		lines.append("Unlocked: %s" % ", ".join(names))
	return "\n".join(lines)

func _on_continue_pressed() -> void:
	continue_pressed.emit()
