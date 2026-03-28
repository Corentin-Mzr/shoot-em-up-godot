extends CharacterBody2D

@export_category("Player settings")
@export var speed: float = 200.0
@export var speed_multiplier: float = 1.0
@export var max_health: int = 4
@export var health: int = 4
@export var weapon_level: int = 1

const MAX_WEAPON_LEVEL: int = 5
var bullet_directions: Array[Vector2] = []

const UP_DIRECTION := Vector2(0.0, -1.0)
const DIAG_LEFT_DIRECTION := Vector2(-0.707, -0.707)
const DIAG_RIGHT_DIRECTION := Vector2(0.707, -0.707)
const BULLET_DIST_TO_CENTER := 10.0
const ANGLE_BETWEEN_BULLETS := 5.0

var screen_size: Vector2
var can_shoot := true
var can_dash := true
var can_take_damage := true
var is_dead := false
var shield_enable := false

signal shoot(pos: Vector2, dir: Vector2)
signal death

func _ready() -> void:
	$ShieldSprite2D.hide()
	screen_size = get_viewport_rect().size
	position = Vector2(0.5 * screen_size.x, 0.9 * screen_size.y)
	get_tree().call_group("level_ui", "set_health", health, max_health)
	create_bullet_markers_and_directions()

func _process(_delta: float) -> void:
	if is_dead:
		return
	
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if velocity.length() > 0.0:
		velocity = velocity.normalized() * speed * speed_multiplier
	
	move_and_slide()
	
	var i := 0
	if Input.is_action_pressed("shoot") and can_shoot:
		for marker in $BulletMarkers.get_children():
			if marker is Marker2D:
				shoot.emit(marker.global_position, bullet_directions[i])
				i += 1
			can_shoot = false
			$ShootCooldown.start()
		
	if Input.is_action_pressed("dash") and can_dash:
		speed_multiplier = 2.0
		can_dash = false
		can_take_damage = false
		$DashCooldown.start()
		$DashDuration.start()
		spawn_ghost()

func _on_shoot_cooldown_timeout() -> void:
	can_shoot = true

func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func _on_dash_duration_timeout() -> void:
	speed_multiplier = 1.0
	can_take_damage = true
	
func take_damage() -> void:
	if shield_enable:
		return
	
	if can_take_damage:
		if health > 0:
			$HurtSound.play()
		health -= 1
		can_take_damage = false
		$ImmunityCooldown.start()
		get_tree().call_group("level_ui", "set_health", health, max_health)
	
	if health <= 0:
		is_dead = true
		death.emit()
		collision_layer = 0
		collision_mask = 0
		
func _on_immunity_cooldown_timeout() -> void:
	can_take_damage = true
	
func spawn_ghost() -> void:
	if speed_multiplier != 1.0:
		var ghost := Sprite2D.new()
		ghost.texture = $ShipSprite2D.texture
		ghost.frame = $ShipSprite2D.frame
		ghost.global_position = global_position
		ghost.modulate = Color(0.5, 0.8, 1.0, 0.7)
		ghost.scale = scale
		get_parent().add_child(ghost)
		
		var tween := create_tween()
		tween.tween_property(ghost, "modulate:a", 0.0, 1.0)
		tween.tween_callback(ghost.queue_free)

func heal() -> void:
	health = min(health + 1, max_health)
	get_tree().call_group("level_ui", "set_health", health, max_health)

func shield() -> void:
	shield_enable = true
	$ShieldSprite2D.show()
	$ShieldDuration.start()
	
func upgrade_weapon() -> void:
	if weapon_level < MAX_WEAPON_LEVEL:
		weapon_level += 1
		create_bullet_markers_and_directions()

func _on_shield_duration_timeout() -> void:
	shield_enable = false
	$ShieldSprite2D.hide()
	
func create_marker_and_direction(dir: Vector2, offset: Vector2 = Vector2.ZERO) -> void:
	var marker := Marker2D.new()
	marker.position = $ShipSprite2D.position
	marker.position += BULLET_DIST_TO_CENTER * dir.normalized() + offset
	$BulletMarkers.add_child(marker)
	bullet_directions.append(dir)
	
func create_bullet_markers_and_directions() -> void:
	bullet_directions.clear()
	for marker in $BulletMarkers.get_children():
		if marker is Marker2D:
			$BulletMarkers.remove_child(marker)
			
	match weapon_level:
		1:
			create_marker_and_direction_center_single()
		2:
			create_marker_and_direction_center_double()
		3:
			create_marker_and_direction_center_double()
			create_marker_and_direction_diagonal_single()
		4:
			create_marker_and_direction_center_double()
			create_marker_and_direction_diagonal_double()
		5:
			create_marker_and_direction_semi_circle()
			
func create_marker_and_direction_center_single() -> void:
	create_marker_and_direction(UP_DIRECTION)
	
func create_marker_and_direction_center_double() -> void:
	create_marker_and_direction(UP_DIRECTION, Vector2(-10.0, 0.0))
	create_marker_and_direction(UP_DIRECTION, Vector2(10.0, 0.0))

func create_marker_and_direction_diagonal_single() -> void:
	create_marker_and_direction(DIAG_LEFT_DIRECTION, Vector2i(-20.0, 0.0))
	create_marker_and_direction(DIAG_RIGHT_DIRECTION, Vector2i(20.0, 0.0))

func create_marker_and_direction_diagonal_double() -> void:
	create_marker_and_direction(DIAG_LEFT_DIRECTION, Vector2(-20.0, -5.0))
	create_marker_and_direction(DIAG_LEFT_DIRECTION, Vector2(-25.0, 5.0))
	create_marker_and_direction(DIAG_RIGHT_DIRECTION, Vector2(20.0, -5.0))
	create_marker_and_direction(DIAG_RIGHT_DIRECTION, Vector2(25.0, 5.0))
	
func create_marker_and_direction_semi_circle() -> void:
	const N_BULLETS := 18
	const D_TH := PI / max(1, (N_BULLETS - 1))
	const DIST_TO_CENTER := 10.0
	for i in N_BULLETS:
		var th := i * D_TH
		var direction := Vector2(cos(th), -sin(th))
		var offset := DIST_TO_CENTER * direction 
		create_marker_and_direction(direction, offset)
	
	
			
