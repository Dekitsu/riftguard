## Applies a BossModifier to run parameters.
class_name BossModifierContext
extends RefCounted

var type: BossModifier.Type

func _init(t: BossModifier.Type) -> void:
	type = t

func apply_enemy_speed(base_speed: float) -> float:
	if type == BossModifier.Type.RUEE:
		return base_speed * 1.5
	return base_speed

func apply_gold_earned(base_gold: int) -> int:
	if type == BossModifier.Type.FAMINE:
		return int(base_gold * 0.6)
	return base_gold

func apply_wave_count(base_count: int) -> int:
	if type == BossModifier.Type.MARCHE:
		return base_count * 2
	return base_count

func apply_armor(base_armor: float) -> float:
	if type == BossModifier.Type.CUIRASSE:
		return base_armor + 5.0
	return base_armor

func apply_swarm(swarm_count: int) -> int:
	if type == BossModifier.Type.ESSAIM:
		return max(swarm_count, 3)
	return swarm_count
