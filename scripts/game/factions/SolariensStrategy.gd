## Solariens faction synergy: 3+ aligned towers deal +20% bonus damage.
class_name SolariensStrategy

const ALIGNMENT_THRESHOLD := 3
const ALIGNED_DAMAGE_BONUS := 0.20
const ALIGNMENT_TOLERANCE := 40.0  # pixels — slots within this Y delta count as aligned

## Returns true if at least ALIGNMENT_THRESHOLD positions share the same axis (row or column).
static func are_aligned(positions: Array[Vector2]) -> bool:
	if positions.size() < ALIGNMENT_THRESHOLD:
		return false
	# Check horizontal alignment (same Y ± tolerance)
	for i in positions.size():
		var count: int = 0
		for j in positions.size():
			if abs(positions[i].y - positions[j].y) <= ALIGNMENT_TOLERANCE:
				count += 1
		if count >= ALIGNMENT_THRESHOLD:
			return true
	# Check vertical alignment (same X ± tolerance)
	for i in positions.size():
		var count: int = 0
		for j in positions.size():
			if abs(positions[i].x - positions[j].x) <= ALIGNMENT_TOLERANCE:
				count += 1
		if count >= ALIGNMENT_THRESHOLD:
			return true
	return false

## Returns effective damage with alignment bonus if active.
static func apply_bonus(base_damage: int, aligned: bool) -> int:
	if aligned:
		return int(base_damage * (1.0 + ALIGNED_DAMAGE_BONUS))
	return base_damage
