extends AnimatedSprite

func _ready() -> void:
	frame = 0
	if animation == "ImpactDustKick":
		scale.x = 2
		scale.y = 2
		modulate.r = 2.75
		modulate.g = 1
		modulate.b = 1.85
	if animation == "New Anim":
		scale.x = 2
		scale.y = 2
		modulate.r = 0.07
		modulate.g = 0
		modulate.b = 0.14
	if animation == "New Anim 1":
		scale.x = 2
		scale.y = 4
		modulate.r = 0.5
		modulate.g = 0.5
		modulate.b = 1.37
	if animation == "ImpactMedium1":
		modulate.r = 0.07
		modulate.g = 0
		modulate.b = 0.14



func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
