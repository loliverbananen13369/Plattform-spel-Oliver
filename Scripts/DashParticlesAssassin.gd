extends Particles2D


func _ready() -> void:
	yield(get_tree().create_timer(1.0), "timeout")
	queue_free()
