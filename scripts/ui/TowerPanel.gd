## Panel shown when player taps a tower slot: place, upgrade, or sell.
class_name TowerPanel
extends CanvasLayer

signal place_requested(slot: TowerSlot, tower_data: TowerData)
signal upgrade_requested(slot: TowerSlot)
signal sell_requested(slot: TowerSlot)

@onready var _title: Label = %TitleLabel
@onready var _place_btn: Button = %PlaceBtn
@onready var _upgrade_btn: Button = %UpgradeBtn
@onready var _sell_btn: Button = %SellBtn
@onready var _close_btn: Button = %CloseBtn
@onready var _stats_label: Label = %StatsLabel

var _slot: TowerSlot = null
var _pending_data: TowerData = null
var _run: RunState = null

func _ready() -> void:
	_place_btn.pressed.connect(_on_place)
	_upgrade_btn.pressed.connect(_on_upgrade)
	_sell_btn.pressed.connect(_on_sell)
	_close_btn.pressed.connect(hide)
	hide()

func show_empty(slot: TowerSlot, choices: Array[TowerData], run: RunState) -> void:
	_slot = slot
	_run = run
	_pending_data = choices[0] if not choices.is_empty() else null
	_title.text = "Emplacement libre"
	_place_btn.show()
	_upgrade_btn.hide()
	_sell_btn.hide()
	if _pending_data != null:
		_place_btn.text = "Placer — %s (%d ⚙)" % [_pending_data.display_name, _pending_data.cost]
		_place_btn.disabled = run.gold < _pending_data.cost
		_stats_label.text = _format_stats(_pending_data, 1)
	else:
		_place_btn.disabled = true
	show()

func show_tower(slot: TowerSlot, run: RunState, invested: int) -> void:
	_slot = slot
	_run = run
	var t: Tower = slot.tower
	_title.text = "%s  Nv.%d" % [t.data.display_name, t.level]
	_place_btn.hide()
	_upgrade_btn.show()
	_sell_btn.show()
	var upgrade_cost: int = t.upgrade_cost()
	var can_upgrade: bool = t.level < t.data.max_level and run.gold >= upgrade_cost
	_upgrade_btn.text = "Améliorer — %d ⚙" % upgrade_cost if t.level < t.data.max_level else "Niveau max"
	_upgrade_btn.disabled = not can_upgrade
	_sell_btn.text = "Vendre — %d ⚙" % t.sell_value(invested)
	_stats_label.text = _format_stats(t.data, t.level)
	show()

func _format_stats(td: TowerData, level: int) -> String:
	var s: Dictionary = td.stats_at_level(level)
	return "Dégâts: %d  |  Portée: %.0f  |  Cadence: %.1f/s" % [s.damage, s.range, s.fire_rate]

func _on_place() -> void:
	if _pending_data == null or _slot == null:
		return
	place_requested.emit(_slot, _pending_data)
	hide()

func _on_upgrade() -> void:
	if _slot == null:
		return
	upgrade_requested.emit(_slot)
	hide()

func _on_sell() -> void:
	if _slot == null:
		return
	sell_requested.emit(_slot)
	hide()
