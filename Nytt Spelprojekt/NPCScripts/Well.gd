extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var parent = get_parent()
onready var player = PlayerStats.player
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		if overlaps_body(player):
			if parent.can_start_d:
				parent._use_dialogue()
				parent.can_start_d = false 
			else:
				$WellDialogue._stop_dialogue()
				parent.can_start_d = true
