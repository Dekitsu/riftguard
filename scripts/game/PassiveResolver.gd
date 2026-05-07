## Resolves all active passives for a faction at a given level into flat modifiers.
class_name PassiveResolver

class Resolved extends RefCounted:
	var damage_mult: float = 1.0
	var range_mult: float = 1.0
	var fire_rate_mult: float = 1.0
	var gold_mult: float = 1.0
	var start_gold_bonus: int = 0
	var synergy_bonus: float = 0.0
	var extra_lives: int = 0

static func resolve(faction: TowerData.Faction, faction_level: int) -> Resolved:
	var r := Resolved.new()
	var passives: Array[FactionPassive] = FactionPassive.all_for_faction(faction)
	for p in passives:
		if faction_level < p.unlock_level:
			continue
		match p.effect:
			FactionPassive.Effect.DAMAGE_BONUS:
				r.damage_mult += p.value
			FactionPassive.Effect.RANGE_BONUS:
				r.range_mult += p.value
			FactionPassive.Effect.FIRE_RATE_BONUS:
				r.fire_rate_mult += p.value
			FactionPassive.Effect.GOLD_BONUS:
				r.gold_mult += p.value
			FactionPassive.Effect.START_GOLD_BONUS:
				r.start_gold_bonus += int(p.value)
			FactionPassive.Effect.SYNERGY_AMPLIFY:
				r.synergy_bonus += p.value
			FactionPassive.Effect.EXTRA_LIVES:
				r.extra_lives += int(p.value)
	return r
