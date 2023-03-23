extends Node2D

var player_scene = PlayerStats.player_instance
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")
export (String) var next_scene 
export (String) var previous_scene

func _ready() -> void:
	
	player = player_scene.instance()
	BackgroundMusic.play_sound("GameMusic")
	var target = anchor_scene.instance()
#	if PlayerStats.is_assassin == true:
	#	player = assassin_scene.instance()
#	else:
	#	player = mage_scene.instance()
	#player.global_position = global_position + Vector2(30, -200)
	#target.get_child(0).limit_right = 1000
	#target.get_child(0).limit_left = -220
	#target.get_child(0).limit_bottom = 140
	#target.get_child(0).limit_top = -220
	get_child(0).add_child(player)
	get_child(0).add_child(target)
	#var hej2 = get_child(1)

func _on_Dialogue_active(active) -> void:
	var value = AudioServer.get_bus_volume_db(0)
	if active:
		value -= 10
		AudioServer.set_bus_volume_db(0, value)
	else:
		value += 10
		AudioServer.set_bus_volume_db(0, value)
