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
var cutscene_finished = true

var anchor_scene = preload("res://Scenes/Anchor.tscn")
var intro_player_scene = preload("res://Scenes/CutScenePlayer.tscn")
var blackbar = preload("res://Instance_Scenes/CutSceneBlackBars.tscn")

signal cutscene()

var next_scene
onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	Quests.connect("quest_available", self, "on_quest_available")
	#Quests.emit_signal("quest_available", "Hubby")
	Quests.send_quest_available()
	PlayerStats.ground_color = "752438"
	PlayerStats.footsteps_sound = "res://Sounds/ImportedSounds/Footsteps/Free Footsteps Pack/Grass Running.wav"
	#if PlayerStats.first_time:
	#	_load_cutscene(1)
	set_process_unhandled_input(true)

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
	get_node("PlayerNode").add_child(player)
	get_node("PlayerNode").add_child(target)
	#get_child(1).add_child(target)
	PlayerStats.player = player
	PlayerStats.visited_bs_house = false
	PlayerStats.visited_katalina_house = false

func _load_cutscene(time: int):
	if time == 1:
		cutscene_finished = false
		var player_intro = intro_player_scene.instance()
		var bar = blackbar.instance()
		#add_child(bar)
		add_child(player_intro)
		player_intro.global_position = Vector2(950, -20)
		player_intro.get_node("AnimationPlayer")
		yield(get_tree().create_timer(6), "timeout")
		$Elder.flip_h = true
		yield(get_tree().create_timer(15), "timeout")
		PlayerStats.first_time = false
		emit_signal("cutscene")

func _on_Area2D_body_entered(body):
	#PlayerStats.next_scene = "res://Scenes/BlackSmithsHouse.tscn"
	next_scene = "res://Levels/BlackSmithsHouse.tscn"
	can_accept = true
	can_start_d = false
	anim.play("BSHouse")
func _on_Area2D_body_exited(body):
	can_accept = false
	anim.stop(true)
	$Bshouse.visible = false

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		if can_accept and cutscene_finished:
			if entered_portal2:
				pass
			Transition.load_scene(next_scene)#PlayerStats.next_scene)
	
			


func _on_Portal_body_entered(body):
	if body.is_in_group("Player"):
		can_accept = true
		can_start_d = false
		#PlayerStats.next_scene = "res://NewTestWorld.tscn"
		next_scene = "res://NewTestWorld.tscn"
		anim.play("Portal")


func _on_Portal_body_exited(body):
	can_accept = false
	anim.stop(true)
	$PortalLabel.visible = false


func _on_Well_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		$Well.can_start = true
		can_accept = false
		entered_well = true
		can_start_d = true
		PlayerStats.can_s_d = true


func _on_Well_body_exited(body: Node) -> void:
	$Well.can_start = false
	entered_well = false
	can_start_d = false
	PlayerStats.can_s_d = false

func _on_Elder_body_entered(body: Node) -> void:
	pass # Replace with function body.


func _on_AssHouseDoor_body_entered(body: Node) -> void:
	#PlayerStats.next_scene == "res://Scenes/AssHouse.tscn"
	if body.is_in_group("Player"):
		next_scene = "res://Levels/AssHouse.tscn"
		can_accept = true
		can_start_d = false
		anim.play("AssHouse")


func _on_AssHouseDoor_body_exited(body: Node) -> void:
	can_accept = false
	anim.stop(true)
	$AssHouseDoor/AssHouseLabel.visible = false


func _on_Portal2_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		can_accept = true
		can_start_d = false
		PlayerStats.next_scene = "res://Levels/WinterLevel1.tscn"#"res://Scenes/NewTestWorld.tscn"
		next_scene = PlayerStats.next_scene
		#next_scene = "res://Scenes/WinterLevel1.tscn"#"res://Scenes/NewTestWorld.tscn"

func _on_Portal2_body_exited(body: Node) -> void:
	can_accept = false
	anim.stop(true)
	$PortalLabel2.visible = false


func _on_CityHall_cutscene() -> void:
	cutscene_finished = true
	Transition.load_scene("res://Levels/Tutorial.tscn")

func on_quest_available(person) -> void:
	pass
