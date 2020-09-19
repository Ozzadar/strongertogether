extends "res://src/Player/PlayerShip.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Sprite").fade_in("setPink", -1, 1, 1, '', GDArmatureDisplay.FadeOut_All)
	get_node("Sprite").fade_in("Idle", -1, -1, 2, '', GDArmatureDisplay.FadeOut_SameLayer)
	current_gun = load("res://src/Pickups/BasicGun.tscn").instance()
	add_child(current_gun)
	pass # Replace with function body.
	

