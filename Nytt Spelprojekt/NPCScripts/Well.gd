extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var parent = get_parent()
var player = PlayerStats.player
var can_start = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		if can_start:
			_use_dialogue()
			can_start = false 
		else:
			$WellDialogue._stop_dialogue()
			can_start = true

func _use_dialogue():
	var dialogue = get_node("WellDialogue")
	if dialogue:
		dialogue._start()
