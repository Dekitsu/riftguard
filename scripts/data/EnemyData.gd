## Static data for one enemy type. Stored as .tres resource.
class_name EnemyData
extends Resource

enum EnemyType {
	WALKER,   # Standard ground
	FAST,     # 2× speed, half HP
	ARMORED,  # 50% physical damage reduction
	SWARM,    # Spawns 8 weak units
	FLYING,   # Ignores ground towers with GROUND_FIRST mode
	BOSS,     # High HP, random resistance
}

@export var id: StringName
@export var display_name: String
@export var type: EnemyType
@export var max_hp: int = 100
@export var speed: float = 80.0       # pixels/second along path
@export var armor: float = 0.0        # flat damage reduction
@export var gold_reward: int = 5
@export var is_flying: bool = false
@export var physical_resist: float = 0.0  # 0.5 = 50% physical damage reduction

# Swarm parameters
@export var swarm_count: int = 0
@export var swarm_unit: EnemyData = null

# Boss parameters
@export var resistance_types: Array[String] = []  # e.g. ["slow", "chain"]
