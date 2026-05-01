class_name EventPool
extends Resource

# Theme-pack event library. Picks an EventDef matching the
# current act, weighted by EventDef.weight. Theme packs ship
# one EventPool .tres listing every event the game supports;
# designers add events by appending .tres files to the pool
# without touching code.

@export var id: StringName
@export var events: Array[EventDef] = []

func pick(rng: RandomNumberGenerator, act: int) -> EventDef:
	if events.is_empty():
		return null
	var available: Array[EventDef] = []
	for e in events:
		if e.is_available_in_act(act):
			available.append(e)
	if available.is_empty():
		# Fall back to the full list so the run never hits a dead
		# event node. Designers should fix availability if it
		# triggers.
		available = events

	var total_weight: int = 0
	for e in available:
		total_weight += maxi(1, e.weight)

	var roll: int = rng.randi_range(1, total_weight)
	var cumulative: int = 0
	for e in available:
		cumulative += maxi(1, e.weight)
		if roll <= cumulative:
			return e
	return available[available.size() - 1]
