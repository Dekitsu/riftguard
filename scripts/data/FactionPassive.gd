## Defines one unlockable passive for a faction.
class_name FactionPassive
extends Resource

enum Effect {
	DAMAGE_BONUS,       # +% damage to all faction towers
	RANGE_BONUS,        # +% range
	FIRE_RATE_BONUS,    # +% fire rate
	GOLD_BONUS,         # +% gold per wave
	START_GOLD_BONUS,   # Extra starting gold
	SYNERGY_AMPLIFY,    # Faction synergy bonus increased
	EXTRA_LIVES,        # +N starting lives
}

@export var id: StringName
@export var display_name: String
@export var description: String
@export var unlock_level: int
@export var effect: Effect
@export var value: float   # multiplier delta or flat amount

static func all_for_faction(faction: TowerData.Faction) -> Array[FactionPassive]:
	match faction:
		TowerData.Faction.SOLARIENS:
			return _solariens_passives()
		TowerData.Faction.GELIDES:
			return _gelides_passives()
		TowerData.Faction.FERREUX:
			return _ferreux_passives()
	return []

static func _solariens_passives() -> Array[FactionPassive]:
	return [
		_make(&"sol_dmg_1",      "Lentille Primaire",   "Tours Solariennes +10% dégâts",           1,  Effect.DAMAGE_BONUS,     0.10),
		_make(&"sol_range_3",    "Faisceau Étendu",     "Portée +15%",                              3,  Effect.RANGE_BONUS,      0.15),
		_make(&"sol_syn_5",      "Résonance Solaire",   "Bonus alignement +5% (→ +25%)",            5,  Effect.SYNERGY_AMPLIFY,  0.05),
		_make(&"sol_dmg_8",      "Concentrateur",       "Dégâts +20% supplémentaires",              8,  Effect.DAMAGE_BONUS,     0.20),
		_make(&"sol_gold_12",    "Commerce de Lumière", "Or par vague +15%",                        12, Effect.GOLD_BONUS,       0.15),
		_make(&"sol_range_16",   "Prisme Orbital",      "Portée +20% supplémentaires",              16, Effect.RANGE_BONUS,      0.20),
		_make(&"sol_syn_20",     "Éclat Solaire",       "Bonus alignement doublé (→ +50%)",         20, Effect.SYNERGY_AMPLIFY,  0.25),
	]

static func _gelides_passives() -> Array[FactionPassive]:
	return [
		_make(&"gel_dmg_1",      "Cristal Primaire",    "Tours Gélides +10% dégâts",                1,  Effect.DAMAGE_BONUS,     0.10),
		_make(&"gel_rate_3",     "Rafale Froide",       "Cadence +15%",                             3,  Effect.FIRE_RATE_BONUS,  0.15),
		_make(&"gel_syn_5",      "Gel Profond",         "Amplification gel +10% (→ ×1.6)",          5,  Effect.SYNERGY_AMPLIFY,  0.10),
		_make(&"gel_dmg_8",      "Tempête de Glace",    "Dégâts +20%",                              8,  Effect.DAMAGE_BONUS,     0.20),
		_make(&"gel_lives_12",   "Fortification",       "+3 vies de départ",                        12, Effect.EXTRA_LIVES,      3.0),
		_make(&"gel_rate_16",    "Blizzard Continu",    "Cadence +20%",                             16, Effect.FIRE_RATE_BONUS,  0.20),
		_make(&"gel_syn_20",     "Cryogénèse",          "Gel amplifie dégâts ×2.0",                 20, Effect.SYNERGY_AMPLIFY,  0.40),
	]

static func _ferreux_passives() -> Array[FactionPassive]:
	return [
		_make(&"fer_gold_1",     "Fonderie",            "+1 or supplémentaire par kill Ferreux",    1,  Effect.GOLD_BONUS,       0.0),
		_make(&"fer_dmg_3",      "Acier Trempé",        "Dégâts +15%",                              3,  Effect.DAMAGE_BONUS,     0.15),
		_make(&"fer_start_5",    "Arsenal",             "+50 or de départ",                         5,  Effect.START_GOLD_BONUS, 50.0),
		_make(&"fer_dmg_8",      "Fonte Lourde",        "Dégâts +25%",                              8,  Effect.DAMAGE_BONUS,     0.25),
		_make(&"fer_gold_12",    "Commerce de Fer",     "Or par vague +20%",                        12, Effect.GOLD_BONUS,       0.20),
		_make(&"fer_lives_16",   "Muraille",            "+5 vies de départ",                        16, Effect.EXTRA_LIVES,      5.0),
		_make(&"fer_syn_20",     "Golem Eternal",       "+3 or par kill Ferreux",                   20, Effect.GOLD_BONUS,       0.0),
	]

static func _make(id: StringName, name: String, desc: String, lvl: int, effect: Effect, val: float) -> FactionPassive:
	var p := FactionPassive.new()
	p.id = id
	p.display_name = name
	p.description = desc
	p.unlock_level = lvl
	p.effect = effect
	p.value = val
	return p
