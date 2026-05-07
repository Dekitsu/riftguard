## Data for one wave in a run. Collection stored as WaveSet resource.
class_name WaveData
extends Resource

## One group of enemies spawned in sequence.
class SpawnGroup extends Resource:
	@export var enemy: EnemyData
	@export var count: int = 1
	@export var interval: float = 0.8   # seconds between spawns in group
	@export var delay_before: float = 0.0  # pause before this group starts

@export var wave_index: int              # 1-based
@export var is_boss_wave: bool = false
@export var groups: Array[SpawnGroup] = []
@export var gold_bonus: int = 0          # extra gold awarded on wave clear
@export var modifier_id: StringName = &"" # optional boss wave modifier
