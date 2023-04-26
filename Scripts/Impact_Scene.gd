extends Sprite


#När divine har dashattackat


func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
