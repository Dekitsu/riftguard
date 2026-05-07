## Persistent settings — orientation, audio, graphics.
## Autoload singleton — no class_name to avoid conflict with autoload name.
extends Node

signal orientation_changed(new_orientation: Orientation)

enum Orientation { LANDSCAPE, PORTRAIT }

const SAVE_PATH := "user://settings.cfg"

var orientation: Orientation = Orientation.LANDSCAPE
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0

func _ready() -> void:
	load_settings()

func set_orientation(o: Orientation) -> void:
	if orientation == o:
		return
	orientation = o
	_apply_orientation()
	orientation_changed.emit(o)
	save_settings()

func _apply_orientation() -> void:
	match orientation:
		Orientation.LANDSCAPE:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		Orientation.PORTRAIT:
			DisplayServer.window_set_size(Vector2i(1080, 1920))

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("display", "orientation", orientation)
	cfg.set_value("audio", "master", master_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("audio", "music", music_volume)
	cfg.save(SAVE_PATH)

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	orientation = cfg.get_value("display", "orientation", Orientation.LANDSCAPE)
	master_volume = cfg.get_value("audio", "master", 1.0)
	sfx_volume = cfg.get_value("audio", "sfx", 1.0)
	music_volume = cfg.get_value("audio", "music", 1.0)
	_apply_orientation()
