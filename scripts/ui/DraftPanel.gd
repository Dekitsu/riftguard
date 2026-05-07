## Overlay shown between waves: 3 tower choices to draft.
class_name DraftPanel
extends CanvasLayer

signal choice_made(index: int)

@onready var _container: HBoxContainer = %ChoicesContainer
@onready var _title: Label = %TitleLabel

func _ready() -> void:
	hide()

func show_draft(choices: Array[TowerData]) -> void:
	for child in _container.get_children():
		child.queue_free()
	_title.text = "Choisissez une tour à ajouter"
	for i in choices.size():
		var btn: PanelContainer = _make_choice_card(choices[i], i)
		_container.add_child(btn)
	show()

func _make_choice_card(td: TowerData, index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = td.display_name
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = td.description
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_lbl.custom_minimum_size = Vector2(200, 0)
	vbox.add_child(desc_lbl)

	var stats: Dictionary = td.stats_at_level(1)
	var stats_lbl := Label.new()
	stats_lbl.text = "Dégâts: %d  Portée: %.0f\nCadence: %.1f/s" % [stats.damage, stats.range, stats.fire_rate]
	vbox.add_child(stats_lbl)

	var btn := Button.new()
	btn.text = "Choisir"
	btn.pressed.connect(func(): choice_made.emit(index); hide())
	vbox.add_child(btn)

	return panel
