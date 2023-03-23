extends Node2D

var can_accept = false
var entered_bs_house = false
var entered_portal = false
var entered_portal2 = false
var entered_well = false
var entered_katalina = false
var can_start_d = false
var player_scene = PlayerStats.player_instance
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")

var next_scene
onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerStats.ground_color = "cf573c"
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
	target.get_child(0).limit_right = 1100
	target.get_child(0).limit_left = -2208
	target.get_child(0).limit_bottom = 40
	target.get_child(0).limit_top = -220
	get_child(2).add_child(player)
	get_child(2).add_child(target)
	#get_child(1).add_child(target)
	PlayerStats.player = player
	PlayerStats.visited_bs_house = false
	PlayerStats.visited_katalina_house = false


func _on_Area2D_body_entered(body):
	#PlayerStats.next_scene = "res://Scenes/BlackSmithsHouse.tscn"
	next_scene = "res://Scenes/BlackSmithsHouse.tscn"
func _on_Area2D_body_exited(body):
	anim.stop(true)
	$Bshouse.visible = false

func _use_dialogue():
	var dialogue = get_node("Well/WellDialogue")
	if dialogue:
		dialogue._start()

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		if can_accept:
			if PlayerStats.next_scene == "res://Scenes/BlackSmithsHouse.tscn":
				PlayerStats.visited_bs_house = true
			if PlayerStats.next_scene == "res://Scenes/AssHouse.tscn":
				PlayerStats.visited_katalina_house = true
			if entered_portal2:
				pass
			print(next_scene)
			Transition.load_scene(next_scene)#PlayerStats.next_scene)
		
			


func _on_Portal_body_entered(body):
	can_accept = true
	can_start_d = false
	#PlayerStats.next_scene = "res://NewTestWorld.tscn"
	next_scene = "res://NewTestWorld.tscn"
	anim.play("Portal")


func _on_Portal_body_exited(body):
	anim.stop(true)
	$PortalLabel.visible = false


func _on_Well_body_entered(body: Node) -> void:
	can_accept = false
	entered_well = true
	can_start_d = true


func _on_Well_body_exited(body: Node) -> void:
	entered_well = false
	can_start_d = false


func _on_Elder_body_entered(body: Node) -> void:
	pass # Replace with function body.


func _on_AssHouseDoor_body_entered(body: Node) -> void:
	#PlayerStats.next_scene == "res://Scenes/AssHouse.tscn"
	next_scene = "res://Scenes/AssHouse.tscn"
	can_accept = true
	can_start_d = false
	anim.play("AssHouse")


func _on_AssHouseDoor_body_exited(body: Node) -> void:
	can_accept = false
	anim.stop(true)
	$AssHouseDoor/AssHouseLabel.visible = false


func _on_Portal2_body_entered(body: Node) -> void:
	can_accept = true
	can_start_d = false
	PlayerStats.next_scene = "res://Scenes/WinterLevel1.tscn"#"res://Scenes/NewTestWorld.tscn"
	next_scene = PlayerStats.next_scene
	#next_scene = "res://Scenes/WinterLevel1.tscn"#"res://Scenes/NewTestWorld.tscn"

func _on_Portal2_body_exited(body: Node) -> void:
	can_accept = false
	anim.stop(true)
	$PortalLabel2.visible = false
