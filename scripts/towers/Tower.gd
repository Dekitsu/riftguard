class_name Tower
extends Node2D

signal enemy_killed(tower: Tower, enemy: Enemy)

var data: TowerData
var level: int = 1
var run_state: RunState = null   # injected after placement
var _enemies_in_range: Array[Enemy] = []
var _fire_timer: float = 0.0

func setup(tower_data: TowerData, rs: RunState = null) -> void:
	data = tower_data
	run_state = rs
	level = 1
	_update_range_shape()

func _process(delta: float) -> void:
	_fire_timer -= delta
	if _fire_timer <= 0.0:
		var stats := data.stats_at_level(level)
		_fire_timer = 1.0 / stats.fire_rate
		var target := _pick_target()
		if target != null:
			_shoot(target, stats)

func _pick_target() -> Enemy:
	# Purge invalid refs
	var valid: Array[Enemy] = []
	for e in _enemies_in_range:
		if is_instance_valid(e):
			valid.append(e)
	_enemies_in_range = valid
	if _enemies_in_range.is_empty():
		return null

	var best: Enemy = _enemies_in_range[0]
	match data.target_mode:
		TowerData.TargetMode.FIRST:
			for e in _enemies_in_range:
				if e.path_progress() > best.path_progress():
					best = e
		TowerData.TargetMode.LAST:
			for e in _enemies_in_range:
				if e.path_progress() < best.path_progress():
					best = e
		TowerData.TargetMode.LOWEST_HP:
			for e in _enemies_in_range:
				if e.current_hp < best.current_hp:
					best = e
		TowerData.TargetMode.HIGHEST_HP:
			for e in _enemies_in_range:
				if e.current_hp > best.current_hp:
					best = e
		TowerData.TargetMode.FASTEST:
			for e in _enemies_in_range:
				if e.current_speed > best.current_speed:
					best = e
		TowerData.TargetMode.CLOSEST:
			for e in _enemies_in_range:
				if global_position.distance_to(e.global_position) < global_position.distance_to(best.global_position):
					best = e
		TowerData.TargetMode.FLYING_FIRST:
			var flying: Array[Enemy] = []
			for e in _enemies_in_range:
				if e.data.is_flying:
					flying.append(e)
			best = flying[0] if not flying.is_empty() else _enemies_in_range[0]
		TowerData.TargetMode.GROUND_FIRST:
			var ground: Array[Enemy] = []
			for e in _enemies_in_range:
				if not e.data.is_flying:
					ground.append(e)
			best = ground[0] if not ground.is_empty() else _enemies_in_range[0]
	return best

func _effective_damage(base: int, target: Enemy) -> int:
	if run_state != null:
		return run_state.modify_damage(base, target, self)
	return base

func _shoot(target: Enemy, stats: Dictionary) -> void:
	match data.special:
		TowerData.TowerSpecial.NONE:
			_deal(target, _effective_damage(stats.damage, target))
		TowerData.TowerSpecial.SLOW:
			_deal(target, _effective_damage(stats.damage, target))
			target.apply_slow(data.slow_factor, data.slow_duration)
		TowerData.TowerSpecial.AOE:
			_shoot_aoe(stats.damage)
		TowerData.TowerSpecial.CHAIN:
			_shoot_chain(target, stats.damage)
		TowerData.TowerSpecial.DOT:
			var tick_dmg := stats.damage / data.dot_ticks
			target.apply_dot(tick_dmg, data.dot_duration, data.dot_duration / float(data.dot_ticks))
		TowerData.TowerSpecial.BUFF:
			pass

func _deal(target: Enemy, amount: int) -> void:
	if not is_instance_valid(target):
		return
	target.take_damage(amount)
	if not is_instance_valid(target):
		enemy_killed.emit(self, target)

func _shoot_aoe(damage: int) -> void:
	var stats := data.stats_at_level(level)
	for e in _enemies_in_range:
		if is_instance_valid(e) and global_position.distance_to(e.global_position) <= stats.range:
			e.take_damage(damage)

func _shoot_chain(first: Enemy, damage: int) -> void:
	first.take_damage(damage)
	var hit: Array[Enemy] = [first]
	var remaining_chains := data.chain_count
	var source_pos := first.global_position
	while remaining_chains > 0:
		var next: Enemy = null
		var best_dist := INF
		for e in _enemies_in_range:
			if is_instance_valid(e) and not hit.has(e):
				var d := source_pos.distance_to(e.global_position)
				if d < best_dist:
					best_dist = d
					next = e
		if next == null:
			break
		next.take_damage(int(damage * 0.6))
		hit.append(next)
		source_pos = next.global_position
		remaining_chains -= 1

func upgrade() -> bool:
	if level >= data.max_level:
		return false
	level += 1
	_update_range_shape()
	return true

func upgrade_cost() -> int:
	return data.stats_at_level(level).upgrade_cost

func sell_value(total_invested: int) -> int:
	return int(total_invested * EconomyData.SELL_REFUND_RATE)

func _update_range_shape() -> void:
	var stats := data.stats_at_level(level)
	# Range visual update — override in scene with actual CollisionShape2D
	pass

func _on_enemy_entered(body: Node2D) -> void:
	if body is Enemy:
		_enemies_in_range.append(body)

func _on_enemy_exited(body: Node2D) -> void:
	_enemies_in_range.erase(body)
