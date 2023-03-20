extends Node2D

var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")

func _ready() -> void:
	player = PlayerStats.player
	BackgroundMusic.play_sound("GameMusic")
	var target = anchor_scene.instance()
#	if PlayerStats.is_assassin == true:
	#	player = assassin_scene.instance()
#	else:
	#	player = mage_scene.instance()
	player.global_position = global_position + Vector2(30, -200)
	target.get_child(0).limit_right = 1000
	target.get_child(0).limit_left = -220
	target.get_child(0).limit_bottom = 140
	target.get_child(0).limit_top = -220
	get_child(1).add_child(player)
	get_child(1).add_child(target)
	#var hej2 = get_child(1)
	
	


