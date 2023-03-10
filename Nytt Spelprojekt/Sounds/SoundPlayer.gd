extends Node

var voice_pitch_scale = 1 

func play_sound(sound: String) -> void:
	for node in get_children():
		if node is AudioStreamPlayer:
			node.stop()
	
	get_node(sound).play()
