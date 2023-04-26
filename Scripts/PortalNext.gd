extends AnimatedSprite

#Skickar iväg spelaren till nästa scen

onready var player = PlayerStats.player
var entered = false



func _input(event):
	if Input.is_action_just_pressed("ui_accept"): 
		if entered:
			Transition.load_scene(PlayerStats.next_scene)


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		entered = true


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		entered = false
