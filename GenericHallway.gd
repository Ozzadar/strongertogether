extends Node2D

const power_juice_resource = preload("res://src/Pickups/PowerJuice/PowerJuice.tscn")
const death_screen_resource = preload("res://src/Screens/DeathScreen.tscn")
const start_screen_resource = preload("res://src/Screens/StartScreen.tscn")

onready var player = $Player
onready var spawners = $Spawners
onready var r = RandomNumberGenerator.new()

const middle_point : Vector2 = Vector2(960,540)
var _scroll_speed : Vector2 = Vector2(1000,1000)
var _score : int = 0

func _ready():
	player.connect("changed_direction", self, "_changed_direction")
	player.connect("changed_mode", self, "_changed_mode")
	player.connect("bullet_shot", self, "_bullet_shot")
	player.connect("health_changed", self, "_health_changed")
	
	for spawner in spawners.get_children():
		spawner.connect("enemy_spawned", self, "_enemy_spawned")
		
	var new_screen = _show_screen(start_screen_resource)
	new_screen.connect("start", self, '_reset')
	new_screen.connect("quit", self, '_quit')
	
func _enemy_spawned(new_enemy):
	$Enemies.add_child(new_enemy)

func _bullet_shot(new_bullet):
	$Bullets.add_child(new_bullet)
	new_bullet.connect('killed_enemy', self, '_enemy_killed')
	
func _physics_process(delta):
	if r.randi_range(0,1000) > 950:
		_scroll_speed = Vector2(r.randi_range(-1000, 1000), r.randi_range(-1000, 1000))
	_spawn_powerup()

		
		
func _changed_direction(direction : bool):
	pass

func _changed_mode(mode : bool):
		
	if mode:
		for enemy in $Enemies.get_children():
			enemy.get_destroyed()
			_enemy_killed()
	if !mode:
		_changed_direction(player._facing_direction)

func _spawn_powerup():
	if r.randf() > 0.99:
		if r.randf() > 0.65:
			
			var new_juice = power_juice_resource.instance()
			
			# right/left
			if r.randf() >= 0.5:
				var left : bool = r.randf() >= 0.5
				new_juice.position = middle_point + Vector2(-300 if left else 300, r.randi_range(-300,300))
			#up/down
			else:
				var up : bool = r.randf() >= 0.5
				new_juice.position = middle_point + Vector2(r.randi_range(-300,300), -300 if up else 300)
			
			$Juice.add_child(new_juice)
	pass

func _enemy_killed():
	_score += 1
	$ScoreAnimator.play("Pop")
	$CanvasLayer/ScoreLabel.text = str(_score)
	player._total_energy += 10

func _health_changed(new_health_percentage):
	$WorldEnvironment.environment.adjustment_contrast = 1 + (1 - new_health_percentage) * -2
	$WorldEnvironment.environment.adjustment_saturation = 1 + (1 - new_health_percentage) * -2
	
	if new_health_percentage <= 0:
		dead()

func dead():
	var new_screen = _show_screen(death_screen_resource)
	new_screen.connect("retry", self, "_retry")
	new_screen.connect("quit", self, "_quit")
	pass

func _show_screen(resource):
	if $Screen.get_child_count() != 0:
		for child in $Screen.get_children():
			child.queue_free()
	
	var new_screen = resource.instance()
	$Screen.add_child(new_screen)
	return new_screen

func _retry():
	_reset()
	
func _quit():
	get_tree().quit()
	pass

func _reset():
	$WorldEnvironment.environment.adjustment_contrast = 1
	$WorldEnvironment.environment.adjustment_saturation = 1
	
	for spawner in $Spawners.get_children():
		spawner.reset()
	
	for enemy in $Enemies.get_children():
		enemy.queue_free()
		
	for bullet in $Bullets.get_children():
		bullet.queue_free()
	
	for juice in $Juice.get_children():
		juice.queue_free()
		
	_score = 0
	$CanvasLayer/ScoreLabel.text = str(_score)
	
	player._reset()
	
	for screen in $Screen.get_children():
		screen.queue_free()
		
