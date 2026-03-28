extends TextureRect

static var health_full_img := load("res://sprites/ui/heart-full.png")
static var health_empty_img := load("res://sprites/ui/heart-empty.png")

@onready var score_label := $ScoreLabel
var displayed_score := 0
var tween: Tween

func _ready() -> void:
	set_score(0)

func set_health(health: int, max_health: int) -> void:
	health = max(0, health)
	
	for child in $Health.get_children():
		child.queue_free()
	
	for i in health:
		var text_rect := TextureRect.new()
		text_rect.texture = health_full_img
		text_rect.stretch_mode = TextureRect.STRETCH_KEEP
		$Health.add_child(text_rect)
		
	for i: int in max(0, max_health - health):
		var text_rect := TextureRect.new()
		text_rect.texture = health_empty_img
		text_rect.stretch_mode = TextureRect.STRETCH_KEEP
		$Health.add_child(text_rect)
		
func set_score(value: int) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_method(
			func(v: int) -> void: 
				displayed_score = v
				score_label.text = str(v).pad_zeros(8),
			displayed_score,
			value,
			clamp((value - displayed_score) * 0.01, 0.3, 2.0)
		)
