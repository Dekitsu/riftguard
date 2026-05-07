class_name Enemy
extends Node2D

signal died(gold_reward: int)
signal reached_gate

var data: EnemyData
var current_hp: int
var current_speed: float
var _waypoints: Array[Vector2] = []
var _waypoint_index: int = 0

# Active effects
var _slow_timer: float = 0.0
var _slow_factor: float = 1.0
var _dot_timer: float = 0.0
var _dot_damage_per_tick: int = 0
var _dot_tick_interval: float = 1.0
var _dot_tick_timer: float = 0.0

func setup(enemy_data: EnemyData, waypoints: Array[Vector2], wave_index: int) -> void:
	data = enemy_data
	current_hp = int(enemy_data.max_hp * EconomyData.hp_scale(wave_index))
	current_speed = enemy_data.speed * EconomyData.speed_scale(wave_index)
	_waypoints = waypoints
	_waypoint_index = 0
	if not _waypoints.is_empty():
		global_position = _waypoints[0]

func _process(delta: float) -> void:
	_tick_effects(delta)
	_move(delta)

func _move(delta: float) -> void:
	if _waypoint_index >= _waypoints.size():
		reached_gate.emit()
		queue_free()
		return
	var target := _waypoints[_waypoint_index]
	var effective_speed := current_speed * _slow_factor
	var step := effective_speed * delta
	if global_position.distance_to(target) <= step:
		global_position = target
		_waypoint_index += 1
	else:
		global_position = global_position.move_toward(target, step)

func take_damage(amount: int) -> void:
	var effective := max(0, amount - int(data.armor))
	current_hp -= effective
	if current_hp <= 0:
		died.emit(data.gold_reward)
		queue_free()

func apply_slow(factor: float, duration: float) -> void:
	if "slow" in data.resistance_types:
		return
	_slow_factor = min(_slow_factor, factor)
	_slow_timer = max(_slow_timer, duration)

func apply_dot(damage_per_tick: int, duration: float, tick_interval: float) -> void:
	_dot_damage_per_tick = damage_per_tick
	_dot_timer = duration
	_dot_tick_interval = tick_interval
	_dot_tick_timer = tick_interval

func _tick_effects(delta: float) -> void:
	if _slow_timer > 0.0:
		_slow_timer -= delta
		if _slow_timer <= 0.0:
			_slow_factor = 1.0
	if _dot_timer > 0.0:
		_dot_timer -= delta
		_dot_tick_timer -= delta
		if _dot_tick_timer <= 0.0:
			_dot_tick_timer = _dot_tick_interval
			take_damage(_dot_damage_per_tick)

## Progress along path [0.0 – 1.0], used for targeting.
func path_progress() -> float:
	if _waypoints.size() <= 1:
		return 0.0
	return float(_waypoint_index) / float(_waypoints.size() - 1)

func hp_ratio() -> float:
	return float(current_hp) / float(data.max_hp)
