## Persistent save data — faction progression, run stats.
## Autoload singleton at path "SaveData".
class_name SaveData
extends Node

const SAVE_PATH := "user://save.cfg"

var total_runs: int = 0

var _faction_levels: Dictionary = {}  # Faction → int
var _faction_xp: Dictionary = {}      # Faction → int
var _best_waves: Dictionary = {}      # Faction → int

func _ready() -> void:
	_init_factions()
	load_data()

func _init_factions() -> void:
	for f in TowerData.Faction.values():
		if not _faction_levels.has(f):
			_faction_levels[f] = 1
		if not _faction_xp.has(f):
			_faction_xp[f] = 0
		if not _best_waves.has(f):
			_best_waves[f] = 0

func reset() -> void:
	total_runs = 0
	_faction_levels.clear()
	_faction_xp.clear()
	_best_waves.clear()
	_init_factions()

# ── Faction progression ───────────────────────────────────────────────────────

func get_faction_level(f: TowerData.Faction) -> int:
	return _faction_levels.get(f, 1)

func get_faction_xp(f: TowerData.Faction) -> int:
	return _faction_xp.get(f, 0)

func set_faction_xp(f: TowerData.Faction, new_level: int, new_xp: int) -> void:
	_faction_levels[f] = new_level
	_faction_xp[f] = new_xp

func update_best_wave(f: TowerData.Faction, wave: int) -> void:
	_best_waves[f] = max(_best_waves.get(f, 0), wave)

func get_best_wave(f: TowerData.Faction) -> int:
	return _best_waves.get(f, 0)

func increment_runs() -> void:
	total_runs += 1

# ── Persistence ───────────────────────────────────────────────────────────────

func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("stats", "total_runs", total_runs)
	for f in TowerData.Faction.values():
		var key := str(int(f))
		cfg.set_value("faction_levels", key, _faction_levels.get(f, 1))
		cfg.set_value("faction_xp", key, _faction_xp.get(f, 0))
		cfg.set_value("best_waves", key, _best_waves.get(f, 0))
	cfg.save(SAVE_PATH)

func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	total_runs = cfg.get_value("stats", "total_runs", 0)
	for f in TowerData.Faction.values():
		var key := str(int(f))
		_faction_levels[f] = cfg.get_value("faction_levels", key, 1)
		_faction_xp[f] = cfg.get_value("faction_xp", key, 0)
		_best_waves[f] = cfg.get_value("best_waves", key, 0)
