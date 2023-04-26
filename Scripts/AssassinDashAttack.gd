extends AnimatedSprite

#Läggs till när divine warrior spinattackar

onready var player = get_parent()
onready var player_dir = player.get("direction_x")
var dir

func _ready():
	frame = 0
	if player_dir == "RIGHT":
		dir = 1
	else:
		dir = -1

func _process(delta):
	global_position = player.global_position + Vector2(50*dir, 0)


func _on_AssassinDashAttack_animation_finished():
	queue_free()


func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
