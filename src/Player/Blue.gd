extends "res://src/Player/PlayerShip.gd"

func _ready():
	#get_node("Sprite").fade_in("Idle", -1, -1, 2, '', GDDragonBones.FadeOut_None)
	get_node("Sprite").fade_in("Idle", -1, -1, 15, '', GDArmatureDisplay.FadeOut_None)
	get_node("Sprite").set_slot_by_item_name('Player', "blueface")	
	current_gun = load("res://src/Pickups/BasicGun.tscn").instance()
	add_child(current_gun)
	pass # Replace with function body.
	
func _physics_process(delta):
	pass
