extends Node2D


var entered_bs_house = false
var entered_portal = false
var entered_well = false
var entered_katalina = false
var can_start_d = false
var player_scene = PlayerStats.player_instance
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")
onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Bshouse.rect_position.x = -87#(-87, -110)
	$Bshouse.visible = false
	$PortalLabel.rect_position.x = 1032
	$PortalLabel.visible = false
	player = player_scene.instance()
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(100, -20)
	if PlayerStats.visited_bs_house == true:
		player.global_position = global_position  + Vector2(0, -20)
	if PlayerStats.visited_katalina_house == true:
		player.global_position = global_position + Vector2(-367, -24)
	get_child(2).add_child(player)
	get_child(2).add_child(target)
	#get_child(1).add_child(target)


func _on_Area2D_body_entered(body):
	entered_bs_house = true
	can_start_d = false
	entered_portal = false
	anim.play("BSHouse")


func _on_Area2D_body_exited(body):
	entered_bs_house = false
	anim.stop(true)
	$Bshouse.visible = false

func _use_dialogue():
	var dialogue = get_node("Well/WellDialogue")
	if dialogue:
		dialogue._start()

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		if entered_bs_house:
			PlayerStats.next_scene = "res://Scenes/BlackSmithsHouse.tscn"
			Transition.load_scene(PlayerStats.next_scene)
			PlayerStats.visited_bs_house = true
		if entered_katalina:
			PlayerStats.next_scene = "res://Scenes/AssHouse.tscn"
			Transition.load_scene((PlayerStats.next_scene))
			PlayerStats.visited_katalina_house = true
		#get_tree().change_scene(PlayerStats.next_scene)
		if entered_portal:
			PlayerStats.next_scene = "res://Scenes/NewTestWorld.tscn"
			Transition.load_scene(PlayerStats.next_scene)
		if entered_well:
			if can_start_d:
				_use_dialogue()
				can_start_d = false
			else:
				get_node("Well/WellDialogue")._stop_dialogue()
				can_start_d = true
			


func _on_Portal_body_entered(body):
	entered_portal = true
	entered_bs_house = false
	can_start_d = false
	anim.play("Portal")


func _on_Portal_body_exited(body):
	entered_portal = false
	anim.stop(true)
	$PortalLabel.visible = false


func _on_Well_body_entered(body: Node) -> void:
	entered_well = true
	entered_portal = false
	entered_bs_house = false
	can_start_d = true


func _on_Well_body_exited(body: Node) -> void:
	entered_well = false
	can_start_d = false


func _on_Elder_body_entered(body: Node) -> void:
	pass # Replace with function body.


func _on_AssHouseDoor_body_entered(body: Node) -> void:
	entered_katalina = true
	entered_bs_house = false
	can_start_d = false
	entered_portal = false
	anim.play("AssHouse")


func _on_AssHouseDoor_body_exited(body: Node) -> void:
	entered_katalina = false
	anim.stop(true)
	$AssHouseDoor/AssHouseLabel.visible = false
