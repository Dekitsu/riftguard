extends GutTest

func _make_enemy_of_type(type: EnemyData.EnemyType, hp: int = 100, armor: float = 0.0) -> Enemy:
	var e := Enemy.new()
	var d := EnemyData.new()
	d.type = type
	d.max_hp = hp
	d.speed = 80.0
	d.armor = armor
	d.gold_reward = 5
	d.resistance_types = []
	d.is_flying = (type == EnemyData.EnemyType.FLYING)
	var waypoints: Array[Vector2] = [Vector2(0, 0), Vector2(500, 0)]
	e.setup(d, waypoints, 1)
	add_child_autofree(e)
	return e

# ── Armored ───────────────────────────────────────────────────────────────────

func test_armored_50_percent_reduction() -> void:
	var e := _make_enemy_of_type(EnemyData.EnemyType.ARMORED, 100, 0.0)
	# Armored uses a damage multiplier, not flat armor
	e.data.physical_resist = 0.5
	e.take_damage_typed(20, Enemy.DamageType.PHYSICAL)
	assert_eq(e.current_hp, 90)  # 20 * 0.5 = 10 damage

func test_armored_magic_damage_full() -> void:
	var e := _make_enemy_of_type(EnemyData.EnemyType.ARMORED, 100, 0.0)
	e.data.physical_resist = 0.5
	e.take_damage_typed(20, Enemy.DamageType.MAGIC)
	assert_eq(e.current_hp, 80)  # no reduction

# ── Swarm ─────────────────────────────────────────────────────────────────────

func test_swarm_emits_spawn_on_death() -> void:
	var e := _make_enemy_of_type(EnemyData.EnemyType.SWARM, 50)
	var sub_data := EnemyData.new()
	sub_data.max_hp = 20
	sub_data.speed = 90.0
	sub_data.armor = 0.0
	sub_data.gold_reward = 1
	sub_data.resistance_types = []
	e.data.swarm_count = 4
	e.data.swarm_unit = sub_data
	watch_signals(e)
	e.take_damage(50)
	assert_signal_emitted(e, "spawned_swarm")

func test_swarm_spawn_count() -> void:
	var e := _make_enemy_of_type(EnemyData.EnemyType.SWARM, 50)
	var sub_data := EnemyData.new()
	sub_data.max_hp = 20
	sub_data.speed = 90.0
	sub_data.armor = 0.0
	sub_data.gold_reward = 1
	sub_data.resistance_types = []
	e.data.swarm_count = 4
	e.data.swarm_unit = sub_data
	var count := 0
	e.spawned_swarm.connect(func(units): count = units.size())
	e.take_damage(50)
	assert_eq(count, 4)

# ── Flying ────────────────────────────────────────────────────────────────────

func test_flying_enemy_is_flagged() -> void:
	var e := _make_enemy_of_type(EnemyData.EnemyType.FLYING)
	assert_true(e.data.is_flying)

func test_flying_enemy_takes_normal_damage() -> void:
	var e := _make_enemy_of_type(EnemyData.EnemyType.FLYING, 100)
	e.take_damage(30)
	assert_eq(e.current_hp, 70)

# ── Boss ──────────────────────────────────────────────────────────────────────

func test_boss_has_high_hp() -> void:
	var e := _make_enemy_of_type(EnemyData.EnemyType.BOSS, 1000)
	assert_true(e.current_hp >= 1000)

func test_boss_resistance_blocks_slow() -> void:
	var e := _make_enemy_of_type(EnemyData.EnemyType.BOSS)
	e.data.resistance_types = ["slow"]
	e.apply_slow(0.5, 3.0)
	assert_eq(e._slow_factor, 1.0)
