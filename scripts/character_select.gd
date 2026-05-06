extends Control

var selected_otter: int = 0

func _ready() -> void:
	selected_otter = GameState.selected_otter
	_update_preview()

func _on_prev_pressed() -> void:
	selected_otter = (selected_otter + 7) % 8
	_update_preview()

func _on_next_pressed() -> void:
	selected_otter = (selected_otter + 1) % 8
	_update_preview()

func _on_play_pressed() -> void:
	GameState.selected_otter = selected_otter
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _update_preview() -> void:
	$VBoxContainer/OtterName.text = "Vydra %d / 8" % (selected_otter + 1)
	$VBoxContainer/ColorPreview.color = GameState.get_selected_color()
	$VBoxContainer/BestScore.text = "Najlepšie skóre: %d" % GameState.best_score
