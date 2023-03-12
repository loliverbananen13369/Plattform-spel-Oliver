extends Node2D


var player_scene = PlayerStats.player_instance
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")
var in_range_for_talk
var can_exit = false

func _ready():
	player = player_scene.instance()
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(270, -20)

	get_child(0).add_child(player)
	get_child(0).add_child(target)
	yield(get_tree().create_timer(0.5),"timeout")
	in_range_for_talk = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if in_range_for_talk:
			_use_dialogue()
		if can_exit:
			PlayerStats.next_scene = "res://Scenes/CityHall.tscn"
			Transition.load_scene(PlayerStats.next_scene)
			#get_tree().change_scene(PlayerStats.next_scene)

func _use_dialogue():
	var dialogue = get_node("Dialogue")
	if dialogue:
		dialogue._start()


func _on_Area2D_body_entered(body):
	in_range_for_talk = true


func _on_Area2D_body_exited(body):
	in_range_for_talk = false


func _on_Door_body_entered(body):
	can_exit = true
	in_range_for_talk = false


func _on_Door_body_exited(body):
	can_exit = false
