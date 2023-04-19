extends Node


const WIDTH = 1024
const HEIGHT = 600

var warrior_scene = preload("res://Scenes/SkeletonWarrior.tscn")

func _ready() -> void:
	randomize()
	$Timer.wait_time = 5 + rand_range(-1, 1)

func _can_spawn_warrior() -> bool:
	var number_of_warrior = len(get_tree().get_nodes_in_group("Enemy"))
	return number_of_warrior <= 20

func _spawn_warrior() -> void:
	var warrior = warrior_scene.instance()
	warrior.global_position = Vector2(rand_range(200, 20), -35)
	add_child(warrior)

func _spawn_swarm() -> void:
	#var possible_sections = [[0, 3], [0, 2], [1, 3], [1, 3]]
	#var sections = possible_sections[randi() % len(possible_sections)]
	pass


func _on_Timer_timeout() -> void:
	if _can_spawn_warrior():
		var randomnumber = randi() % 10
		if randomnumber == 0:
			_spawn_swarm()
			_spawn_warrior()
		else:
			_spawn_warrior()
		$Timer.wait_time = 1 + rand_range(-1, 1)
		
			
