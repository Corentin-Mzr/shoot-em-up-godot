extends Area2D

@export var speed: float = 500.0
@export var scale_duration: float = 0.15
@export var direction := Vector2(0.0, -1.0)

@onready var sprite := $Sprite2D
@onready var collision_shape := $CollisionShape2D

var bullet_texture: Texture2D

func _ready() -> void:
	if bullet_texture:
		sprite.texture = bullet_texture
	
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), scale_duration).from(Vector2.ZERO)
	if direction.length_squared() != 0.0:
		direction = direction.normalized()
	sprite.rotate(direction.angle())

func _process(delta: float) -> void:
	position += speed * delta * direction
	
	if position.y <= 0.0 or position.y >= get_viewport_rect().size.y:
		queue_free()
