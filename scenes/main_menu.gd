extends Control

var level_scene: PackedScene = load("res://scenes/level.tscn")
var options_scene: PackedScene = load("res://scenes/options_menu.tscn")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(level_scene)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_packed(options_scene)
