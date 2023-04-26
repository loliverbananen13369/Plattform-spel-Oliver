extends AnimatedSprite

#Egentligen rätt onödigt med script. Can queue_free() i animationplayer

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
