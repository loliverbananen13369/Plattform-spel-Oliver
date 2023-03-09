extends AnimatedSprite

func _ready() -> void:
	frame = 0
	if animation == "ImpactDustKick":
		scale.x = 2
		scale.y = 2
		#modulate.r = 2.75
		#modulate.g = 1
		#modulate.b = 1.85
		#modulate.r = 0.5
		#modulate.g = 0.5
	#	modulate.b = 1.37

		$AnimationPlayer.play("ImpactDustKick")

	if animation == "New Anim ":
		scale.x = 2
		scale.y = 4
		#modulate.r = 0.5
		#modulate.g = 0.5
		#modulate.b = 1.37
		$AnimationPlayer.play("New Anim 1")
	if animation == "New Anim 1":
		scale.x = 3
		scale.y = 4
		#modulate.r = 0.5
		#modulate.g = 0
	#	modulate.b = 0.62
		$AnimationPlayer.play("Hejsan2")

func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()