extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player = get_parent()
onready var player_dir = player.get("direction_x")
var dir

# Called when the node enters the scene tree for the first time.
func _ready():
	frame = 0
	#playing = true
	if player_dir == "RIGHT":
		dir = 1
	else:
		dir = -1
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = player.global_position + Vector2(50*dir, 0)


func _on_AssassinDashAttack_animation_finished():
	queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
