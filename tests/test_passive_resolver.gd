extends GutTest

func test_level_1_solariens_has_damage_bonus() -> void:
	var r := PassiveResolver.resolve(TowerData.Faction.SOLARIENS, 1)
	assert_true(r.damage_mult > 1.0)

func test_level_1_gelides_has_damage_bonus() -> void:
	var r := PassiveResolver.resolve(TowerData.Faction.GELIDES, 1)
	assert_true(r.damage_mult > 1.0)

func test_level_1_ferreux_has_default_gold_mult() -> void:
	var r := PassiveResolver.resolve(TowerData.Faction.FERREUX, 1)
	# Level 1 Ferreux passive is GOLD_BONUS type but value=0 (handled by strategy)
	assert_true(r.gold_mult >= 1.0)

func test_higher_level_gives_more_bonuses() -> void:
	var r1 := PassiveResolver.resolve(TowerData.Faction.SOLARIENS, 1)
	var r5 := PassiveResolver.resolve(TowerData.Faction.SOLARIENS, 5)
	assert_true(r5.damage_mult >= r1.damage_mult)

func test_level_5_ferreux_start_gold_bonus() -> void:
	var r := PassiveResolver.resolve(TowerData.Faction.FERREUX, 5)
	assert_true(r.start_gold_bonus >= 50)

func test_level_12_gelides_extra_lives() -> void:
	var r := PassiveResolver.resolve(TowerData.Faction.GELIDES, 12)
	assert_true(r.extra_lives >= 3)

func test_level_16_ferreux_extra_lives() -> void:
	var r := PassiveResolver.resolve(TowerData.Faction.FERREUX, 16)
	assert_true(r.extra_lives >= 5)

func test_max_level_all_passives_unlocked() -> void:
	for f in TowerData.Faction.values():
		var r := PassiveResolver.resolve(f, FactionProgression.MAX_LEVEL)
		assert_true(r.damage_mult > 1.0, "Faction %d should have damage bonus at max level" % f)

func test_passives_count_per_faction() -> void:
	for f in TowerData.Faction.values():
		var passives := FactionPassive.all_for_faction(f)
		assert_eq(passives.size(), 7, "Each faction should have 7 passives")
