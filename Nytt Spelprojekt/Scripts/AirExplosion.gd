extends AnimatedSprite




func _ready() -> void:
	frame = 0
	
func _process(delta) -> void:
	pass
	


func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
