extends AnimatedSprite

#När spelaren hoppar

func _ready() -> void:
	frame = 0
	modulate = PlayerStats.ground_color
	scale.x = 1
	scale.y = 0.6


func _on_JumpSmoke_animation_finished() -> void:
	queue_free()
