extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_parent()
onready var player_dir_x = player.get("direction_x")
onready var player_dir_y = player.get("direction_y")
var dir

# Called when the node enters the scene tree for the first time.
func _ready():
	if player_dir_x == "RIGHT":
		print("RIGHT")
		material.set_shader_param("angle", 360)
	elif player_dir_y == "UP":
		print("DOWN")
		material.set_shader_param("angle", 180)
	else:
		material.set_shader_param("angle", 0)
	yield(get_tree().create_timer(0.25),"timeout")
	queue_free()
