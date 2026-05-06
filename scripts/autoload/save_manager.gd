extends Node

const SAVE_PATH := "user://save.cfg"

var master_volume: float = 0.8
var fullscreen: bool = false
var debug_enabled: bool = true

func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	master_volume = cfg.get_value("settings", "master_volume", 0.8)
	fullscreen = cfg.get_value("settings", "fullscreen", false)
	debug_enabled = cfg.get_value("settings", "debug_enabled", true)
	GameState.best_score = cfg.get_value("progress", "best_score", 0)
	GameState.selected_otter = cfg.get_value("progress", "selected_otter", 0)

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "master_volume", master_volume)
	cfg.set_value("settings", "fullscreen", fullscreen)
	cfg.set_value("settings", "debug_enabled", debug_enabled)
	cfg.set_value("progress", "best_score", GameState.best_score)
	cfg.set_value("progress", "selected_otter", GameState.selected_otter)
	cfg.save(SAVE_PATH)
