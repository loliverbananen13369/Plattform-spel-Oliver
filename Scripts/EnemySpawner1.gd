extends Node

#Har enemyspawnposition2d som barn.

var warrior_scene = preload("res://Scenes/SkeletonWarrior.tscn")
onready var timer = $Timer
var list_of_lists = []

export (SpriteFrames) var skin
export (SpriteFrames) var hit
export (int) var hp_max
export (int) var damage_dealt
export (String) var enemy_type
export (Color) var enemy_hp_bar_color

signal Spawned(body)

func _ready() -> void:
	var parent = get_parent()
	skin = parent.skin
	enemy_type = parent.enemy_type
	hp_max = parent.hp_max
	damage_dealt = parent.damage_dealt
	enemy_hp_bar_color = parent.enemy_hp_bar_color
	hit = parent.hit
	timer.start(3)

func _can_spawn_warrior() -> bool:
	var parent = get_parent()
	if parent.can_spawn:
		return true 
	else:
		timer.stop()
		return false


func _check_enemies(area: int):
	pass
	
func _get_enemy_skin():
	return skin

func _get_enemy_hit():
	return hit

func _spawn_warrior(area: int) -> void:
	var warrior = warrior_scene.instance()
	var parent = get_parent()
	var diameter = parent.diameter
	var frames = _get_enemy_skin()
	var hframes = _get_enemy_hit()
	warrior.type = enemy_type
	warrior.hp_max = hp_max
	warrior.damage_dealt = damage_dealt
	warrior.get_node("AnimatedSprite").set_sprite_frames(frames)
	warrior.get_node("Sprite").set_sprite_frames(hframes)
	add_child(warrior)
	warrior.hpbar.modulate = enemy_hp_bar_color
	warrior.global_position = parent.get_child(0).get_child(0).global_position + Vector2(rand_range((-diameter/2), (diameter/2)), 0)
	warrior.add_to_group(str(area))
	emit_signal("Spawned", warrior)

func _on_Timer_timeout() -> void:
	if _can_spawn_warrior():
		_spawn_warrior(1)
		timer.wait_time = 2 + rand_range(-1, 1)

		
func _on_Position2D_can_spawn(can):
	if can:
		timer.start(2)
	else:
		timer.stop()
