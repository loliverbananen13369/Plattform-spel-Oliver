extends Node2D


var player_scene = PlayerStats.player_instance
#onready var player = PlayerStats.player
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")
var in_range_for_talk
var can_exit = false
onready var audiop = $AnimatedSprite/AudioStreamPlayer2D


func _ready():
	PlayerStats.visited_bs_house = true
	PlayerStats.ground_color = "3a2122"
	player = player_scene.instance()
	#player = PlayerStats.player
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(270, -20)

	get_child(0).add_child(player)
	get_child(0).add_child(target)
	PlayerStats.player = player
	yield(get_tree().create_timer(0.5),"timeout")
	in_range_for_talk = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if in_range_for_talk:
			_use_dialogue()

		if can_exit:
			PlayerStats.next_scene = "res://Levels/CityHall.tscn"
			Transition.load_scene(PlayerStats.next_scene)
			#get_tree().change_scene(PlayerStats.next_scene)

func _use_dialogue():
	var dialogue = get_node("Dialogue")
	if dialogue:
		dialogue._start()

func _on_Dialogue_active(active) -> void:
	var value = AudioServer.get_bus_volume_db(0)
	if active:
		value -= 10
		AudioServer.set_bus_volume_db(0, value)
		audiop.playing = true
	else:
		value += 10
		AudioServer.set_bus_volume_db(0, value)
		audiop.playing = false

func _on_Area2D_body_entered(body):
	in_range_for_talk = true


func _on_Area2D_body_exited(body):
	in_range_for_talk = false


func _on_Door_body_entered(body):
	can_exit = true
	in_range_for_talk = false


func _on_Door_body_exited(body):
	can_exit = false


