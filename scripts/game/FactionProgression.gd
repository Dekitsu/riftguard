## Per-faction XP and level tracking. Serializable for SaveData.
class_name FactionProgression
extends RefCounted

signal leveled_up(new_level: int)
signal xp_changed(xp: int, required: int)

const MAX_LEVEL := 20

var faction: TowerData.Faction
var level: int = 1
var xp: int = 0

## Passives unlock at these levels (1-indexed).
const PASSIVE_UNLOCK_LEVELS := [1, 3, 5, 8, 12, 16, 20]

func setup(f: TowerData.Faction) -> void:
	faction = f
	level = 1
	xp = 0

## XP required to *reach* the given level (cumulative from 0).
static func xp_for_level(target_level: int) -> int:
	if target_level <= 1:
		return 0
	# Formula: 100 * level^1.5, cumulative
	var total := 0
	for l in range(2, target_level + 1):
		total += int(100 * pow(l, 1.5))
	return total

func earn_xp(amount: int) -> void:
	xp += amount
	xp_changed.emit(xp, xp_for_level(level + 1))
	_check_level_up()

func _check_level_up() -> void:
	while level < MAX_LEVEL and xp >= xp_for_level(level + 1):
		level += 1
		leveled_up.emit(level)

func is_passive_unlocked(passive_level: int) -> bool:
	return level >= passive_level

func serialize() -> Dictionary:
	return { "faction": int(faction), "level": level, "xp": xp }

func deserialize(data: Dictionary) -> void:
	faction = data.get("faction", int(faction)) as TowerData.Faction
	level = data.get("level", 1)
	xp = data.get("xp", 0)
