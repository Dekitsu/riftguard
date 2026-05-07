extends GutTest

func _make_enemy(hp: int = 100, speed: float = 80.0, is_flying: bool = false) -> Enemy:
	var e := Enemy.new()
	var d := EnemyData.new()
	d.max_hp = hp
	d.speed = speed
	d.armor = 0.0
	d.gold_reward = 5
	d.resistance_types = []
	d.is_flying = is_flying
	var waypoints: Array[Vector2] = [Vector2(0, 0), Vector2(500, 0)]
	e.setup(d, waypoints, 1)
	add_child_autofree(e)
	return e

# ── Gélides synergy: frozen enemies take ×1.5 damage ─────────────────────────

func test_gelides_frozen_enemy_takes_amplified_damage() -> void:
	var e := _make_enemy(100)
	e.apply_slow(0.5, 3.0)  # frozen = slowed
	var dmg := GelidesStrategy.amplified_damage(e, 10)
	assert_eq(dmg, 15)  # 10 × 1.5

func test_gelides_unfrozen_enemy_takes_normal_damage() -> void:
	var e := _make_enemy(100)
	var dmg := GelidesStrategy.amplified_damage(e, 10)
	assert_eq(dmg, 10)

func test_gelides_amplifier_is_1_5() -> void:
	assert_eq(GelidesStrategy.FROZEN_DAMAGE_MULT, 1.5)

# ── Ferreux synergy: gold per enemy killed in range ───────────────────────────

func test_ferreux_kill_awards_bonus_gold() -> void:
	var strategy := FerruxStrategy.new()
	var gold_earned := 0
	strategy.gold_earned.connect(func(g): gold_earned += g)
	strategy.on_enemy_killed()
	assert_true(gold_earned > 0)

func test_ferreux_bonus_gold_amount() -> void:
	var strategy := FerruxStrategy.new()
	var gold_earned := 0
	strategy.gold_earned.connect(func(g): gold_earned = g)
	strategy.on_enemy_killed()
	assert_eq(gold_earned, FerruxStrategy.GOLD_PER_KILL)

func test_ferreux_multiple_kills_stack() -> void:
	var strategy := FerruxStrategy.new()
	var total := 0
	strategy.gold_earned.connect(func(g): total += g)
	for i in 5:
		strategy.on_enemy_killed()
	assert_eq(total, 5 * FerruxStrategy.GOLD_PER_KILL)

# ── Solariens synergy: aligned towers deal shared damage ──────────────────────

func test_solariens_alignment_detected() -> void:
	# 3 towers at same Y = aligned
	var positions := [Vector2(100, 300), Vector2(400, 300), Vector2(700, 300)]
	assert_true(SolariensStrategy.are_aligned(positions))

func test_solariens_non_aligned_not_detected() -> void:
	var positions := [Vector2(100, 300), Vector2(400, 350), Vector2(700, 400)]
	assert_false(SolariensStrategy.are_aligned(positions))

func test_solariens_alignment_threshold() -> void:
	assert_eq(SolariensStrategy.ALIGNMENT_THRESHOLD, 3)

func test_solariens_aligned_damage_bonus() -> void:
	assert_true(SolariensStrategy.ALIGNED_DAMAGE_BONUS > 0.0)
