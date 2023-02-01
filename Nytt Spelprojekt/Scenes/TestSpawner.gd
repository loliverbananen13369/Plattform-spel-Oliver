extends Node


const WIDTH = 1024
const HEIGHT = 600

var warrior_scene = preload("res://Scenes/SkeletonWarrior.tscn")

onready var player = get_node("../Node2D/Player")

func _ready() -> void:
	randomize()
	$Timer.wait_time = 3 + rand_range(-2, 2)

func _can_spawn_warrior() -> bool:
	var number_of_warrior = len(get_tree().get_nodes_in_group("Enemy"))
	return number_of_warrior <= 10

func _spawn_warrior() -> void:
	var warrior = warrior_scene.instance()
	warrior.position = Vector2(rand_range(200, 20), -15)
	add_child(warrior)
"""
	var section = randi() % 4
	if section == 0:
		warrior.global_position = player.global_position + Vector2(-WIDTH/2 - 20, rand_range(-HEIGHT/2, HEIGHT/2))
	elif section == 1:
		warrior.global_position = player.global_position + Vector2(WIDTH/2 + 20, rand_range(-HEIGHT/2, HEIGHT/2))
	elif section == 2:
		warrior.global_position = player.global_position + Vector2(rand_range(-WIDTH/2, WIDTH/2), -HEIGHT/2 - 20)
	else:
		warrior.global_position = player.global_position + Vector2(rand_range(-WIDTH/2, WIDTH/2), HEIGHT/2 + 20)
	add_child(warrior)
"""
func _spawn_swarm() -> void:
	#var possible_sections = [[0, 3], [0, 2], [1, 3], [1, 3]]
	#var sections = possible_sections[randi() % len(possible_sections)]
	pass
"""
	for section in [0, 1, 2, 3]:
		for i in range(3):
			var warrior = warrior_scene.instance()
			if section == 0:
				warrior.global_position = player.global_position + Vector2(-WIDTH/2 - 20, -HEIGHT/2 + i * HEIGHT/3)
			elif section == 1:
				warrior.global_position = player.global_position + Vector2(WIDTH/2 + 20, -HEIGHT/2 + i * HEIGHT/3)
			elif section == 2:
				warrior.global_position = player.global_position + Vector2(-WIDTH/2 + i * WIDTH/3, -HEIGHT/2 - 20)
			else:
				warrior.global_position = player.global_position + Vector2(-WIDTH/2 + i * WIDTH/3, HEIGHT/2 + 20)
			add_child(warrior)
				
"""


func _on_Timer_timeout() -> void:
	if _can_spawn_warrior():
		var randomnumber = randi() % 10
		if randomnumber == 0:
			_spawn_swarm()
		else:
			_spawn_warrior()
		$Timer.wait_time = 3 + rand_range(-2, 2)
		
			
