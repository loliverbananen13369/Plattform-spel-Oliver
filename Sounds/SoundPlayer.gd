extends Node

var voice_pitch_scale = 1 
onready var tween = $Tween
onready var MainMeniMusic = $MainMenuMusic
onready var GameMusic = $GameMusic


func play_sound(sound: String) -> void:
	for node in get_children():
		if node is AudioStreamPlayer:
			node.stop()
#	tween.interpolate_property(sound, "set_bus_volume_db", 0.0, PlayerStats.master_vol_value, 1.0)
#	tween.start()
	get_node(sound).play()
