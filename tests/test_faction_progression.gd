extends GutTest

func _make_progression(faction: TowerData.Faction = TowerData.Faction.SOLARIENS) -> FactionProgression:
	var fp := FactionProgression.new()
	fp.setup(faction)
	return fp

func test_starts_at_level_1() -> void:
	var fp := _make_progression()
	assert_eq(fp.level, 1)

func test_starts_at_zero_xp() -> void:
	var fp := _make_progression()
	assert_eq(fp.xp, 0)

func test_earn_xp_increases_xp() -> void:
	var fp := _make_progression()
	fp.earn_xp(50)
	assert_eq(fp.xp, 50)

func test_level_up_on_xp_threshold() -> void:
	var fp := _make_progression()
	var threshold := FactionProgression.xp_for_level(2)
	fp.earn_xp(threshold)
	assert_eq(fp.level, 2)

func test_level_up_signal_emitted() -> void:
	var fp := _make_progression()
	watch_signals(fp)
	fp.earn_xp(FactionProgression.xp_for_level(2))
	assert_signal_emitted(fp, "leveled_up")

func test_xp_threshold_increases_per_level() -> void:
	for i in range(1, 10):
		assert_true(
			FactionProgression.xp_for_level(i + 2) > FactionProgression.xp_for_level(i + 1),
			"XP threshold should grow each level"
		)

func test_max_level_is_20() -> void:
	assert_eq(FactionProgression.MAX_LEVEL, 20)

func test_passive_unlocked_at_correct_level() -> void:
	var fp := _make_progression()
	# Level 1 passive always unlocked
	assert_true(fp.is_passive_unlocked(1))

func test_passive_locked_above_current_level() -> void:
	var fp := _make_progression()
	assert_false(fp.is_passive_unlocked(5))

func test_passive_unlocked_after_leveling() -> void:
	var fp := _make_progression()
	# Level up to 5
	fp.earn_xp(FactionProgression.xp_for_level(6))
	assert_true(fp.is_passive_unlocked(5))

func test_serialize_deserialize_preserves_state() -> void:
	var fp := _make_progression()
	fp.earn_xp(FactionProgression.xp_for_level(3) + 50)
	var data := fp.serialize()
	var fp2 := FactionProgression.new()
	fp2.setup(TowerData.Faction.SOLARIENS)
	fp2.deserialize(data)
	assert_eq(fp2.level, fp.level)
	assert_eq(fp2.xp, fp.xp)
