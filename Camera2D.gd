extends Camera2D

export var decay = 0.8  # How quickly the shaking stops [0, 1].
export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).
export (NodePath) var target  # Assign the node this camera will follow.
onready var noise = OpenSimplexNoise.new()
var noise_y = 0
var trauma = 0.0  # Current shake strength.
var trauma_power = 3  # Trauma exponent. Use [2, 3].
var pop = 0.0

func _ready():
	randomize()

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func add_pop(amount):
	pop = min(pop + amount, 0.75)
	
func pop():
	var amount = pow(pop, trauma_power)
	zoom = Vector2(1 - amount, 1 - amount)
	
func _process(delta):
	if target:
		global_position = get_node(target).global_position
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()		
	if pop:
		pop = max(pop - decay * delta, 0)
		pop()
		
func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range(-1, 1)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)
