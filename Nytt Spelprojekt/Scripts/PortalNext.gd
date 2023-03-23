extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = PlayerStats.player
var entered = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if Input.is_action_just_pressed("ui_accept"): 
		if entered:#if $Area2D.overlaps_body(player):
			Transition.load_scene(PlayerStats.next_scene)





func _on_Area2D_body_entered(body):
	entered = true


func _on_Area2D_body_exited(body):
	entered = false
