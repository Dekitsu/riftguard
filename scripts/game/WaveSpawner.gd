## Spawns enemies along a waypoint path according to WaveData.
class_name WaveSpawner
extends Node

signal wave_started(wave_index: int)
signal wave_cleared(wave_index: int, gold_earned: int)
signal all_waves_cleared
signal enemy_reached_gate

var _wave_set: WaveSet
var _waypoints: Array[Vector2] = []
var _current_wave: int = 0
var _enemies_alive: int = 0
var _wave_active: bool = false
var _enemy_scene: PackedScene

func setup(wave_set: WaveSet, waypoints: Array[Vector2], enemy_scene: PackedScene) -> void:
	_wave_set = wave_set
	_waypoints = waypoints
	_enemy_scene = enemy_scene

func start_next_wave() -> void:
	if _current_wave >= _wave_set.waves.size():
		all_waves_cleared.emit()
		return
	_wave_active = true
	var wave_data: WaveData = _wave_set.waves[_current_wave]
	wave_started.emit(wave_data.wave_index)
	_spawn_wave(wave_data)

func _spawn_wave(wave_data: WaveData) -> void:
	_enemies_alive = 0
	for group in wave_data.groups:
		_enemies_alive += group.count
	_spawn_groups(wave_data.groups, wave_data.wave_index)

func _spawn_groups(groups: Array, wave_index: int) -> void:
	var delay := 0.0
	for group in groups:
		delay += group.delay_before
		for i in group.count:
			var t := Timer.new()
			t.wait_time = delay + i * group.interval
			t.one_shot = true
			add_child(t)
			t.start()
			var d := group  # capture
			var wi := wave_index
			t.timeout.connect(func(): _spawn_enemy(d.enemy, wi); t.queue_free())
		delay += group.count * group.interval

func _spawn_enemy(enemy_data: EnemyData, wave_index: int) -> void:
	var e: Enemy = _enemy_scene.instantiate()
	get_parent().add_child(e)
	e.setup(enemy_data, _waypoints, wave_index)
	e.died.connect(_on_enemy_died.bind(_wave_set.waves[_current_wave]))
	e.reached_gate.connect(_on_enemy_reached_gate)

func _on_enemy_died(_gold: int, _wave_data: WaveData) -> void:
	_enemies_alive -= 1
	_check_wave_clear()

func _on_enemy_reached_gate() -> void:
	_enemies_alive -= 1
	enemy_reached_gate.emit()
	_check_wave_clear()

func _check_wave_clear() -> void:
	if _enemies_alive > 0 or not _wave_active:
		return
	_wave_active = false
	var wave_data: WaveData = _wave_set.waves[_current_wave]
	var gold := EconomyData.gold_for_wave(wave_data.wave_index) + wave_data.gold_bonus
	if wave_data.is_boss_wave:
		gold += EconomyData.BOSS_WAVE_GOLD_BONUS
	_current_wave += 1
	wave_cleared.emit(wave_data.wave_index, gold)
	if _current_wave >= _wave_set.waves.size():
		all_waves_cleared.emit()
