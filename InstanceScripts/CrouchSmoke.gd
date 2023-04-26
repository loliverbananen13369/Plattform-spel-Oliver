extends AnimatedSprite

#Inget speciellt

func _ready() -> void:
	frame = 0
	modulate = PlayerStats.ground_color


func _on_CrouchSmoke_animation_finished() -> void:
	queue_free()
