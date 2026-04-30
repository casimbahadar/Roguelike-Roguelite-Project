class_name EventScreen
extends Control

# Renders one EventDef: title, body, and a button per choice.
# After the player picks, replaces the choices with the chosen
# choice's outcome_text and a single Continue button. When
# Continue is pressed, emits event_resolved(chosen) so Main can
# apply effects and return to the map.

signal event_resolved(chosen: EventChoice)

var _event: EventDef
var _resolved_choice: EventChoice

@onready var _title: Label = $Margin/VBox/Title
@onready var _body: Label = $Margin/VBox/Body
@onready var _choices: VBoxContainer = $Margin/VBox/Choices
@onready var _outcome: Label = $Margin/VBox/Outcome
@onready var _continue_btn: Button = $Margin/VBox/ContinueBtn

func bind_event(p_event: EventDef) -> void:
	_event = p_event
	_resolved_choice = null

	_title.text = p_event.display_name
	_body.text = p_event.body
	_outcome.text = ""
	_outcome.visible = false

	_continue_btn.visible = false
	if not _continue_btn.pressed.is_connected(_on_continue_pressed):
		_continue_btn.pressed.connect(_on_continue_pressed)

	for child in _choices.get_children():
		child.queue_free()
	_choices.visible = true
	for choice in p_event.choices:
		var btn: Button = Button.new()
		btn.text = choice.label
		btn.custom_minimum_size = Vector2(0, 56)
		btn.pressed.connect(_on_choice_pressed.bind(choice))
		_choices.add_child(btn)

func _on_choice_pressed(choice: EventChoice) -> void:
	_resolved_choice = choice
	_choices.visible = false
	_outcome.text = choice.outcome_text
	_outcome.visible = true
	_continue_btn.visible = true

func _on_continue_pressed() -> void:
	if _resolved_choice == null:
		return
	event_resolved.emit(_resolved_choice)
