extends Node2D

signal changed_direction
signal changed_mode
signal juiced_up
signal health_changed
signal bullet_shot

onready var pink = $PINK
onready var blue = $Blue
onready var tween = $Tween
onready var distance_line = $DistanceLine
onready var energy_line = $EnergyLine

export (float) var acceleration : float = 10
export (float) var decceleration : float = 5
export (float) var max_rotation_speed : float = 10
export (float) var max_distance : float = 300
export (float) var can_mode_distance = 200
export (int) var max_energy = 100
export (float) var decay_per_second = 5
export (int) var max_health = 5

var _translation : Vector2 = Vector2.ZERO
var _inputs : Vector2 = Vector2.ZERO
var _rotation_speed : float = 0.0
var _movement_speed : Vector2 = Vector2.ZERO
var _distance : float = 0.0
var _facing_direction : bool = false # only 2 modes
var _mode : bool = false  setget _switch_mode # true is better together mode
var _total_energy : float = 0
var _throb : int = 0
var _throb_up : bool = true
var _current_health : int = 0

func _ready():
	pink.connect('shot_bullet', self, '_bullet_shot')
	blue.connect('shot_bullet', self, '_bullet_shot')
	pink.connect('juice_pickup', self, '_juice_pickup')
	blue.connect('juice_pickup', self, '_juice_pickup')
	blue.connect('got_hit', self, 'take_damage')
	pink.connect('got_hit', self, 'take_damage')

func _juice_pickup():
	_total_energy = clamp(_total_energy + 25, 0, max_energy)
	
	$Camera2D.add_pop(0.5)
	
func _bullet_shot(new_bullet):
	emit_signal("bullet_shot", new_bullet)
	
# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if is_dead():
		pink.dead = true
		blue.dead = true
		return
	_record_inputs()
	_handle_inputs(delta)
	_move(delta)
	
	if $Super.visible != _can_super():
		$Super.visible = _can_super()
		
	if _total_energy < max_energy && !_mode:
		_energy_decay(delta)	
	elif _mode:
		_countdown_super(delta)
			
	_draw_line()

func _energy_decay(delta):
	_total_energy = clamp(_total_energy - (decay_per_second * delta), 0, max_energy)

func _countdown_super(delta):
	_total_energy = clamp(_total_energy - ((decay_per_second * 5) * delta), 0, max_energy)
	if _total_energy == 0:
		_switch_mode(false)
	
func _update_energy_line(points):
	var percentage : float = (float(_total_energy) / float(max_energy))

	var new_points : PoolVector2Array = []
	for point in points:
		# multiply by percentage half
		new_points.append(point * percentage)
	
	energy_line.points = new_points;
	
	var r : float = 1 * percentage
	var g : float = 1 * percentage
	var b : float = 1 * percentage
	
	if _throb_up:
		_throb += 1
		if _throb >= 47:
			_throb_up = false
	else:
		_throb -= 1
		if _throb <= 0:
			_throb_up = true
		
	energy_line.width = 25 + (_throb % 48)

	if _throb_up:
		energy_line.default_color = Color(r + _throb, g, b, 0.25);
	else:
		energy_line.default_color = Color(r, g, b + _throb, 0.25);
		
	
# 2 different input modes
func _record_inputs():
	_inputs.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if _mode:
		_inputs.x = 1
		
	_inputs.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if Input.is_action_just_pressed("switch_mode"):
		if _can_super():
			_switch_mode(!_mode)
		else:
			_switch_facing_direction(!_facing_direction)
			

func _switch_facing_direction(new_dir : bool):
	if _mode:
		_facing_direction = false
		return

	_facing_direction = new_dir
	
	emit_signal("changed_direction", _facing_direction)
	
func _handle_inputs(delta):
	# better together mode
	if _mode:
		if _inputs.x != 0:
			_rotation_speed += acceleration * _inputs.x * delta
		else:
			# decellerate
			_rotation_speed *= (1 - (decceleration * delta))
	else:
		if _inputs.x != 0 && !_facing_direction:
			_movement_speed.x -= acceleration * _inputs.x * delta *5
		elif !_facing_direction:
			# decellerate
			_movement_speed.x *= (1 - (decceleration * delta))
		else:
			_movement_speed.x = 0
	
		if _inputs.y != 0 && _facing_direction:
			_movement_speed.y -= acceleration * _inputs.y * delta *5
		elif _facing_direction:
			_movement_speed.y *= (1 - (decceleration * delta))
		else:
			_movement_speed.y = 0
			
		_translation += _movement_speed * delta
		
func _switch_mode(mode : bool):
	_mode = mode
	
	if mode:
		_disable_shooting(true)
		_switch_facing_direction(false)
		tween.interpolate_property(self, '_translation', _translation, Vector2(0,75),0.1)
		tween.start()
	else:
		_disable_shooting(false)
		
		tween.interpolate_property(self, '_translation', _translation, Vector2(0, 150), 0.1)
		tween.interpolate_property(self, 'rotation_degrees', rotation_degrees, 0.0, 0.1)
		tween.interpolate_property(self, '_rotation_speed', _rotation_speed / 360, 0.0, 0.1)
		tween.start()
	
	emit_signal("changed_mode", _mode)
	pass

func _disable_shooting(is_disabled):
	pink.shooting = !is_disabled
	blue.shooting = !is_disabled
	pass
	
func _fire_lazers():
	
	pass
	
func _move(delta):
	
	rotation_degrees += _rotation_speed
	pink.rotation_degrees = -90.0 if _facing_direction else 0
	blue.rotation_degrees = -90.0 if _facing_direction else 0.0
	
	if !_mode:
		pink.move_and_collide(_movement_speed);
		blue.move_and_collide(-_movement_speed);
		_translation = pink.position
		
		_translation.x = clamp(_translation.x, -max_distance, max_distance)
		_translation.y = clamp(_translation.y, -max_distance, max_distance)
		
		if abs(_translation.x) == max_distance:
			_movement_speed.x = 0
		if abs(_translation.y) == max_distance:
			_movement_speed.y = 0
			
		pink.position = _translation
		blue.position = -_translation
	else:		
		pink.position = _translation
		blue.position = -_translation
		
	_distance = pink.position.distance_to(blue.position)
	pass

func _reset():
	_switch_mode(false)
	rotation_degrees = 0.0
	_inputs = Vector2.ZERO
	_draw_line()
	pink.reset()
	blue.reset()
	_translation = Vector2.ZERO
	_current_health = max_health
	_total_energy = 0

func _draw_line():
	var points : PoolVector2Array = PoolVector2Array()
	points.append(pink.position - (pink.position * 0.3))
	points.append(blue.position  - (blue.position * 0.3))
	
	var normalized_diff : float = _distance / ((max_distance * 2))
	
	distance_line.points = points;
	
	var r : float = 3 * normalized_diff
	var g : float = 3 * (1 - normalized_diff)
	var b : float = 0
	
	if _distance <= can_mode_distance:
		r = 0
		g = 255
	
	if _mode:
		distance_line.width = 20
	else:
		distance_line.width = clamp((1 - normalized_diff) * 10, 1, 100)
		
	distance_line.default_color = Color(r, g, b, 1);
	
	_update_energy_line(points)
	
	
func _can_super() -> bool:
	return _total_energy >= max_energy && _distance <= can_mode_distance

func take_damage():
	if is_dead():
		return
		
	$Camera2D.add_trauma(0.75)
	Input.start_joy_vibration(0,1.0,1.0,0.1)
	_current_health = clamp(_current_health - 1, 0, max_health)	
	emit_signal("health_changed", float(_current_health) / float(max_health))
	
func _enemy_detected(body):
	if body.has_method('get_destroyed'):
		body.get_destroyed()
		take_damage()
		
func is_dead() -> bool:
	return _current_health == 0
