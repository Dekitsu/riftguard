## Central game state for one run.
class_name RunState
extends RefCounted

signal gold_changed(amount: int)
signal lives_changed(lives: int)
signal run_won
signal run_lost

const MAX_LIVES := 20

var gold: int = EconomyData.STARTING_GOLD
var lives: int = MAX_LIVES
var faction: TowerData.Faction
var wave_index: int = 0         # current wave (1-based when active)
var towers_placed: Array = []   # Array[Dictionary] {tower, total_invested}

func setup(selected_faction: TowerData.Faction) -> void:
	faction = selected_faction
	gold = EconomyData.STARTING_GOLD
	lives = MAX_LIVES
	towers_placed.clear()

func earn_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true

func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		run_lost.emit()

func place_tower(tower: Tower, cost: int) -> bool:
	if not spend_gold(cost):
		return false
	towers_placed.append({ "tower": tower, "invested": cost })
	return true

func upgrade_tower(tower: Tower) -> bool:
	var entry := _find_entry(tower)
	if entry == null:
		return false
	var cost := tower.upgrade_cost()
	if not spend_gold(cost):
		return false
	entry.invested += cost
	return tower.upgrade()

func sell_tower(tower: Tower) -> void:
	var entry := _find_entry(tower)
	if entry == null:
		return
	var refund := tower.sell_value(entry.invested)
	towers_placed.erase(entry)
	earn_gold(refund)
	tower.queue_free()

func _find_entry(tower: Tower):
	for e in towers_placed:
		if e.tower == tower:
			return e
	return null
