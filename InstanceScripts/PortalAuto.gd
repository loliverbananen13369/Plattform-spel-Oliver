extends Sprite

#När spelaren går in här kommer nästa scen laddas automatiskt

export (String) var next_scene


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		Transition.load_scene(next_scene)
