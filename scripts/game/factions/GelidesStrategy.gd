## Gélides faction synergy: slowed enemies take ×1.5 damage from all sources.
class_name GelidesStrategy

const FROZEN_DAMAGE_MULT := 1.5

## Returns the effective damage to deal, amplified if target is slowed.
static func amplified_damage(enemy: Enemy, base_damage: int) -> int:
	if enemy._slow_factor < 1.0:
		return int(base_damage * FROZEN_DAMAGE_MULT)
	return base_damage
