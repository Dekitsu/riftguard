## Faction selection screen shown before each run. Displays level and passives.
class_name FactionSelectScreen
extends Control

signal faction_selected(faction: TowerData.Faction)

@onready var _cards: HBoxContainer = %FactionCards
@onready var _detail_name: Label = %DetailName
@onready var _detail_level: Label = %DetailLevel
@onready var _detail_passives: VBoxContainer = %DetailPassives

var _selected: TowerData.Faction = TowerData.Faction.SOLARIENS

func _ready() -> void:
	_build_cards()
	_show_detail(_selected)

func _build_cards() -> void:
	for child in _cards.get_children():
		child.queue_free()
	for f in TowerData.Faction.values():
		var card := _make_card(f)
		_cards.add_child(card)

func _make_card(f: TowerData.Faction) -> PanelContainer:
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = TowerData.Faction.keys()[f]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)

	var level := SaveData.get_faction_level(f)
	var xp := SaveData.get_faction_xp(f)
	var xp_next := FactionProgression.xp_for_level(level + 1)

	var level_lbl := Label.new()
	level_lbl.text = "Nv. %d" % level
	vbox.add_child(level_lbl)

	var xp_bar := ProgressBar.new()
	xp_bar.min_value = FactionProgression.xp_for_level(level)
	xp_bar.max_value = xp_next if level < FactionProgression.MAX_LEVEL else 1
	xp_bar.value = xp
	xp_bar.show_percentage = false
	xp_bar.custom_minimum_size = Vector2(160, 10)
	vbox.add_child(xp_bar)

	var btn := Button.new()
	btn.text = "Jouer"
	btn.pressed.connect(func():
		_selected = f
		_show_detail(f)
		faction_selected.emit(f)
	)
	vbox.add_child(btn)
	return panel

func _show_detail(f: TowerData.Faction) -> void:
	_detail_name.text = TowerData.Faction.keys()[f]
	var level := SaveData.get_faction_level(f)
	_detail_level.text = "Niveau %d / %d" % [level, FactionProgression.MAX_LEVEL]

	for child in _detail_passives.get_children():
		child.queue_free()
	var passives := FactionPassive.all_for_faction(f)
	for p in passives:
		var row := Label.new()
		var unlocked := level >= p.unlock_level
		row.text = "%s Nv.%d — %s" % ["✓" if unlocked else "✗", p.unlock_level, p.description]
		row.modulate.a = 1.0 if unlocked else 0.4
		_detail_passives.add_child(row)
