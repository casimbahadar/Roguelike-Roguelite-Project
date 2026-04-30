class_name ResultScreen
extends Control

# Shown after a run ends — either by clearing the final-act boss,
# by losing a battle (no revives left), or by abandoning. Shows
# the outcome, headline numbers, and a single action button.
# The parent scene listens for continue_pressed to return to the
# Hub.

signal continue_pressed

enum Outcome { VICTORY, DEFEAT, ABANDONED }

@onready var _outcome_label: Label = $Margin/VBox/Outcome
@onready var _details_label: Label = $Margin/VBox/Details
@onready var _continue_btn: Button = $Margin/VBox/ContinueBtn

func bind_result(outcome: Outcome, run_state: RunState, newly_unlocked: Array[StringName]) -> void:
	_outcome_label.text = _outcome_text(outcome)
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
