## End-of-run screen: victory or defeat.
class_name ResultScreen
extends CanvasLayer

signal replay_requested
signal main_menu_requested

@onready var _title: Label = %TitleLabel
@onready var _summary: Label = %SummaryLabel
@onready var _replay_btn: Button = %ReplayBtn
@onready var _menu_btn: Button = %MenuBtn

func _ready() -> void:
	_replay_btn.pressed.connect(func(): replay_requested.emit())
	_menu_btn.pressed.connect(func(): main_menu_requested.emit())
	hide()

func show_victory(waves_cleared: int, gold_left: int) -> void:
	_title.text = "Victoire !"
	_summary.text = "%d vagues repoussées\n%d ⚙ restants" % [waves_cleared, gold_left]
	show()

func show_defeat(wave_reached: int, lives_lost: int) -> void:
	_title.text = "Défaite"
	_summary.text = "Vague %d atteinte\n%d cœurs perdus" % [wave_reached, lives_lost]
	show()
