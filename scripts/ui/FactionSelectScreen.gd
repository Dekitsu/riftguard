## Faction selection screen — fully procedural, no scene node dependencies.
class_name FactionSelectScreen
extends Control

signal faction_selected(faction: TowerData.Faction)

var _selected: TowerData.Faction = TowerData.Faction.SOLARIENS
var _cards_container: HBoxContainer
var _detail_name: Label
var _detail_level: Label
var _detail_passives: VBoxContainer

func _ready() -> void:
	_build_layout()
	_build_cards()
	_show_detail(_selected)

func _build_layout() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 20)
	root.offset_left = 80; root.offset_top = 60
	root.offset_right = -80; root.offset_bottom = -40
	add_child(root)

	var title := Label.new()
	title.text = "Choisissez votre faction"
	title.add_theme_font_size_override("font_size", 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	_cards_container = HBoxContainer.new()
	_cards_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cards_container.add_theme_constant_override("separation", 32)
	root.add_child(_cards_container)

	var detail_panel := PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(0, 260)
	root.add_child(detail_panel)

	var detail_vbox := VBoxContainer.new()
	detail_panel.add_child(detail_vbox)

	_detail_name = Label.new()
	_detail_name.add_theme_font_size_override("font_size", 28)
	_detail_name.text = "—"
	detail_vbox.add_child(_detail_name)

	_detail_level = Label.new()
	_detail_level.text = "Niveau 1 / 20"
	detail_vbox.add_child(_detail_level)

	var passives_title := Label.new()
	passives_title.text = "Passifs :"
	detail_vbox.add_child(passives_title)

	_detail_passives = VBoxContainer.new()
	detail_vbox.add_child(_detail_passives)

func _build_cards() -> void:
	for f in TowerData.Faction.values():
		_cards_container.add_child(_make_card(f))

func _make_card(f: TowerData.Faction) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = TowerData.Faction.keys()[f]
	name_lbl.add_theme_font_size_override("font_size", 22)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)

	var level: int = SaveData.get_faction_level(f)
	var xp: int = SaveData.get_faction_xp(f)

	var level_lbl := Label.new()
	level_lbl.text = "Nv. %d" % level
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(level_lbl)

	var xp_bar := ProgressBar.new()
	xp_bar.min_value = FactionProgression.xp_for_level(level)
	xp_bar.max_value = FactionProgression.xp_for_level(level + 1) if level < FactionProgression.MAX_LEVEL else 1
	xp_bar.value = xp
	xp_bar.show_percentage = false
	xp_bar.custom_minimum_size = Vector2(0, 12)
	vbox.add_child(xp_bar)

	var btn := Button.new()
	btn.text = "Jouer"
	btn.size_flags_vertical = Control.SIZE_SHRINK_END
	var captured_f := f
	btn.pressed.connect(func(): _on_faction_chosen(captured_f))
	vbox.add_child(btn)

	return panel

func _on_faction_chosen(f: TowerData.Faction) -> void:
	_selected = f
	_show_detail(f)
	faction_selected.emit(f)
	ProjectSettings.set_setting("riftguard/selected_faction", int(f))
	get_tree().change_scene_to_file("res://scenes/game/GameScene.tscn")

func _show_detail(f: TowerData.Faction) -> void:
	_detail_name.text = TowerData.Faction.keys()[f]
	var level: int = SaveData.get_faction_level(f)
	_detail_level.text = "Niveau %d / %d" % [level, FactionProgression.MAX_LEVEL]

	for child in _detail_passives.get_children():
		child.queue_free()

	for p in FactionPassive.all_for_faction(f):
		var row := Label.new()
		var unlocked := level >= p.unlock_level
		row.text = "%s Nv.%d — %s" % ["✓" if unlocked else "✗", p.unlock_level, p.description]
		row.modulate.a = 1.0 if unlocked else 0.4
		_detail_passives.add_child(row)
