extends AnimatedSprite


#4.55, 4.2, 3.5
var color 
#2.35, 1.05, 2.4
func _ready():
	
	$Particles2D.emitting = true
	
func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
