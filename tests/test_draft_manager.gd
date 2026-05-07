extends GutTest

func _make_towers(faction: TowerData.Faction, count: int) -> Array[TowerData]:
	var result: Array[TowerData] = []
	for i in count:
		var td := TowerData.new()
		td.id = StringName("tower_%d" % i)
		td.faction = faction
		result.append(td)
	return result

func test_generates_3_choices() -> void:
	var dm := DraftManager.new()
	var towers := _make_towers(TowerData.Faction.SOLARIENS, 10)
	dm.setup(TowerData.Faction.SOLARIENS, towers)
	var choices: Array[TowerData] = []
	dm.draft_ready.connect(func(c): choices = c)
	dm.generate_draft()
	assert_eq(choices.size(), 3)

func test_choices_are_from_correct_faction() -> void:
	var dm := DraftManager.new()
	var towers := _make_towers(TowerData.Faction.SOLARIENS, 10)
	towers.append_array(_make_towers(TowerData.Faction.FERREUX, 5))
	dm.setup(TowerData.Faction.SOLARIENS, towers)
	var choices: Array[TowerData] = []
	dm.draft_ready.connect(func(c): choices = c)
	dm.generate_draft()
	for c in choices:
		assert_eq(c.faction, TowerData.Faction.SOLARIENS)

func test_pick_returns_chosen_tower() -> void:
	var dm := DraftManager.new()
	var towers := _make_towers(TowerData.Faction.SOLARIENS, 5)
	dm.setup(TowerData.Faction.SOLARIENS, towers)
	dm.generate_draft()
	var picked := dm.pick(0)
	assert_not_null(picked)

func test_pick_invalid_index_returns_null() -> void:
	var dm := DraftManager.new()
	var towers := _make_towers(TowerData.Faction.SOLARIENS, 5)
	dm.setup(TowerData.Faction.SOLARIENS, towers)
	dm.generate_draft()
	assert_null(dm.pick(99))

func test_choices_are_unique() -> void:
	var dm := DraftManager.new()
	var towers := _make_towers(TowerData.Faction.SOLARIENS, 10)
	dm.setup(TowerData.Faction.SOLARIENS, towers)
	var choices: Array[TowerData] = []
	dm.draft_ready.connect(func(c): choices = c)
	dm.generate_draft()
	var ids := choices.map(func(t): return t.id)
	# No duplicate IDs
	var unique_ids := {}
	for id in ids:
		unique_ids[id] = true
	assert_eq(unique_ids.size(), choices.size())
