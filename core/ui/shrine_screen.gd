class_name ShrineScreen
extends Control

# Shrine node: a hard choice. The shrine offers one rare-tier
# relic in exchange for a steep gold sacrifice. Compared to the
# shop's three-options-by-budget model, the shrine is binary —
# accept, or walk away. Designers should weight shrine nodes
# rare in the encounter pool; they're meant to feel like a
# pivotal moment.
#
# Sacrifice cost: a flat 18 gold for the slice. Future shrines
# can take HP, accept multi-cost trades, or condition on honor
# meter etc.

signal shrine_left

const SACRIFICE_COST: int = 18

var _run_state: RunState
var _offered: RelicDef
var _resolved: bool = false

@onready var _gold_label: Label = $Margin/VBox/Gold
@onready var _offer_label: Label = $Margin/VBox/Offer
@onready var _accept_btn: Button = $Margin/VBox/AcceptBtn
@onready var _decline_btn: Button = $Margin/VBox/DeclineBtn
@onready var _outcome: Label = $Margin/VBox/Outcome
@onready var _continue_btn: Button = $Margin/VBox/ContinueBtn

func bind_shrine(p_run: RunState, p_offered: RelicDef) -> void:
	_run_state = p_run
	_offered = p_offered
	_resolved = false
	_outcome.text = ""
	_outcome.visible = false
	_continue_btn.visible = false

	if not _accept_btn.pressed.is_connected(_on_accept_pressed):
		_accept_btn.pressed.connect(_on_accept_pressed)
	if not _decline_btn.pressed.is_connected(_on_decline_pressed):
		_decline_btn.pressed.connect(_on_decline_pressed)
	if not _continue_btn.pressed.is_connected(_on_continue_pressed):
		_continue_btn.pressed.connect(_on_continue_pressed)

	_offer_label.text = "%s\n\n%s" % [_offered.display_name, _offered.description]
	_accept_btn.text = "Sacrifice %d gold" % SACRIFICE_COST
	_accept_btn.disabled = _run_state.gold < SACRIFICE_COST
	_decline_btn.disabled = false
	_decline_btn.text = "Walk away"
	_refresh_gold()

func _refresh_gold() -> void:
	_gold_label.text = "Gold: %d" % _run_state.gold

func _on_accept_pressed() -> void:
	if _resolved or _run_state.gold < SACRIFICE_COST:
		return
	_resolved = true
	_run_state.gold -= SACRIFICE_COST
	_run_state.relics.append(_offered)
	_show_outcome("The shrine accepts the offering. The relic is yours.")

func _on_decline_pressed() -> void:
	if _resolved:
		return
	_resolved = true
	_show_outcome("You step back from the shrine. The wind stays cold a moment longer than it should.")

func _on_continue_pressed() -> void:
	shrine_left.emit()

func _show_outcome(text: String) -> void:
	_outcome.text = text
	_outcome.visible = true
	_accept_btn.disabled = true
	_decline_btn.disabled = true
	_continue_btn.visible = true
	_refresh_gold()
