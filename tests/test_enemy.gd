extends GutTest

func _make_enemy(hp: int = 100, speed: float = 80.0) -> Enemy:
	var e := Enemy.new()
	var d := EnemyData.new()
	d.max_hp = hp
	d.speed = speed
	d.armor = 0.0
	d.gold_reward = 5
	d.is_flying = false
	d.resistance_types = []
	var waypoints: Array[Vector2] = [Vector2(0, 0), Vector2(500, 0)]
	e.setup(d, waypoints, 1)
	add_child_autofree(e)
	return e

func test_setup_sets_hp() -> void:
	var e := _make_enemy(100)
	assert_eq(e.current_hp, 100)

func test_setup_applies_wave_hp_scale() -> void:
	var e := Enemy.new()
	var d := EnemyData.new()
	d.max_hp = 100
	d.speed = 80.0
	d.armor = 0.0
	d.gold_reward = 5
	d.resistance_types = []
	var waypoints: Array[Vector2] = [Vector2(0, 0), Vector2(500, 0)]
	e.setup(d, waypoints, 6)
	add_child_autofree(e)
	assert_true(e.current_hp > 100)

func test_take_damage_reduces_hp() -> void:
	var e := _make_enemy(100)
	e.take_damage(30)
	assert_eq(e.current_hp, 70)

func test_take_damage_emits_died_at_zero() -> void:
	var e := _make_enemy(100)
	watch_signals(e)
	e.take_damage(100)
	assert_signal_emitted(e, "died")

func test_take_damage_gold_reward_correct() -> void:
	var e := _make_enemy(100)
	var received_gold := -1
	e.died.connect(func(g): received_gold = g)
	e.take_damage(100)
	assert_eq(received_gold, 5)

func test_armor_reduces_damage() -> void:
	var e := Enemy.new()
	var d := EnemyData.new()
	d.max_hp = 100
	d.speed = 80.0
	d.armor = 5.0
	d.gold_reward = 5
	d.resistance_types = []
	var waypoints: Array[Vector2] = [Vector2(0, 0), Vector2(500, 0)]
	e.setup(d, waypoints, 1)
	add_child_autofree(e)
	e.take_damage(10)
	assert_eq(e.current_hp, 95)  # 10 - 5 armor = 5 damage

func test_slow_reduces_speed_factor() -> void:
	var e := _make_enemy()
	e.apply_slow(0.5, 2.0)
	assert_eq(e._slow_factor, 0.5)

func test_slow_ignored_if_resistant() -> void:
	var e := Enemy.new()
	var d := EnemyData.new()
	d.max_hp = 100
	d.speed = 80.0
	d.armor = 0.0
	d.gold_reward = 5
	d.resistance_types = ["slow"]
	var waypoints: Array[Vector2] = [Vector2(0, 0), Vector2(500, 0)]
	e.setup(d, waypoints, 1)
	add_child_autofree(e)
	e.apply_slow(0.5, 2.0)
	assert_eq(e._slow_factor, 1.0)

func test_path_progress_starts_at_zero() -> void:
	var e := _make_enemy()
	assert_eq(e.path_progress(), 0.0)

func test_hp_ratio_full_at_start() -> void:
	var e := _make_enemy(100)
	assert_eq(e.hp_ratio(), 1.0)

func test_hp_ratio_after_damage() -> void:
	var e := _make_enemy(100)
	e.take_damage(50)
	assert_true(abs(e.hp_ratio() - 0.5) < 0.001)
