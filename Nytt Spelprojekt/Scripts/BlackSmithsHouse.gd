extends Node2D


var player_scene = preload("res://Scenes/PlayerAssassin.tscn")
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")
var in_range_for_talk = false
var can_exit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#player = PlayerStats.player
	PlayerStats.player = player_scene.instance()
	player = PlayerStats.player
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(270, -20)
	get_child(0).add_child(player)
	get_child(0).add_child(target)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if in_range_for_talk:
			_use_dialogue()
		if can_exit:
			get_tree().change_scene("res://Scenes/CityHall.tscn")

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


func _on_Door_body_exited(body):
	can_exit = false
