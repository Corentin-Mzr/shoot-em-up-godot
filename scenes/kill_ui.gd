extends HBoxContainer

@onready var texture := $TextureRect
@onready var label := $Label

func set_killed(value: int) -> void:
	label.text = str(value).pad_zeros(3)
