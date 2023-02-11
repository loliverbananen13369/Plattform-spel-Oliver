extends AnimatedSprite

const MAX_SPEED = 300
var velocity := Vector2.ZERO



var skeleton_enemy_scene = preload("res://Scenes/SkeletonWarrior.tscn")
onready var player = get_node("/root/Level 0/Node2D/Player")
onready var test = get_node("/root/Level 0/Node")

#var enemy = _get_closest_enemy()
#var direction_x := global_position.direction_to(enemy)

func _ready() -> void:
	#_test_function()
	frame = 0


"""
func _process(delta) -> void:
	velocity = direction_x * MAX_SPEED


	
func _get_closest_enemy():
	var all_enemy = get_tree().get_nodes_in_group("Enemy")
	print(all_enemy)
	if len(all_enemy) > 0:
		var closest_enemy = all_enemy[0]
		for i in range(1, len(all_enemy)):
			if global_position.distance_to(all_enemy[i].global_position) < global_position.distance_to((closest_enemy.global_position)):
				closest_enemy = all_enemy[i]

		return closest_enemy

func _test_function():
	var damage = player.get("tester")
	print(damage)

"""

func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
