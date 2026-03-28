extends HBoxContainer

@onready var timer := $Timer

var time_elapsed: int = 0

func format_time(seconds: int) -> String:
	@warning_ignore("integer_division")
	var minutes := seconds / 60
	var secs := seconds % 60
	return "%02d:%02d" % [minutes, secs]

func _on_timer_timeout() -> void:
	time_elapsed += 1
	$Label.text = format_time(time_elapsed)
