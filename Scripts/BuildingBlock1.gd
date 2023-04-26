extends Node2D

#Ger alla lvlar 


var player_scene = PlayerStats.player_instance
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")
export (String) var next_scene 
export (String) var previous_scene
export (String) var ground_color
export (String) var footsteps_sound


func _ready() -> void:
	PlayerStats.ground_color = ground_color
	PlayerStats.footsteps_sound = footsteps_sound
	PlayerStats.next_scene = next_scene
	PlayerStats.prev_scene = previous_scene
	player = player_scene.instance()
	var target = anchor_scene.instance()
	target.get_child(0).limit_right = $CameraLimits/TopRIght.position.x
	target.get_child(0).limit_left = $CameraLimits/BottomLeft.position.x
	target.get_child(0).limit_bottom = $CameraLimits/BottomLeft.position.y 
	target.get_child(0).limit_top = $CameraLimits/TopRIght.position.y
	get_child(0).add_child(player)
	player.global_position = $PlayerNode/Position2D.global_position
	get_child(0).add_child(target)
	PlayerStats.player = player
	

func _on_Dialogue_active(active) -> void:
	var value = AudioServer.get_bus_volume_db(0)
	if active:
		value -= 10
		AudioServer.set_bus_volume_db(0, value)
	else:
		value += 10
		AudioServer.set_bus_volume_db(0, value)
