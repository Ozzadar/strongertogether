extends Node2D

signal enemy_spawned

export(PackedScene) var enemy
export(int) var speed = 1

var _direction : int = 0; # down right up left
var _difficulty_scale : int = 90

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	pass

func reset():
	randomize()
	position = Vector2(0, 0)
	_difficulty_scale = 75
	
func _physics_process(delta):
	
	_spawn_enemy()
	if _direction == 0:
		# down
		position += Vector2(0, 100 * delta * speed)
		if position.y >= 1280:
			_direction = 1
	elif _direction == 1:
		# right
		position += Vector2(100 * delta * speed, 0)
		if position.x >= 1920:
			_direction = 2
	elif _direction == 2:
		position += Vector2(0, -100 * delta * speed)
		if position.y <= 0:
			_direction = 3
	elif _direction == 3:
		position += Vector2(-100 * delta * speed, 0)
		if position.x <= 0:
			_direction = 0

func _spawn_enemy():
	if rand_range(0, 100) > 99:
		if rand_range(0, 100) > _difficulty_scale:
			var new_enemy = enemy.instance()
			new_enemy.global_position = global_position
			
			emit_signal("enemy_spawned", new_enemy)


func _bump_difficulty():
	_difficulty_scale = clamp(_difficulty_scale - 3, 0, 100)
