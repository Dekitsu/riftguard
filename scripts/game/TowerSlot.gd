## A placeable slot on the map. Handles placement, upgrade, sell UI trigger.
class_name TowerSlot
extends Node2D

signal slot_tapped(slot: TowerSlot)

var tower: Tower = null
var slot_index: int = 0

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch and event.pressed:
		slot_tapped.emit(self)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		slot_tapped.emit(self)

func is_occupied() -> bool:
	return tower != null

func place(t: Tower) -> void:
	tower = t
	add_child(t)
	t.position = Vector2.ZERO

func clear() -> void:
	if tower != null:
		tower.queue_free()
		tower = null
