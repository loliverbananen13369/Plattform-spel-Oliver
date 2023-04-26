extends Area2D

#Laddar automatiskt förra scenen

func _on_Next_body_entered(body):
	if body.is_in_group("Player"):
		Transition.load_scene(PlayerStats.prev_scene)
