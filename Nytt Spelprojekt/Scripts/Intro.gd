extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const NEW_AUDIO = "res://Intro/sunrise-114326.mp3"

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.visible = false
	$CanvasLayer2.visible = false
	yield(get_tree().create_timer(0.1), "timeout")
	$AnimationPlayer.play("Fade in")
	yield($AnimationPlayer, "animation_finished")
	yield(get_tree().create_timer(2), "timeout")
	$ColorRect.visible = true
	$CanvasLayer2.visible = true
	#$AudioStreamPlayer.stream = NEW_AUDIO
	yield(get_tree().create_timer(0.05), "timeout")
	print($ColorRect.visible)
	print($CanvasLayer2.visible)
	$AnimationPlayer.play("NameAnim")
	yield($AnimationPlayer, "animation_finished")
	yield(get_tree().create_timer(1), "timeout")
	Transition.load_scene("res://UI/StartMenu.tscn")
	
	#pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



