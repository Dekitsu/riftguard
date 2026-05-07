extends GutTest

func _make_tower_data(
	target: TowerData.TargetMode = TowerData.TargetMode.FIRST,
	special: TowerData.TowerSpecial = TowerData.TowerSpecial.NONE
) -> TowerData:
	var td := TowerData.new()
	td.damage = 10
	td.range = 1000.0
	td.fire_rate = 1.0
	td.upgrade_cost_base = 40
	td.upgrade_cost_per_level = 0.5
	td.damage_per_level = 0.3
	td.range_per_level = 0.1
	td.fire_rate_per_level = 0.15
	td.max_level = 5
	td.target_mode = target
	td.special = special
	td.slow_factor = 0.5
	td.slow_duration = 2.0
	td.chain_count = 2
	td.aoe_radius = 200.0
	td.dot_duration = 3.0
	td.dot_ticks = 3
	return td

func _make_enemy_in_range(tower: Tower, hp: int = 100, progress: float = 0.0, speed: float = 80.0) -> Enemy:
	var e := Enemy.new()
	var d := EnemyData.new()
	d.max_hp = hp
	d.speed = speed
	d.armor = 0.0
	d.gold_reward = 5
	d.resistance_types = []
	var waypoints: Array[Vector2] = [Vector2(0, 0), Vector2(1000, 0)]
	e.setup(d, waypoints, 1)
	e.current_hp = hp
	# Simulate path progress by setting waypoint index
	e._waypoint_index = int(progress * (waypoints.size() - 1))
	add_child_autofree(e)
	tower._enemies_in_range.append(e)
	return e

func test_upgrade_increments_level() -> void:
	var t := Tower.new()
	t.setup(_make_tower_data())
	add_child_autofree(t)
	var ok := t.upgrade()
	assert_true(ok)
	assert_eq(t.level, 2)

func test_upgrade_blocked_at_max_level() -> void:
	var t := Tower.new()
	var td := _make_tower_data()
	td.max_level = 1
	t.setup(td)
	add_child_autofree(t)
	var ok := t.upgrade()
	assert_false(ok)
	assert_eq(t.level, 1)

func test_sell_value_is_partial_refund() -> void:
	var t := Tower.new()
	t.setup(_make_tower_data())
	add_child_autofree(t)
	var sell := t.sell_value(100)
	assert_eq(sell, 70)  # 70% refund

func test_targeting_first_picks_most_advanced() -> void:
	var t := Tower.new()
	t.setup(_make_tower_data(TowerData.TargetMode.FIRST))
	add_child_autofree(t)
	var e1 := _make_enemy_in_range(t, 100)
	var e2 := _make_enemy_in_range(t, 100)
	e1._waypoint_index = 0
	e2._waypoint_index = 1
	var picked := t._pick_target()
	assert_eq(picked, e2)

func test_targeting_lowest_hp_picks_weakest() -> void:
	var t := Tower.new()
	t.setup(_make_tower_data(TowerData.TargetMode.LOWEST_HP))
	add_child_autofree(t)
	var e1 := _make_enemy_in_range(t, 100)
	var e2 := _make_enemy_in_range(t, 30)
	var picked := t._pick_target()
	assert_eq(picked, e2)

func test_targeting_highest_hp_picks_toughest() -> void:
	var t := Tower.new()
	t.setup(_make_tower_data(TowerData.TargetMode.HIGHEST_HP))
	add_child_autofree(t)
	var e1 := _make_enemy_in_range(t, 100)
	var e2 := _make_enemy_in_range(t, 30)
	var picked := t._pick_target()
	assert_eq(picked, e1)

func test_targeting_fastest_picks_highest_speed() -> void:
	var t := Tower.new()
	t.setup(_make_tower_data(TowerData.TargetMode.FASTEST))
	add_child_autofree(t)
	var e1 := _make_enemy_in_range(t, 100, 0.0, 80.0)
	var e2 := _make_enemy_in_range(t, 100, 0.0, 160.0)
	var picked := t._pick_target()
	assert_eq(picked, e2)

func test_targeting_flying_first_prefers_flying() -> void:
	var t := Tower.new()
	t.setup(_make_tower_data(TowerData.TargetMode.FLYING_FIRST))
	add_child_autofree(t)
	# ground enemy
	var e1 := _make_enemy_in_range(t, 100)
	e1.data.is_flying = false
	# flying enemy
	var e2 := _make_enemy_in_range(t, 100)
	e2.data.is_flying = true
	var picked := t._pick_target()
	assert_eq(picked, e2)

func test_slow_special_applies_slow_on_hit() -> void:
	var t := Tower.new()
	var td := _make_tower_data(TowerData.TargetMode.FIRST, TowerData.TowerSpecial.SLOW)
	t.setup(td)
	add_child_autofree(t)
	var e := _make_enemy_in_range(t)
	var stats := td.stats_at_level(1)
	t._shoot(e, stats)
	assert_eq(e._slow_factor, 0.5)

func test_no_target_when_range_empty() -> void:
	var t := Tower.new()
	t.setup(_make_tower_data())
	add_child_autofree(t)
	var picked := t._pick_target()
	assert_null(picked)
