## Main menu — fully procedural, no scene node dependencies.
class_name MainMenu
extends Control

var _orientation_btn: Button

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.10, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.add_theme_constant_override("separation", 24)
	center.offset_left = -200; center.offset_top = -180
	center.offset_right = 200; center.offset_bottom = 180
	add_child(center)

	var title := Label.new()
	title.text = "RIFTGUARD"
	title.add_theme_font_size_override("font_size", 64)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(title)

	var play_btn := _make_btn("Jouer", 400, 60, 24)
	play_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/FactionSelect.tscn"))
	center.add_child(play_btn)

	_orientation_btn = _make_btn("", 400, 60, 20)
	_orientation_btn.pressed.connect(_on_toggle_orientation)
	center.add_child(_orientation_btn)
	_refresh_orientation_label()
	GameSettings.orientation_changed.connect(func(_o): _refresh_orientation_label())

	var quit_btn := _make_btn("Quitter", 400, 60, 20)
	quit_btn.pressed.connect(get_tree().quit)
	center.add_child(quit_btn)

func _make_btn(label: String, w: float, h: float, font_size: int) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(w, h)
	btn.add_theme_font_size_override("font_size", font_size)
	return btn

func _on_toggle_orientation() -> void:
	var next := 1 if GameSettings.orientation == 0 else 0
	GameSettings.set_orientation(next)

func _refresh_orientation_label() -> void:
	var label := "Portrait" if GameSettings.orientation == 1 else "Paysage"
	_orientation_btn.text = "Orientation : %s" % label
