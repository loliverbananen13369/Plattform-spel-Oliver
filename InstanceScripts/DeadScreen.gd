extends CanvasLayer

#När spelaren dör

func _on_AnimationPlayer_animation_finished(_anim_name):
	get_tree().quit()
