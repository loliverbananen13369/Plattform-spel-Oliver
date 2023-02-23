extends Node2D

var player
var assassin_scene = preload("res://Scenes/PlayerAssassin.tscn")
var mage_scene = preload("res://Scenes/Player.tscn")
var anchor_scene = preload("res://Scenes/Anchor.tscn")

func _ready() -> void:
	var target = anchor_scene.instance()
	if PlayerStats.is_assassin == true:
		player = assassin_scene.instance()
	else:
		player = mage_scene.instance()
	player.global_position = global_position + Vector2(30, -200)
	get_child(1).add_child(player)
	get_child(1).add_child(target)
	#var hej2 = get_child(1)
	
	


