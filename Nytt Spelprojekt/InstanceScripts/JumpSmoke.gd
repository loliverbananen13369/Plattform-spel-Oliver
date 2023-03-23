extends AnimatedSprite


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	frame = 0
	modulate = PlayerStats.ground_color
	scale.x = 1
	scale.y = 0.6
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_JumpSmoke_animation_finished() -> void:
	queue_free()
