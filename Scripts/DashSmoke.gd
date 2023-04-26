extends AnimatedSprite

#Ger olika dashsmokes beroende på om spelaren är på marken eller i luften


func _ready() -> void:
	frame = 0
	if animation == "ImpactDustKick":
		scale.x = 2
		scale.y = 2
		$AnimationPlayer.play("ImpactDustKick")
	if animation == "New Anim":
		scale.x = 3
		scale.y = 4
		$AnimationPlayer.play("Hejsan")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
