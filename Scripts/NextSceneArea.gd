extends Area2D

#Area som skickar iväg spelaren automatiskt till nästa scen

func _on_Next_body_entered(body):
	if body.is_in_group("Player"):
		Transition.load_scene(PlayerStats.next_scene)
