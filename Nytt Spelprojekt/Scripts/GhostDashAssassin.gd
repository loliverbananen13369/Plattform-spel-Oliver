extends AnimatedSprite




#2.35, 1.05, 2.4

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
