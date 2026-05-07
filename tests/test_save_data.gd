extends GutTest

func test_save_and_load_faction_progression() -> void:
	SaveData.reset()
	SaveData.set_faction_xp(TowerData.Faction.SOLARIENS, 3, 150)
	SaveData.save()
	SaveData.load_data()
	var lvl := SaveData.get_faction_level(TowerData.Faction.SOLARIENS)
	var xp  := SaveData.get_faction_xp(TowerData.Faction.SOLARIENS)
	assert_eq(lvl, 3)
	assert_eq(xp, 150)

func test_default_faction_level_is_1() -> void:
	SaveData.reset()
	assert_eq(SaveData.get_faction_level(TowerData.Faction.FERREUX), 1)

func test_default_faction_xp_is_0() -> void:
	SaveData.reset()
	assert_eq(SaveData.get_faction_xp(TowerData.Faction.GELIDES), 0)

func test_all_factions_independently_stored() -> void:
	SaveData.reset()
	SaveData.set_faction_xp(TowerData.Faction.SOLARIENS, 5, 0)
	SaveData.set_faction_xp(TowerData.Faction.GELIDES, 2, 80)
	assert_eq(SaveData.get_faction_level(TowerData.Faction.SOLARIENS), 5)
	assert_eq(SaveData.get_faction_level(TowerData.Faction.GELIDES), 2)
	assert_eq(SaveData.get_faction_level(TowerData.Faction.FERREUX), 1)

func test_total_runs_increments() -> void:
	SaveData.reset()
	SaveData.increment_runs()
	SaveData.increment_runs()
	assert_eq(SaveData.total_runs, 2)

func test_best_wave_updates() -> void:
	SaveData.reset()
	SaveData.update_best_wave(TowerData.Faction.SOLARIENS, 8)
	assert_eq(SaveData.get_best_wave(TowerData.Faction.SOLARIENS), 8)

func test_best_wave_does_not_regress() -> void:
	SaveData.reset()
	SaveData.update_best_wave(TowerData.Faction.SOLARIENS, 8)
	SaveData.update_best_wave(TowerData.Faction.SOLARIENS, 5)
	assert_eq(SaveData.get_best_wave(TowerData.Faction.SOLARIENS), 8)
