extends CanvasLayer

var scene = PlayerStats.next_scene

onready var animationplayer = $AnimationPlayer

func load_scene(scene):
	animationplayer.play("fade_in")
	yield(animationplayer, "animation_finished")
	get_tree().change_scene(scene)
	#animationplayer.play_backwards("fade_in")
	animationplayer.play("fade_out")
