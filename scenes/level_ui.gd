extends CanvasLayer

func set_health(health: int, max_health: int) -> void:
	$MarginContainer2/ScoreHealthUI.set_health(health, max_health)
	
func stop_clock() -> void:
	$VBoxContainer/MarginContainer/ClockUI.timer.stop()

func set_score(value: int) -> void:
	$MarginContainer2/ScoreHealthUI.set_score(value)
	
func set_killed(value: int) -> void:
	$VBoxContainer/MarginContainer2/KillUI.set_killed(value)
