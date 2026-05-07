extends GutTest

func _make_wave_set(enemy_count: int = 3) -> WaveSet:
	var ws := WaveSet.new()
	ws.map_id = &"test_map"
	ws.total_waves = 1

	var ed := EnemyData.new()
	ed.id = &"marcheur"
	ed.max_hp = 100
	ed.speed = 80.0
	ed.armor = 0.0
	ed.gold_reward = 5
	ed.resistance_types = []

	var grp := WaveData.SpawnGroup.new()
	grp.enemy = ed
	grp.count = enemy_count
	grp.interval = 0.0
	grp.delay_before = 0.0

	var wd := WaveData.new()
	wd.wave_index = 1
	wd.is_boss_wave = false
	wd.groups = [grp]

	ws.waves = [wd]
	return ws

func test_wave_cleared_signal_emitted() -> void:
	# WaveSpawner requires a scene for enemies — test signal wiring only
	var spawner := WaveSpawner.new()
	add_child_autofree(spawner)
	watch_signals(spawner)
	# Simulate direct call to _check_wave_clear with 0 enemies
	spawner._wave_set = _make_wave_set()
	spawner._current_wave = 0
	spawner._enemies_alive = 0
	spawner._wave_active = true
	spawner._check_wave_clear()
	assert_signal_emitted(spawner, "wave_cleared")

func test_wave_clear_gold_includes_base_and_bonus() -> void:
	var spawner := WaveSpawner.new()
	add_child_autofree(spawner)
	var received_gold := -1
	spawner.wave_cleared.connect(func(_wi, g): received_gold = g)
	spawner._wave_set = _make_wave_set()
	spawner._current_wave = 0
	spawner._enemies_alive = 0
	spawner._wave_active = true
	spawner._check_wave_clear()
	var expected := EconomyData.gold_for_wave(1)
	assert_eq(received_gold, expected)

func test_all_waves_cleared_after_last_wave() -> void:
	var spawner := WaveSpawner.new()
	add_child_autofree(spawner)
	watch_signals(spawner)
	spawner._wave_set = _make_wave_set()
	spawner._current_wave = 0
	spawner._enemies_alive = 0
	spawner._wave_active = true
	spawner._check_wave_clear()
	assert_signal_emitted(spawner, "all_waves_cleared")
