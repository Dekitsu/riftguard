## Called at run end to award XP, update save data, and show result screen.
class_name RunEndManager
extends RefCounted

static func on_run_finished(run: RunState, waves_cleared: int, won: bool) -> void:
	run.highest_wave = waves_cleared
	var xp: int = run.xp_earned()
	SaveData.increment_runs()
	SaveData.update_best_wave(run.faction, waves_cleared)

	var progression := FactionProgression.new()
	progression.setup(run.faction)
	progression.deserialize({
		"faction": int(run.faction),
		"level": SaveData.get_faction_level(run.faction),
		"xp": SaveData.get_faction_xp(run.faction),
	})
	progression.earn_xp(xp)
	SaveData.set_faction_xp(run.faction, progression.level, progression.xp)
	SaveData.save()
