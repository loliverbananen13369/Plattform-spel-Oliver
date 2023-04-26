extends AnimatedSprite

#Necromancers golem attack2. När den den entrar fienders hitbox "hoppar" fienden upp

func _ready() -> void:
	frame = 0
	scale.y = 2
	scale.x = 2
	$AnimationPlayer.play("Burst")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	queue_free()
	

func _on_AnimationPlayer_animation_started(_anim_name: String) -> void:
	global_position.y -= 43
	global_position.x += 25
