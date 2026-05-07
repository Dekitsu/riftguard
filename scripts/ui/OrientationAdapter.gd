## Listens to GameSettings.orientation_changed and repositions UI nodes.
## Attach to any scene that needs to adapt to orientation changes.
class_name OrientationAdapter
extends Node

## Pairs of (landscape_node_path, portrait_node_path) for layout swaps.
## In practice: landscape root and portrait root are separate Control subtrees.
@export var landscape_root: NodePath
@export var portrait_root: NodePath

func _ready() -> void:
	GameSettings.orientation_changed.connect(_on_orientation_changed)
	_on_orientation_changed(GameSettings.orientation)

func _on_orientation_changed(o: int) -> void:
	var ls := get_node_or_null(landscape_root)
	var ps := get_node_or_null(portrait_root)
	if ls != null:
		ls.visible = (o == 0)  # 0 = LANDSCAPE
	if ps != null:
		ps.visible = (o == 1)  # 1 = PORTRAIT
