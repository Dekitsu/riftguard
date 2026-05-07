extends GutTest

func _make_tower_data() -> TowerData:
	var td := TowerData.new()
	td.damage = 10
	td.range = 200.0
	td.fire_rate = 1.0
	td.upgrade_cost_base = 40
	td.upgrade_cost_per_level = 0.5
	td.damage_per_level = 0.3
	td.range_per_level = 0.1
	td.fire_rate_per_level = 0.15
	td.max_level = 5
	return td

func test_stats_at_level_1_match_base() -> void:
	var td := _make_tower_data()
	var s := td.stats_at_level(1)
	assert_eq(s.damage, 10)
	assert_eq(s.range, 200.0)
	assert_eq(s.fire_rate, 1.0)

func test_stats_at_level_2_scale_up() -> void:
	var td := _make_tower_data()
	var s := td.stats_at_level(2)
	assert_true(s.damage > 10)
	assert_true(s.range > 200.0)
	assert_true(s.fire_rate > 1.0)

func test_stats_at_level_5_higher_than_2() -> void:
	var td := _make_tower_data()
	assert_true(td.stats_at_level(5).damage > td.stats_at_level(2).damage)

func test_stats_clamp_at_max_level() -> void:
	var td := _make_tower_data()
	var at_max := td.stats_at_level(td.max_level)
	var over_max := td.stats_at_level(td.max_level + 10)
	assert_eq(at_max.damage, over_max.damage)

func test_upgrade_cost_increases_per_level() -> void:
	var td := _make_tower_data()
	assert_true(td.stats_at_level(2).upgrade_cost < td.stats_at_level(3).upgrade_cost)
