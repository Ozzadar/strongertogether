extends "res://src/Pickups/Gun.gd"

func shoot() -> Node2D :
	.shoot()
	var new_bullet = bullet.instance()
	
	return new_bullet
