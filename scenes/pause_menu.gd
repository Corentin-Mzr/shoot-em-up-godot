extends CanvasLayer

var main_menu: PackedScene = load("res://scenes/main_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu)

func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false
