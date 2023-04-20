extends Node2D


var player_scene = PlayerStats.player_instance
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")
var can_talk_rock = false
var d_active = false
export (String) var next_scene 
export (String) var previous_scene
export (String) var footstep_sound

onready var mission_d = $NPCRock/MissionDialogue
onready var normal_d = $NPCRock/Dialogue


# Called when the node enters the scene tree for the first time.
func _ready():
	BackgroundMusic.play_sound("GameMusic")
	PlayerStats.ground_color = "a4dddb"
	PlayerStats.enemy_hpbar_color = "a4dddb"
	player = player_scene.instance()
	#player = PlayerStats.player
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(0, -20)
	target.get_child(0).limit_right = 1870
	target.get_child(0).limit_left = -26
	target.get_child(0).limit_bottom = 64
	target.get_child(0).limit_top = -640
	get_child(0).add_child(player)
	get_child(0).add_child(target)
	PlayerStats.player = player
	PlayerStats.next_scene = next_scene

func _input(event) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if can_talk_rock:
			_use_dialogue("MissionDialogue", "Rock")

func _use_dialogue(dia: String, type: String):
	var dialogue
	if type == "Rock":
		dialogue = get_child(2).get_node(dia)
	if dialogue:
		dialogue._start()

func _use_mission_dialogue():
	var dialogue = get_node("NPCRock/MissionDialogue")
	if dialogue:
		dialogue._start()

func _on_Dialogue_active(active) -> void:
	var value = AudioServer.get_bus_volume_db(0)
	if active:
		value -= 10
		AudioServer.set_bus_volume_db(0, value)
	else:
		value += 10
		AudioServer.set_bus_volume_db(0, value)

func _on_Area2D_body_entered(body: Node) -> void:
	can_talk_rock = true


func _on_Area2D_body_exited(body: Node) -> void:
	can_talk_rock = false
