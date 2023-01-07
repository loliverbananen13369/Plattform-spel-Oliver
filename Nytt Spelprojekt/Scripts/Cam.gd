extends Camera2D


func _physics_process(delta):
	pass
	#if get_node("../Node2D/Player").motion.x > 15 or get_node("../Node2D/Player").motion.y > 15 or get_node("../Node2D/Player").motion.x > -15 or get_node("../Node2D/Player").motion.y > -15:
	#	global_position = get_node("../Node2D/Player").global_position.round()
	#	force_update_scroll()
