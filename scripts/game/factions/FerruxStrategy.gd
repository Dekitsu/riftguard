## Ferreux faction synergy: each enemy killed by a Ferreux tower awards bonus gold.
class_name FerruxStrategy
extends RefCounted

signal gold_earned(amount: int)

const GOLD_PER_KILL := 2

func on_enemy_killed() -> void:
	gold_earned.emit(GOLD_PER_KILL)
