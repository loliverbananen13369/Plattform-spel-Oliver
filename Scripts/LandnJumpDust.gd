extends AnimatedSprite

#När spelaren landar

func _ready():
	frame = 0
	modulate = PlayerStats.ground_color
	scale.x = 0.2
	scale.y = 0.1


func _on_LandnJumpDust_animation_finished():
	queue_free()



