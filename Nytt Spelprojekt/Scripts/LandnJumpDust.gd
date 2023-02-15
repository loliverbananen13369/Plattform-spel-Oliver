extends AnimatedSprite

onready var player = get_node("/root/Level 0/Node2D/Player")


func _ready():
	var direction_x = player.get("direction_x")
	frame = 0
	if animation == "LandSmoke":
		scale.x = 0.2
		scale.y = 0.1
	if animation == "JumpSmokeUp":
		scale.x = 0.5
		scale.y = 0.5
	if animation == "JumpSmokeSide":
		scale.x = 0.5
		scale.y = 0.5
		if direction_x == "RIGHT":
			flip_h = false
		else:
			flip_h = true
	if animation == "DustExplosion":
		scale.x = 1
		scale.y = 0.6
		modulate.r8 = 213
		modulate.g8 = 60
		modulate.b8 = 106
		modulate.a8 = 255
		


func _on_LandnJumpDust_animation_finished():
	queue_free()



