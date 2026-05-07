## Economy constants derived from the balance spreadsheet.
## All values calibrated for a 12-wave run.
class_name EconomyData

# Starting gold
const STARTING_GOLD := 100

# Gold per wave clear (wave_index 1-based)
# Formula: 15 + wave_index * 5  (wave 1 = 20, wave 12 = 75)
static func gold_for_wave(wave_index: int) -> int:
	return 15 + wave_index * 5

# Boss wave bonus (waves 4, 8, 12)
const BOSS_WAVE_GOLD_BONUS := 30

# Tower base costs (level 1)
# Calibrated: starting_gold = ~2 towers level 1
const TOWER_COST_CHEAP   := 40    # basic towers
const TOWER_COST_MEDIUM  := 65    # specialized towers
const TOWER_COST_HEAVY   := 90    # heavy/AOE towers

# Upgrade cost formula: base_upgrade * (1 + 0.5 * (current_level - 1))
# Level 1→2: base, Level 2→3: +50%, etc.

# Sell value: 70% of total invested (purchase + upgrades)
const SELL_REFUND_RATE := 0.7

# Draft: 3 choices offered per wave clear
const DRAFT_CHOICES := 3

# ── Balance targets ──────────────────────────────────────────────────────────
# Wave 1:  2 towers lv1 survive comfortably (entry experience)
# Wave 6:  5 towers lv2 average → tight but winnable
# Wave 12: 8 towers lv3+ → ~25% first-run clear rate

# HP scaling per wave (applied to EnemyData.max_hp)
# Formula: hp * (1.0 + 0.18 * (wave_index - 1))
# Wave 1: ×1.0 | Wave 6: ×1.9 | Wave 12: ×2.98
static func hp_scale(wave_index: int) -> float:
	return 1.0 + 0.18 * (wave_index - 1)

# Speed scaling (enemies accelerate slightly in later waves)
# Formula: speed * (1.0 + 0.05 * (wave_index - 1))
static func speed_scale(wave_index: int) -> float:
	return 1.0 + 0.05 * (wave_index - 1)
