extends Node


var warrior_scene = preload("res://Scenes/SkeletonWarrior.tscn")
onready var timer = $Timer
var list_of_lists = []

signal Spawned(body)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	timer.start(3)

func _can_spawn_warrior() -> bool:
	var parent = get_parent()
	if parent.can_spawn:
		return true 
	else:
		return false
#	can = true
#	return can #number_of_warrior <= 20

func _check_enemies(area: int):
	pass
	
#Gör en kod för alla spawn points istället
	

func _spawn_warrior(area: int) -> void:
	var warrior = warrior_scene.instance()
	var parent = get_parent()
	var diameter = parent.diameter
	add_child(warrior)
	warrior.global_position = parent.global_position + Vector2(rand_range((-diameter/2), (diameter/2)), 0)
	warrior.add_to_group(str(area))
	emit_signal("Spawned", warrior)

func _on_Timer_timeout() -> void:
	if _can_spawn_warrior() == true:
		var randomnumber = randi() % 10
		if randomnumber == 0:
			_spawn_warrior(1)
		else:
			_spawn_warrior(1)
		
		$Timer.wait_time = 1 + rand_range(-1, 1)

func on_EnemyDead(body):
	pass
		
