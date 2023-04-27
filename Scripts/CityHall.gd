extends Node2D

var can_accept = false
var entered_bs_house = false
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

func _ready(): #Väldigt mycket debug och connectar signar
	if PlayerStats.first_time:
		_load_cutscene(1)
		yield(get_tree().create_timer(40.5), "timeout") 
	set_process_unhandled_input(true)
	$Bshouse.rect_position.x = -87#(-87, -110)
	$Bshouse.visible = false
	player = player_scene.instance()
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(900, -20)
	if PlayerStats.visited_tutorial:
		player.global_position = global_position + Vector2(100, -20)
		PlayerStats.visited_tutorial = false
	if PlayerStats.visited_bs_house == true:
		player.global_position = global_position  + Vector2(0, -20)
		PlayerStats.visited_bs_house = false
	if PlayerStats.visited_katalina_house == true:
		player.global_position = global_position + Vector2(-367, -24)
		PlayerStats.visited_katalina_house = false
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
	Quests.connect("ClassChosen2", self, "_on_class_chosen")
	Quests.connect("TutorialFinished2", self, "_on_tutorial_finished")
	PlayerStats.ground_color = "752438"
	PlayerStats.footsteps_sound = "res://Sounds/ImportedSounds/Footsteps/Free Footsteps Pack/Grass Running.wav"
	PlayerStats.connect("ChooseClass", self, "_on_choose_class")
	Quests.emit_signal("CityHallLoaded")
	if not BackgroundMusic.MainMenuMusic.playing:
		BackgroundMusic.play_sound("MainMenuMusic")

func _load_cutscene(time: int): #Kör cutscenen
	if time == 1:
		cutscene_finished = false
		var player_intro = intro_player_scene.instance()
		var bar = blackbar.instance()
		add_child(player_intro)
		player_intro.global_position = Vector2(950, -20)
		player_intro.get_node("AnimationPlayer")
		yield(get_tree().create_timer(6), "timeout") #6
		$Elder.flip_h = true
		yield(get_tree().create_timer(34), "timeout") # 34
		PlayerStats.first_time = false
		emit_signal("cutscene")

func _on_Area2D_body_entered(body): #När spelaren stiger på blacksmiths house
	if body.is_in_group("Player"):
		next_scene = "res://Levels/BlackSmithsHouse.tscn"
		can_accept = true
		can_start_d = false
		anim.play("BSHouse")

func _on_Area2D_body_exited(body): #När spelaren går ur blacksmits house area
	can_accept = false
	anim.stop(true)
	$Bshouse.visible = false

func _input(event): 
	if Input.is_action_just_pressed("ui_accept"):
		if can_accept and cutscene_finished:
			Transition.load_scene(next_scene)
	

func _on_Well_body_entered(body: Node) -> void: #När spelaren stiger på brunn-arean
	if body.is_in_group("Player"):
		$Well.can_start = true
		can_accept = false
		entered_well = true
		can_start_d = true
		PlayerStats.can_s_d = true


func _on_Well_body_exited(body: Node) -> void: #När spelaren går ur brunn-arean
	$Well.can_start = false
	entered_well = false
	can_start_d = false
	PlayerStats.can_s_d = false



func _on_AssHouseDoor_body_entered(body: Node) -> void: #När spelaren stiger på katalinas hus
	if body.is_in_group("Player"):
		next_scene = "res://Levels/AssHouse.tscn"
		can_accept = true
		can_start_d = false
		anim.play("AssHouse")


func _on_AssHouseDoor_body_exited(body: Node) -> void: #När splearen går ur katalinas husarea
	can_accept = false
	anim.stop(true)
	$AssHouseDoor/AssHouseLabel.visible = false



func _on_CityHall_cutscene() -> void: #Kollar när cutscenen är klar
	cutscene_finished = true
	Transition.load_scene("res://Levels/Tutorial.tscn")

func _on_tutorial_finished(): #Kollar om questen kan köras
	Quests.send_quest_available()

func _on_class_chosen(): #När en klass har blivit val
	Quests.get_node("Hubby").get_node("TalkQuest").emit_signal("talk_finished")

func _on_choose_class() -> void: #När spelaren ska välja klass
	Transition.load_scene("res://UI/ChooseClassScene.tscn")
