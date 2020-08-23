extends Gun

func shoot() -> Node2D :
	.shoot()
	var new_bullet = bullet.instance()
	
	return new_bullet
