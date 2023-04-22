extends CanvasLayer



func _ready():
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("Pause"): 
		_pause()

func _pause():
	$PauseMenu.visible = !$PauseMenu.visible
	$Background.visible = !$Background.visible
	$Label.visible = !$Label.visible
	get_tree().paused = !get_tree().paused # togglar pause statusen
