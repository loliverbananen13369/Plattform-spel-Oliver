extends AnimatedSprite

onready var player = PlayerStats.player#get_parent().get_child(3).get_child(1).get_child(0)


func _ready():
	if is_instance_valid(player):
		var direction_x = player.get("direction_x")
		frame = 0
		if animation == "LandSmoke":
			scale.x = 0.2
			scale.y = 0.1
		if animation == "LandSmokeAssassin":
			scale.x = 0.2
			scale.y = 0.1
			modulate.r8 = 232
			modulate.g8 = 193
			modulate.b8 = 112
		if animation == "JumpSmokeSide":
			scale.x = 0.5
			scale.y = 0.5
			if direction_x == "RIGHT":
				flip_h = false
			else:
				flip_h = true
		if animation == "JumpSmokeSideAssassin":
			scale.x = 0.5
			scale.y = 0.5
			if direction_x == "RIGHT":
				flip_h = false
			else:
				flip_h = true
			modulate.r8 = 232
			modulate.g8 = 193
			modulate.b8 = 112
		if animation == "DustExplosion":
			scale.x = 1
			scale.y = 0.6
			modulate.r8 = 213
			modulate.g8 = 60
			modulate.b8 = 106
			modulate.a8 = 255
			


func _on_LandnJumpDust_animation_finished():
	queue_free()



