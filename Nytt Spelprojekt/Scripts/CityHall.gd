extends Node2D


var entered_bs_house = false
var entered_portal = false
var player_scene = PlayerStats.player_instance
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")
onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():

	player = player_scene.instance()
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(30, -20)
	if PlayerStats.visited_bs_house == true:
		player.global_position = global_position  + Vector2(0, -20)
	get_child(2).add_child(player)
	get_child(2).add_child(target)
	#get_child(1).add_child(target)


func _on_Area2D_body_entered(body):
	entered_bs_house = true
	entered_portal = false
	anim.play("BSHouse")


func _on_Area2D_body_exited(body):
	entered_bs_house = false
	anim.stop(true)
	$Bshouse.visible = false
	
func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		if entered_bs_house:
			PlayerStats.visited_bs_house = true
			PlayerStats.next_scene = "res://Scenes/BlackSmithsHouse.tscn"
			Transition.load_scene(PlayerStats.next_scene)
		#get_tree().change_scene(PlayerStats.next_scene)
		if entered_portal:
			PlayerStats.next_scene = "res://Scenes/NewTestWorld.tscn"
			Transition.load_scene(PlayerStats.next_scene)


func _on_Portal_body_entered(body):
	entered_portal = true
	entered_bs_house = false
	anim.play("Portal")


func _on_Portal_body_exited(body):
	entered_portal = false
	anim.stop(true)
	$PortalLabel.visible = false
