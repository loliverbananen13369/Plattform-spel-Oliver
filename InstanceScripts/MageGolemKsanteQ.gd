extends AnimatedSprite


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	frame = 0
	playing = true

func _physics_process(delta) -> void:
	pass

func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
