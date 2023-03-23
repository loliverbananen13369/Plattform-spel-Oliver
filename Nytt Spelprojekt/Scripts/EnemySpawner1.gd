extends Node


var warrior_scene = preload("res://Scenes/SkeletonWarrior.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _can_spawn_warrior(area: int, can: bool):
	for i in range(len(get_parent().get_node("EnemySpawnPoints"))):
		pass
	var number_of_warrior = len(get_tree().get_nodes_in_group("Enemy"))
	return number_of_warrior <= 20

func _check_enemies(area: int):
	pass
	
	

func _spawn_warrior() -> void:
	var warrior = warrior_scene.instance()
	warrior.global_position = Vector2(rand_range(200, 20), -35)
	add_child(warrior)

func _on_Timer_timeout() -> void:
	if _can_spawn_warrior(1, true):
		var randomnumber = randi() % 10
		if randomnumber == 0:
			_spawn_warrior()
		else:
			_spawn_warrior()
		$Timer.wait_time = 1 + rand_range(-1, 1)
		
