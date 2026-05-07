extends GutTest

func test_gold_for_wave_1() -> void:
	assert_eq(EconomyData.gold_for_wave(1), 20)

func test_gold_for_wave_12() -> void:
	assert_eq(EconomyData.gold_for_wave(12), 75)

func test_gold_increases_each_wave() -> void:
	for i in range(1, 12):
		assert_true(EconomyData.gold_for_wave(i + 1) > EconomyData.gold_for_wave(i))

func test_hp_scale_wave_1() -> void:
	assert_eq(EconomyData.hp_scale(1), 1.0)

func test_hp_scale_wave_6_above_1() -> void:
	assert_true(EconomyData.hp_scale(6) > 1.0)

func test_hp_scale_increases() -> void:
	for i in range(1, 12):
		assert_true(EconomyData.hp_scale(i + 1) > EconomyData.hp_scale(i))

func test_speed_scale_wave_1() -> void:
	assert_eq(EconomyData.speed_scale(1), 1.0)

func test_speed_scale_wave_12_above_1() -> void:
	assert_true(EconomyData.speed_scale(12) > 1.0)

func test_starting_gold() -> void:
	assert_eq(EconomyData.STARTING_GOLD, 100)

func test_sell_refund_rate_below_1() -> void:
	assert_true(EconomyData.SELL_REFUND_RATE < 1.0)
	assert_true(EconomyData.SELL_REFUND_RATE > 0.0)
