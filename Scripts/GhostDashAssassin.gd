extends AnimatedSprite


func _ready():
	$Particles2D.emitting = true
	
func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
