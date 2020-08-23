extends Node2D
class_name Gun

export(PackedScene) var bullet

export (float) var fire_rate = 4.0; # bullets per second
var _last_fired : float = 0.0

func _physics_process(delta):
	_last_fired += delta
		
# interface
func shoot() -> Node2D:	
	_last_fired = 0.0
	return null

func can_shoot() -> bool:
	return _last_fired >= 1 / fire_rate
