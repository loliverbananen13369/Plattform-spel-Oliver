extends Particles2D



func _ready():
	modulate = PlayerStats.ground_color
	yield(get_tree().create_timer(1), "timeout")
	queue_free()

