extends AnimatedSprite


#Positionen anges i spelarkoden

func _ready() -> void:
	animation = ("New Anim")
	$Particles2D.emitting = true
	frame = 0




func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
