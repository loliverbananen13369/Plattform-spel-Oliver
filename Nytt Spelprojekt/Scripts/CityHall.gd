extends Node2D


var entered_bs_house = false
var player_scene = preload("res://Scenes/PlayerAssassin.tscn")
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	#player = PlayerStats.player
	PlayerStats.player = player_scene.instance()
	player = PlayerStats.player
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(30, -20)
	if PlayerStats.visited_bs_house == true:
		player.global_position = global_position  + Vector2(0, -20)
	get_child(0).add_child(player)
	get_child(0).add_child(target)

func _on_Area2D_body_entered(body):
	entered_bs_house = true


func _on_Area2D_body_exited(body):
	entered_bs_house = false
	
func _input(event):
	if Input.is_action_just_pressed("ui_accept") and entered_bs_house:
		PlayerStats.visited_bs_house = true
		get_tree().change_scene("res://Scenes/BlackSmithsHouse.tscn")
