extends AnimatedSprite



func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
