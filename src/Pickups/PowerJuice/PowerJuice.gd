extends Node2D

export(float) var lifespan = 5.0

var _alive : float = 0.0
var _dying : float = -1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	_alive += delta
	
	if _alive >= lifespan && _dying < -0.0:
		_die()
	
	if _dying >= 0.0:
		_dying += delta
		
		if _dying > 0.5:
			queue_free()
		

func _on_body_entered(body):
	_die()
	
	if body.has_method('pickup_juice'):
		body.pickup_juice()
	pass # Replace with function body.


func _die():
	$Sprite.hide()
	$SparkleEffect2.restart()
	$SparkleEffect2.emitting = true
	_dying = 0.0
	pass
