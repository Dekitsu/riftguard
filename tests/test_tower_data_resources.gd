extends GutTest

## Verifies that all .tres tower resources are valid and well-formed.

const TOWER_DIR := "res://resources/towers/"

var _towers: Array[TowerData] = []

func before_all() -> void:
	var dir := DirAccess.open(TOWER_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var td: TowerData = load(TOWER_DIR + file)
			if td != null:
				_towers.append(td)
		file = dir.get_next()

func test_at_least_6_towers_defined() -> void:
	assert_true(_towers.size() >= 6, "Expected at least 6 towers, got %d" % _towers.size())

func test_all_towers_have_id() -> void:
	for td in _towers:
		assert_true(td.id != &"", "Tower missing id: %s" % td.display_name)

func test_all_towers_have_display_name() -> void:
	for td in _towers:
		assert_true(td.display_name != "", "Tower missing display_name: %s" % str(td.id))

func test_all_towers_have_positive_damage() -> void:
	for td in _towers:
		assert_true(td.damage > 0, "Tower %s has 0 damage" % td.display_name)

func test_all_towers_have_positive_cost() -> void:
	for td in _towers:
		assert_true(td.cost > 0, "Tower %s has 0 cost" % td.display_name)

func test_all_factions_represented() -> void:
	var factions := {}
	for td in _towers:
		factions[td.faction] = true
	assert_true(factions.has(TowerData.Faction.SOLARIENS), "No SOLARIENS tower")
	assert_true(factions.has(TowerData.Faction.GELIDES), "No GELIDES tower")
	assert_true(factions.has(TowerData.Faction.FERREUX), "No FERREUX tower")

func test_stats_at_level5_greater_than_level1() -> void:
	for td in _towers:
		var s1 := td.stats_at_level(1)
		var s5 := td.stats_at_level(5)
		assert_true(s5.damage >= s1.damage,
			"Tower %s: level 5 damage not >= level 1" % td.display_name)

func test_no_duplicate_ids() -> void:
	var seen := {}
	for td in _towers:
		assert_false(seen.has(td.id), "Duplicate tower id: %s" % td.id)
		seen[td.id] = true
