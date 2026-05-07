## Applies the active faction's synergy during a run.
class_name FactionSynergyManager
extends RefCounted

signal gold_earned(amount: int)

var faction: TowerData.Faction
var _ferrux: FerruxStrategy = null
var _solariens_active: bool = false

func setup(f: TowerData.Faction) -> void:
	faction = f
	if faction == TowerData.Faction.FERREUX:
		_ferrux = FerruxStrategy.new()
		_ferrux.gold_earned.connect(func(g): gold_earned.emit(g))

## Called by Tower when it damages/kills an enemy.
func on_enemy_killed(tower_pos: Vector2, all_tower_positions: Array[Vector2]) -> void:
	match faction:
		TowerData.Faction.FERREUX:
			if _ferrux != null:
				_ferrux.on_enemy_killed()

## Called by Tower before dealing damage to optionally modify the amount.
func modify_damage(base: int, target: Enemy, shooter_pos: Vector2, all_tower_positions: Array[Vector2]) -> int:
	match faction:
		TowerData.Faction.GELIDES:
			return GelidesStrategy.amplified_damage(target, base)
		TowerData.Faction.SOLARIENS:
			var aligned := SolariensStrategy.are_aligned(all_tower_positions)
			return SolariensStrategy.apply_bonus(base, aligned)
		_:
			return base

## Refresh alignment state (call when a tower is placed/sold).
func refresh_alignment(positions: Array[Vector2]) -> void:
	_solariens_active = SolariensStrategy.are_aligned(positions)
