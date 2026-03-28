extends Node2D

var screen_size: Vector2
var speed: float
var rotation_direction: float
var linear_direction: Vector2

@export var min_speed: float = 50.0
@export var max_speed: float = 200.0

signal collision
signal destruction(pos: Vector2)

func _ready() -> void:
	screen_size = get_viewport_rect().size
	var rng := RandomNumberGenerator.new()
	
	# Texture
	var asteroid_index := rng.randi_range(1, 6)
	var path: String = "res://sprites/asteroids/asteroid-" + str(asteroid_index) + ".png"
	$Sprite2D.texture = load(path)
	
	if asteroid_index <= 2:
		$CollisionShape2D.shape.radius = 18
	if asteroid_index <= 4:
		$CollisionShape2D.shape.radius = 13
	if asteroid_index <= 6:
		$CollisionShape2D.shape.radius = 8
	
	# Spawn position and velocity
	var random_x := rng.randf_range(0.0, screen_size.x)
	var random_y := rng.randf_range(-150.0, -50.0)
	var random_dir_rot := rng.randi_range(0, 1)
	var random_dir_x := rng.randf_range(-1.0, 1.0)
	
	position = Vector2(random_x, random_y)
	speed = rng.randf_range(min_speed, max_speed)
	linear_direction = Vector2(random_dir_x, 1.0).normalized()
	
	# Rotation direction (clockwise or anti clockwise)
	if random_dir_rot == 0:
		rotation_direction = 1.0
	else:
		rotation_direction = -1.0

func _process(delta: float) -> void:
	position += linear_direction * speed * delta
	rotation += speed_to_rotation(delta) 
	
	if position.y > 1.2 * screen_size.y:
		queue_free()

func speed_to_rotation(delta: float) -> float:
	return 2.0 * speed * delta / 180.0

func _on_body_entered(_body: Node2D) -> void:
	collision.emit()

func _on_area_entered(area: Area2D) -> void:
	destruction.emit(global_position)
	area.queue_free()
	queue_free()
