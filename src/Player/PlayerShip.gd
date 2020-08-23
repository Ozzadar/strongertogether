extends KinematicBody2D
class_name PlayerShip

signal shot_bullet
signal juice_pickup
signal got_hit

export(float) var energy_attrition = 1.0
export(Color) var lazer_color = Color(0,0,0,1)
export(bool) var up = true

var current_gun = null
var current_energy : float = 0.0
var shooting : bool = true
var lazer : Line2D 
var dead : bool = false

func reset():
	dead = false
	
func _update_energy_bar():
	get_node("Energy").value = current_energy
	
func fire():
	if lazer != null:
		lazer.queue_free()
		lazer = null
		
	if current_gun != null && current_gun.has_method("shoot") && current_gun.can_shoot():
		
		var new_bullet = current_gun.shoot()
		var angle = get_node("Sprite").get_global_transform().get_rotation() - (3.14 /2)
		new_bullet.direction = Vector2(cos(angle), sin(angle))
		new_bullet.global_position = global_position
		emit_signal('shot_bullet', new_bullet)

func _physics_process(delta):
	if dead:
		return
		
	if shooting:
		fire()
	else:
		_fire_lazer()

func _fire_lazer():
	if lazer != null:
		lazer.queue_free()
		lazer = null
	
	lazer = Line2D.new()
	add_child(lazer)
	var points : PoolVector2Array = PoolVector2Array()
	points.append(position)
	var lazer_line = Vector2(0, 3000)
	if !up:
		lazer_line = Vector2(0, -3000)
	points.append(position + lazer_line)
	lazer.points = points
	
	lazer.width = 300
	lazer.default_color = lazer_color
	
func pickup_juice():
	emit_signal("juice_pickup")

func take_damage():
	emit_signal("got_hit")
