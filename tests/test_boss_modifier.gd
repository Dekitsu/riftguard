extends GutTest

# ── BossModifier system ───────────────────────────────────────────────────────

func test_modifier_none_no_effect() -> void:
	var ctx := BossModifierContext.new(BossModifier.Type.NONE)
	assert_eq(ctx.apply_gold_earned(100), 100)
	assert_eq(ctx.apply_enemy_speed(80.0), 80.0)
	assert_eq(ctx.apply_wave_count(4), 4)

func test_modifier_ruee_increases_speed() -> void:
	var ctx := BossModifierContext.new(BossModifier.Type.RUEE)
	assert_true(ctx.apply_enemy_speed(80.0) > 80.0)

func test_modifier_famine_reduces_gold() -> void:
	var ctx := BossModifierContext.new(BossModifier.Type.FAMINE)
	assert_true(ctx.apply_gold_earned(100) < 100)

func test_modifier_marche_doubles_wave_enemies() -> void:
	var ctx := BossModifierContext.new(BossModifier.Type.MARCHE)
	assert_true(ctx.apply_wave_count(4) > 4)

func test_modifier_cuirasse_adds_armor() -> void:
	var ctx := BossModifierContext.new(BossModifier.Type.CUIRASSE)
	assert_true(ctx.apply_armor(0.0) > 0.0)

func test_all_modifier_types_defined() -> void:
	assert_true(BossModifier.Type.size() >= 5)
