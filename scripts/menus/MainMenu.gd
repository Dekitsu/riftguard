class_name MainMenu
extends Control

@onready var _play_btn: Button = %PlayBtn
@onready var _orientation_btn: Button = %OrientationBtn
@onready var _quit_btn: Button = %QuitBtn

func _ready() -> void:
	_play_btn.pressed.connect(_on_play)
	_orientation_btn.pressed.connect(_on_toggle_orientation)
	_quit_btn.pressed.connect(get_tree().quit)
	_refresh_orientation_label()
	GameSettings.orientation_changed.connect(func(_o): _refresh_orientation_label())

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/FactionSelect.tscn")

func _on_toggle_orientation() -> void:
	var next := 1 if GameSettings.orientation == 0 else 0  # 0=LANDSCAPE 1=PORTRAIT
	GameSettings.set_orientation(next)

func _refresh_orientation_label() -> void:
	var label := "Portrait" if GameSettings.orientation == 1 else "Paysage"
	_orientation_btn.text = "Orientation : %s" % label
