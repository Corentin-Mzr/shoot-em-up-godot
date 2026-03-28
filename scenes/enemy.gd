extends Area2D

enum EnemyType
{
	Small = 0,
	Medium = 1,
	Large = 2,
	Mega = 3
}

const ENEMY_DATA := {
	EnemyType.Small: {
		"hp": 8,
		"speed": 100,
		"collision_radius": 13,
		"frame_size": Vector2(16, 16),
		"ship_sprite": "res://sprites/enemies/enemy-1.png",
		"exhaust_sprite": "res://sprites/enemies/exhaust-1.png",
		"exhaust_offset": Vector2(-10, 0),
		"bullet_sprite": "res://sprites/enemies/bullet-1.png",
		"marker_count": 1,
		"marker_offset": [Vector2(20, 0)],
		"shoot_duration_in_s": 0.3,
		"shoot_cd_between_bullets_in_s": 0.1,
		"shoot_cd_between_salvo_in_s": 1.0,
		"score_on_death": 200,
	},
	EnemyType.Medium: {
		"hp": 15,
		"speed": 80,
		"collision_radius": 16,
		"frame_size": Vector2(16, 14),
		"ship_sprite": "res://sprites/enemies/enemy-2.png",
		"exhaust_sprite": "res://sprites/enemies/exhaust-2.png",
		"exhaust_offset": Vector2(-10, 0),
		"bullet_sprite": "res://sprites/enemies/bullet-2.png",
		"marker_count": 1,
		"marker_offset": [Vector2(20, 0)],
		"shoot_duration_in_s": 1.0,
		"shoot_cd_between_bullets_in_s": 0.2,
		"shoot_cd_between_salvo_in_s": 2.5,
		"score_on_death": 400,
	},
	EnemyType.Large: {
		"hp": 25,
		"speed": 50,
		"collision_radius": 19,
		"frame_size": Vector2(16, 14),
		"ship_sprite": "res://sprites/enemies/enemy-3.png",
		"exhaust_sprite": "res://sprites/enemies/exhaust-3.png",
		"exhaust_offset": Vector2(-20, 0),
		"bullet_sprite": "res://sprites/enemies/bullet-3.png",
		"marker_count": 2,
		"marker_offset": [Vector2(20, 5), Vector2(20, -5)],
		"shoot_duration_in_s": 2.0,
		"shoot_cd_between_bullets_in_s": 0.25,
		"shoot_cd_between_salvo_in_s": 3.0,
		"score_on_death": 800,
	},
	EnemyType.Mega: {
		"hp": 50,
		"speed": 30,
		"collision_radius": 27,
		"frame_size": Vector2(16, 16),
		"ship_sprite": "res://sprites/enemies/enemy-4.png",
		"exhaust_sprite": "res://sprites/enemies/exhaust-4.png",
		"exhaust_offset": Vector2(-25, 0),
		"bullet_sprite": "res://sprites/enemies/bullet-4.png",
		"marker_count": 1,
		"marker_offset": [Vector2(20, 0)],
		"shoot_duration_in_s": 3.0,
		"shoot_cd_between_bullets_in_s": 0.5,
		"shoot_cd_between_salvo_in_s": 3.0,
		"score_on_death": 1600,
	}
}

@export var flickering_duration: float = 0.02

var screen_size: Vector2
var enemy_type: EnemyType
var health: int
var speed: float
var moving_direction: Vector2
var init_target_pos: Vector2
var reach_init_target := false
var can_move := true
var player: Node2D = null
var can_shoot := false
var start_shoot := false
var score_given: int

@onready var ship_sprite := $ShipSprite2D
@onready var exhaust_sprite := $ExhaustAnimatedSprite2D
@onready var bullet_markers := $BulletMarkers
@onready var shoot_duration := $ShootDurationTimer
@onready var shoot_cd_between_bullets := $ShootCooldownBetweenBulletsTimer
@onready var shoot_cd_between_salvo := $ShootCooldownBetweenSalvoTimer

signal destruction(pos: Vector2, score: int)
signal collision
signal shoot(src: Vector2, dst: Vector2, sprite: String)

func int_to_enemy_type(value: int) -> EnemyType:
	if value >= 0 and value < EnemyType.size():
		return value as EnemyType
	return EnemyType.Small
	
func set_enemy_sprite() -> void:
	const FPS := 12.0
	const FRAME_COUNT := 4
	var data: Dictionary = ENEMY_DATA[enemy_type]
	ship_sprite.texture = load(data["ship_sprite"])
	
	var sprite_frames := SpriteFrames.new()
	sprite_frames.set_animation_loop("default", true)
	sprite_frames.set_animation_speed("default", FPS)
	
	var exhaust_texture := load(data["exhaust_sprite"])
	var fw: float = data["frame_size"].x
	var fh: float = data["frame_size"].y
	
	for i: int in range(FRAME_COUNT):
		var atlas := AtlasTexture.new()
		atlas.atlas = exhaust_texture
		atlas.region = Rect2(i * fw, 0, fw, fh)
		sprite_frames.add_frame("default", atlas)
	
	exhaust_sprite.sprite_frames = sprite_frames
	exhaust_sprite.position = data["exhaust_offset"]
	exhaust_sprite.play("default")
	
func set_enemy_data() -> void:
	var data: Dictionary = ENEMY_DATA[enemy_type]
	var collision_shape := $CollisionShape2D
	collision_shape.shape.radius = data["collision_radius"]
	health = data["hp"]
	speed = data["speed"]
	score_given = data["score_on_death"]
	
	# Markers
	for i: int in data["marker_count"]:
		var marker := Marker2D.new()
		marker.position = data["marker_offset"][i]
		bullet_markers.add_child(marker)
		
	# Shoot type
	shoot_duration.wait_time = data["shoot_duration_in_s"]
	shoot_cd_between_bullets.wait_time = data["shoot_cd_between_bullets_in_s"]
	shoot_cd_between_salvo.wait_time = data["shoot_cd_between_salvo_in_s"]

func _ready() -> void:
	screen_size = get_viewport_rect().size
	var rng := RandomNumberGenerator.new()
	
	# Texture and data
	var enemy_index := rng.randi_range(0, 3)
	enemy_type = int_to_enemy_type(enemy_index)
	set_enemy_sprite()
	set_enemy_data()
			
	# Spawn position and velocity
	var random_x := rng.randf_range(0.0, screen_size.x)
	var random_y := rng.randf_range(-150.0, -50.0)
	
	var random_target_x := rng.randf_range(0.0, screen_size.x)
	var random_target_y := rng.randf_range(0.0, 0.5 * screen_size.y)
	
	position = Vector2(random_x, random_y)
	init_target_pos = Vector2(random_target_x, random_target_y)


func _process(delta: float) -> void:
	# First reach a random target position
	if not reach_init_target:
		moving_direction = (init_target_pos - position).normalized()
	else:
		position = position.clamp(Vector2.ZERO, screen_size)
		
	# Then move in a random direction for a bit
	if position.distance_squared_to(init_target_pos) <= 50.0 and not reach_init_target:
		moving_direction = random_direction()
		reach_init_target = true
		start_shoot = true
		can_move = true
		$MoveTimer.start()
	
	# Stop moving for some time
	if not can_move:
		moving_direction = Vector2.ZERO
		
	position += speed * moving_direction * delta
	
	if player:
		look_at(player.global_position)
	
	if start_shoot:
		$ShootDurationTimer.start()
		start_shoot = false
		can_shoot = true
		
	if can_shoot:
		can_shoot = false
		var bullet_sprite_path: String = ENEMY_DATA[enemy_type]["bullet_sprite"]
		for marker in bullet_markers.get_children():
			if marker is Marker2D and player.health > 0:
				shoot.emit(marker.global_position, player.global_position, bullet_sprite_path)
		$ShootCooldownBetweenBulletsTimer.start()

func random_direction() -> Vector2:
	var rng := RandomNumberGenerator.new()
	var x := rng.randf_range(0.2 * screen_size.x, 0.8 * screen_size.x)
	var y := rng.randf_range(0.1 * screen_size.y, 0.5 * screen_size.y)
	return (Vector2(x, y) - position).normalized()

func _on_move_timer_timeout() -> void:
	can_move = false
	$IdleTimer.start()

func _on_idle_timer_timeout() -> void:
	moving_direction = random_direction()
	can_move = true
	$MoveTimer.start()

func _on_area_entered(area: Area2D) -> void:
	health -= 1
	area.queue_free()
	
	if health <= 0:
		destruction.emit(global_position, score_given)
		queue_free()
	else:
		var tween := create_tween()
		tween.tween_property(ship_sprite, "modulate:a", 0.0, flickering_duration)
		tween.tween_property(ship_sprite, "modulate:a", 1.0, flickering_duration)
		tween.tween_property(exhaust_sprite, "modulate:a", 0.0, flickering_duration)
		tween.tween_property(exhaust_sprite, "modulate:a", 1.0, flickering_duration)
		await tween.finished

func _on_body_entered(_body: Node2D) -> void:
	collision.emit()

func _on_shoot_duration_timer_timeout() -> void:
	can_shoot = false
	$ShootCooldownBetweenBulletsTimer.stop()
	$ShootCooldownBetweenSalvoTimer.start()

func _on_shoot_cooldown_between_bullets_timer_timeout() -> void:
	can_shoot = true

func _on_shoot_cooldown_between_salvo_timer_timeout() -> void:
	start_shoot = true
