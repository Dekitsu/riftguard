## Root script for the in-game scene. Wires GameManager ↔ UI.
class_name GameScreen
extends Node

@export var faction: TowerData.Faction = TowerData.Faction.SOLARIENS
@export var wave_set_resource: WaveSet

@onready var _manager: GameManager = $GameManager
@onready var _map: MapScene = $Map01
@onready var _hud: GameHUD = $GameHUD
@onready var _tower_panel: TowerPanel = $TowerPanel
@onready var _draft_panel: DraftPanel = $DraftPanel
@onready var _result: ResultScreen = $ResultScreen

var _draft_choices: Array[TowerData] = []
var _current_slot: TowerSlot = null

func _ready() -> void:
	var ws := wave_set_resource if wave_set_resource != null else _build_default_wave_set()

	_manager.start_run(faction, ws, _map.waypoints)
	_hud.bind(_manager.run, _manager)

	_manager.run.run_won.connect(_on_run_won)
	_manager.run.run_lost.connect(_on_run_lost)
	_manager.draft.draft_ready.connect(_on_draft_ready)
	_manager.slot_tapped.connect(_on_slot_tapped)
	_manager._spawner.wave_started.connect(_on_wave_started)

	_hud.launch_wave_requested.connect(_manager.launch_wave)
	_tower_panel.place_requested.connect(_on_place_requested)
	_tower_panel.upgrade_requested.connect(_on_upgrade_requested)
	_tower_panel.sell_requested.connect(_on_sell_requested)
	_draft_panel.choice_made.connect(_on_draft_choice)
	_result.replay_requested.connect(_reload_scene)
	_result.main_menu_requested.connect(_go_to_menu)

func _on_wave_started(wave_idx: int) -> void:
	_hud.set_wave(wave_idx, _manager._spawner._wave_set.total_waves)

func _on_draft_ready(choices: Array[TowerData]) -> void:
	_draft_choices = choices
	_draft_panel.show_draft(choices)

func _on_draft_choice(index: int) -> void:
	_manager.draft.pick(index)

func _on_slot_tapped(slot: TowerSlot) -> void:
	_current_slot = slot
	if slot.is_occupied():
		var entry := _manager.run._find_entry(slot.tower)
		var invested := entry.invested if entry != null else 0
		_tower_panel.show_tower(slot, _manager.run, invested)
	else:
		_tower_panel.show_empty(slot, _draft_choices, _manager.run)

func _on_place_requested(slot: TowerSlot, td: TowerData) -> void:
	_manager.place_tower(slot, td)

func _on_upgrade_requested(slot: TowerSlot) -> void:
	_manager.upgrade_tower(slot)

func _on_sell_requested(slot: TowerSlot) -> void:
	_manager.sell_tower(slot)

func _on_run_won() -> void:
	var waves := _manager._spawner._current_wave
	RunEndManager.on_run_finished(_manager.run, waves, true)
	_result.show_victory(waves, _manager.run.gold)

func _on_run_lost() -> void:
	var waves := _manager._spawner._current_wave
	RunEndManager.on_run_finished(_manager.run, waves, false)
	_result.show_defeat(waves, RunState.max_lives() - _manager.run.lives)

func _reload_scene() -> void:
	get_tree().reload_current_scene()

func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

func _build_default_wave_set() -> WaveSet:
	var ws := WaveSet.new()
	ws.map_id = &"map01"
	ws.total_waves = 12
	ws.waves = []
	var marcheur_data := EnemyData.new()
	marcheur_data.id = &"marcheur"
	marcheur_data.display_name = "Marcheur"
	marcheur_data.type = EnemyData.EnemyType.WALKER
	marcheur_data.max_hp = 100
	marcheur_data.speed = 80.0
	marcheur_data.gold_reward = 5
	marcheur_data.resistance_types = []
	for i in 12:
		var wave := WaveData.new()
		wave.wave_index = i + 1
		wave.is_boss_wave = (i + 1) % 4 == 0
		var grp := WaveData.SpawnGroup.new()
		grp.enemy = marcheur_data
		grp.count = 4 + i * 2
		grp.interval = 0.8
		grp.delay_before = 0.0
		wave.groups = [grp]
		ws.waves.append(wave)
	return ws
