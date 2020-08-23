extends KinematicBody2D

var _throb : bool = false
var _throb_time : float = 0.0

var _current_color : Color = Color(0,1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func get_destroyed():
	$Sprite.visible = false
	$PlayerDetector.disconnect("body_entered", self, '_player_detected')
	$PlayerDetector/Collision.set_deferred('disabled', true)
	$CollisionShape2D.set_deferred('disabled', true)
	$Explode.emitting = true
	$AudioStreamPlayer2D.play(0.0)
	$Timer.start()
	pass
	
func _physics_process(delta):
	_move_to_center()
	_throb_color(delta)
	pass

func _move_to_center():
	var direction : Vector2 = Vector2(960,540) - global_position
	direction = direction.normalized()
	
	move_and_collide(direction)
	pass
	
func _throb_color(delta):
	if _throb:
		_throb_time -= delta
		
		_current_color -= Color(0.0005,0, 0,1)
		if _throb_time <= 0:
			_throb = false
		pass
	else:
		_throb_time += delta
		
		_current_color += Color(0.0005,0, 0,1)
		if _throb_time > 1.5:
			_throb = true
			
	$Sprite.modulate = _current_color

func _kill_myself():
	queue_free()

func _player_detected(body):
	body.take_damage()
	get_destroyed()
