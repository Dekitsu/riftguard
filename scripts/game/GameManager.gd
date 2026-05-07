## Top-level orchestrator for one run.
class_name GameManager
extends Node

signal phase_changed(phase: Phase)

enum Phase { PREP, WAVE, DRAFT, RESULT }

@export var wave_scene: PackedScene
@export var enemy_scene: PackedScene
@export var tower_scene: PackedScene

@onready var _spawner: WaveSpawner = $WaveSpawner
@onready var _slots: Node2D = $TowerSlots

var run: RunState
var draft: DraftManager
var _phase: Phase = Phase.PREP
var _gate_hits: int = 0

func start_run(faction: TowerData.Faction, wave_set: WaveSet, waypoints: Array[Vector2]) -> void:
	run = RunState.new()
	run.setup(faction)
	run.run_won.connect(_on_run_won)
	run.run_lost.connect(_on_run_lost)

	draft = DraftManager.new()
	draft.setup(faction, _load_all_towers())

	_spawner.setup(wave_set, waypoints, enemy_scene)
	_spawner.wave_cleared.connect(_on_wave_cleared)
	_spawner.all_waves_cleared.connect(_on_all_waves_cleared)
	_spawner.enemy_reached_gate.connect(_on_enemy_reached_gate)

	for slot in _slots.get_children():
		if slot is TowerSlot:
			slot.slot_tapped.connect(_on_slot_tapped)

	_set_phase(Phase.PREP)

func launch_wave() -> void:
	if _phase != Phase.PREP and _phase != Phase.DRAFT:
		return
	_set_phase(Phase.WAVE)
	_spawner.start_next_wave()

func _on_wave_cleared(wave_idx: int, gold: int) -> void:
	run.earn_gold(gold)
	if _spawner._current_wave >= _spawner._wave_set.total_waves:
		return  # all_waves_cleared will fire
	draft.generate_draft()
	_set_phase(Phase.DRAFT)

func _on_all_waves_cleared() -> void:
	run.run_won.emit()

func _on_enemy_reached_gate() -> void:
	_gate_hits += 1
	run.lose_life()

func _on_slot_tapped(slot: TowerSlot) -> void:
	# UI handles showing place/upgrade/sell panel — GameManager just routes state
	pass

func _on_run_won() -> void:
	_set_phase(Phase.RESULT)

func _on_run_lost() -> void:
	_set_phase(Phase.RESULT)

func _set_phase(p: Phase) -> void:
	_phase = p
	phase_changed.emit(p)

func _load_all_towers() -> Array[TowerData]:
	var result: Array[TowerData] = []
	var dir := DirAccess.open("res://resources/towers/")
	if dir == null:
		return result
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var td: TowerData = load("res://resources/towers/" + file)
			if td != null:
				result.append(td)
		file = dir.get_next()
	return result
