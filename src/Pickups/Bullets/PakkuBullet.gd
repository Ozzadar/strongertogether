extends KinematicBody2D

signal killed_enemy

var movement_speed = 500
var direction = Vector2(1,0)

var _alive : float = 0.0

func _physics_process(delta):
	var new_direction =  direction * (movement_speed * delta)
	global_position += new_direction
	global_rotation = new_direction.angle()
	_alive += delta
	
	if _alive > 3.0:
		queue_free()


func _enemy_detected(body):
	if body.has_method('get_destroyed'):
		emit_signal('killed_enemy')
		body.get_destroyed()
		queue_free()
