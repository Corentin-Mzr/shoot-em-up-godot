extends Node2D

const BONUS_TO_ANIM := {
	0: "health",
	1: "shield",
	2: "laser",
	3: "multishot",
	4: "score_multiplier",
} 

signal picked(type: int)

var screen_size: Vector2
var bonus_type: int
@export var speed := 100

func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	# Random bonus type
	var rng := RandomNumberGenerator.new()
	bonus_type = rng.randi_range(0, 4)
	
	# Show sprite based on bonus type
	$AnimatedSprite2D.play(BONUS_TO_ANIM[bonus_type])

func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y >= 1.2 * screen_size.y:
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	$Area2D.call_deferred("set_disabled", true)
	picked.emit(bonus_type)
	hide()
	$BonusPickedSound.play()
	await get_tree().create_timer(1.0).timeout
	queue_free()
