## Central game state for one run.
class_name RunState
extends RefCounted

signal gold_changed(amount: int)
signal lives_changed(lives: int)
signal run_won
signal run_lost

var gold: int = EconomyData.STARTING_GOLD
var lives: int
var faction: TowerData.Faction
var wave_index: int = 0
var towers_placed: Array = []   # Array[Dictionary] {tower, invested}
var passives: PassiveResolver.Resolved = null
var synergy: FactionSynergyManager = null
var highest_wave: int = 0

func setup(selected_faction: TowerData.Faction, faction_level: int = 1) -> void:
	faction = selected_faction
	passives = PassiveResolver.resolve(faction, faction_level)
	gold = EconomyData.STARTING_GOLD + passives.start_gold_bonus
	lives = RunState.max_lives() + passives.extra_lives
	towers_placed.clear()
	synergy = FactionSynergyManager.new()
	synergy.setup(faction)
	synergy.gold_earned.connect(earn_gold)

static func max_lives() -> int:
	return 20

func earn_gold(amount: int) -> void:
	var effective := int(amount * passives.gold_mult) if passives != null else amount
	gold += effective
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
	_refresh_synergy_positions()
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
	_refresh_synergy_positions()

func on_enemy_killed_by_tower(tower: Tower, enemy: Enemy) -> void:
	var all_pos := _all_tower_positions()
	synergy.on_enemy_killed(tower.global_position, all_pos)

## Returns passives-adjusted damage for a given tower shot.
func modify_damage(base: int, target: Enemy, shooter: Tower) -> int:
	var with_passives := int(base * passives.damage_mult)
	return synergy.modify_damage(with_passives, target, shooter.global_position, _all_tower_positions())

func _refresh_synergy_positions() -> void:
	synergy.refresh_alignment(_all_tower_positions())

func _all_tower_positions() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for e in towers_placed:
		if is_instance_valid(e.tower):
			result.append(e.tower.global_position)
	return result

func _find_entry(tower: Tower):
	for e in towers_placed:
		if e.tower == tower:
			return e
	return null

## XP earned at run end based on waves cleared.
func xp_earned() -> int:
	return highest_wave * 15
