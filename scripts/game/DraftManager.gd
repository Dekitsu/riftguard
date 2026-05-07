## Presents 3 tower choices after each wave clear. Player picks one to place.
class_name DraftManager
extends RefCounted

signal draft_ready(choices: Array[TowerData])
signal draft_resolved(chosen: TowerData)

const CHOICES := EconomyData.DRAFT_CHOICES

var _faction: TowerData.Faction
var _all_towers: Array[TowerData] = []
var _current_choices: Array[TowerData] = []

func setup(faction: TowerData.Faction, all_towers: Array[TowerData]) -> void:
	_faction = faction
	_all_towers.clear()
	for t in all_towers:
		if t.faction == faction:
			_all_towers.append(t)

func generate_draft() -> void:
	var pool := _all_towers.duplicate()
	pool.shuffle()
	_current_choices.clear()
	for i in min(CHOICES, pool.size()):
		_current_choices.append(pool[i])
	draft_ready.emit(_current_choices.duplicate())

func pick(index: int) -> TowerData:
	if index < 0 or index >= _current_choices.size():
		return null
	var chosen := _current_choices[index]
	draft_resolved.emit(chosen)
	return chosen
