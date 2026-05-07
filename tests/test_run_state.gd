extends GutTest

func _make_run() -> RunState:
	var r := RunState.new()
	r.setup(TowerData.Faction.SOLARIENS)
	return r

func test_starts_with_correct_gold() -> void:
	var r := _make_run()
	assert_eq(r.gold, EconomyData.STARTING_GOLD)

func test_starts_with_max_lives() -> void:
	var r := _make_run()
	assert_eq(r.lives, RunState.MAX_LIVES)

func test_earn_gold_increases_gold() -> void:
	var r := _make_run()
	r.earn_gold(50)
	assert_eq(r.gold, EconomyData.STARTING_GOLD + 50)

func test_spend_gold_decreases_gold() -> void:
	var r := _make_run()
	var ok := r.spend_gold(50)
	assert_true(ok)
	assert_eq(r.gold, EconomyData.STARTING_GOLD - 50)

func test_spend_gold_fails_if_insufficient() -> void:
	var r := _make_run()
	var ok := r.spend_gold(EconomyData.STARTING_GOLD + 1)
	assert_false(ok)
	assert_eq(r.gold, EconomyData.STARTING_GOLD)

func test_lose_life_decrements() -> void:
	var r := _make_run()
	r.lose_life()
	assert_eq(r.lives, RunState.MAX_LIVES - 1)

func test_run_lost_signal_at_zero_lives() -> void:
	var r := _make_run()
	watch_signals(r)
	for _i in RunState.MAX_LIVES:
		r.lose_life()
	assert_signal_emitted(r, "run_lost")

func test_gold_signal_emitted_on_earn() -> void:
	var r := _make_run()
	watch_signals(r)
	r.earn_gold(10)
	assert_signal_emitted(r, "gold_changed")

func test_gold_signal_emitted_on_spend() -> void:
	var r := _make_run()
	watch_signals(r)
	r.spend_gold(10)
	assert_signal_emitted(r, "gold_changed")
