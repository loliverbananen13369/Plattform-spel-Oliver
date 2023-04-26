extends AnimatedSprite

#Visar vägen som golem attack2 åker

func _ready() -> void:
	frame = 0
	playing = true

func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
