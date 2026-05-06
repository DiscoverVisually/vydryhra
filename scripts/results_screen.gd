extends Control

func _ready() -> void:
	$VBox/Title.text = "Koniec kola"
	$VBox/Summary.text = GameState.last_run_summary

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
