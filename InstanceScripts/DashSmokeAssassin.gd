extends AnimatedSprite

#Olika om spelaren är i luften eller på marken

func _ready() -> void:
	frame = 0
	modulate.r = 3
	modulate.g = 1.5
	modulate.b = 1
	if animation == "ImpactDustKick":
		scale.x = 2
		scale.y = 2
		$AnimationPlayer.play("ImpactDustKick")
	if animation == "New Anim":
		scale.x = 3
		scale.y = 4
		$AnimationPlayer.play("Hejsan")



func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
