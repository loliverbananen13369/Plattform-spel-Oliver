extends AnimatedSprite

var dash

func _ready():
	if dash:
		pass

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
