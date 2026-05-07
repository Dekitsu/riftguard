## Static data for one tower type. Stored as .tres resource.
class_name TowerData
extends Resource

enum Faction { SOLARIENS, GELIDES, FERREUX }

enum TargetMode {
	FIRST,        # Most advanced on path
	LAST,         # Least advanced
	LOWEST_HP,    # Finisher — target near-dead enemies
	HIGHEST_HP,   # Anti-armor — focus toughest
	FASTEST,      # Anti-rush — target fastest mover
	CLOSEST,      # Short-range / AOE towers
	FLYING_FIRST, # Prioritize flying enemies
	GROUND_FIRST, # Prioritize ground enemies
}

enum TowerSpecial {
	NONE,
	SLOW,      # Applies slow on hit
	CHAIN,     # Damage chains to nearby enemies
	AOE,       # Damages all enemies in radius
	BUFF,      # Buffs adjacent towers
	DOT,       # Damage over time
}

@export var id: StringName
@export var display_name: String
@export var description: String
@export var faction: Faction
@export var target_mode: TargetMode = TargetMode.FIRST
@export var special: TowerSpecial = TowerSpecial.NONE

# Base stats (level 1)
@export var damage: int = 10
@export var range: float = 200.0
@export var fire_rate: float = 1.0   # shots per second
@export var cost: int = 50

# Per-level scaling multipliers (applied on top of base)
@export var damage_per_level: float = 0.3   # +30% per level
@export var range_per_level: float = 0.1
@export var fire_rate_per_level: float = 0.15
@export var upgrade_cost_base: int = 40
@export var upgrade_cost_per_level: float = 0.5

@export var max_level: int = 5

# Special effect parameters
@export var slow_factor: float = 0.5     # 0.5 = 50% speed
@export var slow_duration: float = 1.0
@export var chain_count: int = 2
@export var aoe_radius: float = 80.0
@export var dot_duration: float = 3.0
@export var dot_ticks: int = 3

func stats_at_level(level: int) -> Dictionary:
	var l: int = clamp(level, 1, max_level) - 1
	return {
		"damage":    int(damage * (1.0 + damage_per_level * l)),
		"range":     range * (1.0 + range_per_level * l),
		"fire_rate": fire_rate * (1.0 + fire_rate_per_level * l),
		"upgrade_cost": int(upgrade_cost_base * (1.0 + upgrade_cost_per_level * l)),
	}
