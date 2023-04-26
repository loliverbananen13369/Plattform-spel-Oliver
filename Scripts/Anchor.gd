extends Position2D

#Tog kamera koden från någon youtube video

onready var player = get_parent().get_node("Player")



func _process(_delta):
	var target = player.global_position
	var target_pos_x
	var target_pos_y
	target_pos_x = int(lerp(global_position.x, target.x, 0.2))
	target_pos_y = int(lerp(global_position.y, target.y, 0.2))
	global_position = Vector2(target_pos_x, target_pos_y)
