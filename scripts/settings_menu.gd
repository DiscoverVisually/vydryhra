extends Control

func _ready() -> void:
	$VBox/Volume.value = SaveManager.master_volume
	$VBox/Fullscreen.button_pressed = SaveManager.fullscreen
	$VBox/Debug.button_pressed = SaveManager.debug_enabled

func _on_back_pressed() -> void:
	SaveManager.save_data()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_volume_value_changed(value: float) -> void:
	SaveManager.master_volume = value

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	SaveManager.fullscreen = toggled_on

func _on_debug_toggled(toggled_on: bool) -> void:
	SaveManager.debug_enabled = toggled_on
