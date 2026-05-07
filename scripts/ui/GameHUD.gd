## In-run HUD: gold, lives, wave counter, launch button.
class_name GameHUD
extends CanvasLayer

signal launch_wave_requested

@onready var _gold_label: Label = %GoldLabel
@onready var _lives_label: Label = %LivesLabel
@onready var _wave_label: Label = %WaveLabel
@onready var _launch_btn: Button = %LaunchBtn
@onready var _phase_label: Label = %PhaseLabel

func _ready() -> void:
	_launch_btn.pressed.connect(func(): launch_wave_requested.emit())

func bind(run: RunState, manager: GameManager) -> void:
	run.gold_changed.connect(_on_gold_changed)
	run.lives_changed.connect(_on_lives_changed)
	manager.phase_changed.connect(_on_phase_changed)
	_on_gold_changed(run.gold)
	_on_lives_changed(run.lives)
	_on_phase_changed(GameManager.Phase.PREP)

func _on_gold_changed(amount: int) -> void:
	_gold_label.text = "⚙ %d" % amount

func _on_lives_changed(lives: int) -> void:
	_lives_label.text = "♥ %d" % lives

func set_wave(index: int, total: int) -> void:
	_wave_label.text = "Vague %d / %d" % [index, total]

func _on_phase_changed(phase: GameManager.Phase) -> void:
	match phase:
		GameManager.Phase.PREP:
			_launch_btn.show()
			_launch_btn.text = "Lancer la vague"
			_phase_label.text = "Préparation"
		GameManager.Phase.WAVE:
			_launch_btn.hide()
			_phase_label.text = "En cours…"
		GameManager.Phase.DRAFT:
			_launch_btn.show()
			_launch_btn.text = "Lancer la vague"
			_phase_label.text = "Draft — choisissez une tour"
		GameManager.Phase.RESULT:
			_launch_btn.hide()
			_phase_label.text = ""
