extends Node2D

var asteroid_scene: PackedScene = load("res://scenes/asteroid.tscn")
var bullet_scene: PackedScene = load("res://scenes/bullet.tscn")
var explosion_scene: PackedScene = load("res://scenes/explosion.tscn")
var bonus_scene: PackedScene = load("res://scenes/bonus.tscn")
var enemy_scene: PackedScene = load("res://scenes/enemy.tscn")

var game_over := false
var bonus_spawn_chance := 0.3
var score := 0
var enemy_kills := 0
var score_mult := 1

func increment_score(value: int) -> void:
	score += value

func spawn_bonus(pos: Vector2) -> void:
	var rng := RandomNumberGenerator.new()
	if rng.randf() <= bonus_spawn_chance:
		var bonus := bonus_scene.instantiate()
		bonus.global_position = pos
		bonus.connect("picked", _on_bonus_picked)
		$Bonuses.call_deferred("add_child", bonus)

func _ready() -> void:
	$GameOver.hide()
	$PauseMenu.hide()
	$Player.scale = Vector2(0.75, 0.75)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and game_over:
		get_tree().reload_current_scene()
		game_over = false
	if event.is_action_pressed("pause_game"):
		$PauseMenu.show()
		get_tree().paused = true

func _on_asteroid_timer_timeout() -> void:
	var asteroid := asteroid_scene.instantiate()
	asteroid.connect("collision", _on_asteroid_collision)
	asteroid.connect("destruction", _on_asteroid_destruction)
	$Asteroids.add_child(asteroid)

func _on_asteroid_collision() -> void:
	get_tree().call_group("player", "take_damage")

func _on_player_shoot(pos: Vector2, dir: Vector2) -> void:
	var bullet := bullet_scene.instantiate()
	bullet.position = pos
	bullet.direction = dir
	$PlayerBullets.add_child(bullet)
	

func _on_player_death() -> void:
	$GameOver/CenterContainer/VBoxContainer/ScoreLabel.text = "Score %d" % score
	$Player.hide()
	$GameOver.show()
	game_over = true
	var explosion := explosion_scene.instantiate()
	explosion.global_position = $Player.global_position
	$Explosions.add_child(explosion)
	$UI.stop_clock()
	
func _on_asteroid_destruction(pos: Vector2) -> void:
	var explosion := explosion_scene.instantiate()
	explosion.global_position = pos
	$Explosions.add_child(explosion)
	spawn_bonus(pos)
	increment_score(100 * score_mult)
	get_tree().call_group("level_ui", "set_score", score)

func _on_bonus_picked(type: int) -> void:
	increment_score(100 * score_mult)
	get_tree().call_group("level_ui", "set_score", score)
	
	match type:
		0:
			get_tree().call_group("player", "heal")
		1:
			get_tree().call_group("player", "shield")
		2:
			get_tree().call_group("player", "get_laser_weapon")
		3:
			get_tree().call_group("player", "upgrade_weapon")
		4:
			score_mult = 2
			$ScoreMultTimer.start()

func _on_enemy_timer_timeout() -> void:
	var enemy := enemy_scene.instantiate()
	enemy.player = $Player
	enemy.connect("shoot", _on_enemy_shoot)
	enemy.connect("destruction", _on_enemy_destruction)
	enemy.connect("collision", _on_enemy_collision)
	$Enemies.add_child(enemy)
	
func _on_enemy_destruction(pos: Vector2, value: int) -> void:
	var explosion := explosion_scene.instantiate()
	explosion.global_position = pos
	$Explosions.add_child(explosion)
	spawn_bonus(pos)
	increment_score(value * score_mult)
	enemy_kills += 1
	
	get_tree().call_group("level_ui", "set_score", score)
	get_tree().call_group("level_ui", "set_killed", enemy_kills)

func _on_enemy_collision() -> void:
	get_tree().call_group("player", "take_damage")
	
func _on_enemy_shoot(src: Vector2, dst: Vector2, sprite: String) -> void:
	var bullet := bullet_scene.instantiate()
	bullet.bullet_texture = load(sprite)
	bullet.position = src
	bullet.direction = (dst - src).normalized()
	$EnemyBullets.add_child(bullet)
	
	# After because it would be reset to the player bullets values
	bullet.set_collision_layer_value(4, false)
	bullet.set_collision_layer_value(7, true)
	bullet.set_collision_mask_value(1, true)
	bullet.set_collision_mask_value(2, false)
	bullet.set_collision_mask_value(6, false)
	bullet.connect("body_entered", _on_enemy_bullet_collision)

func _on_enemy_bullet_collision(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
	


func _on_score_mult_timer_timeout() -> void:
	score_mult = 1
