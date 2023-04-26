extends CanvasLayer

#Taget från alien

var scene = PlayerStats.next_scene

onready var animationplayer = $AnimationPlayer

signal SceneChanged()

func load_scene(scene):
	animationplayer.play("fade_in")
	emit_signal("SceneChanged")
	yield(animationplayer, "animation_finished")
	get_tree().change_scene(scene)
	animationplayer.play("fade_out")
	yield(animationplayer, "animation_finished")
	
func _paus():
	get_tree().paused = !get_tree().paused
