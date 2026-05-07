## Game map: holds waypoints path and tower slots.
## Attach to the root Node2D of a map scene.
class_name MapScene
extends Node2D

@export var waypoint_path: NodePath
@export var slot_container_path: NodePath

var waypoints: Array[Vector2] = []
var slots: Array[TowerSlot] = []

func _ready() -> void:
	_collect_waypoints()
	_collect_slots()

func _collect_waypoints() -> void:
	var container: Node = get_node_or_null(waypoint_path)
	if container == null:
		return
	for child in container.get_children():
		if child is Node2D:
			waypoints.append(child.global_position)

func _collect_slots() -> void:
	var container: Node = get_node_or_null(slot_container_path)
	if container == null:
		return
	var idx: int = 0
	for child in container.get_children():
		if child is TowerSlot:
			child.slot_index = idx
			slots.append(child)
			idx += 1
