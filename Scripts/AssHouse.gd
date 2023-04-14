extends Node2D


var player_scene = PlayerStats.player_instance
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")
var in_range_for_talk
var can_exit = false
var can_enter_new = false
onready var audiop = $Area2D/AudioStreamPlayer2D


func _ready():
	PlayerStats.visited_katalina_house = true
	PlayerStats.ground_color = "3a2122"
	PlayerStats.footsteps_sound = "res://Sounds/ImportedSounds/Footsteps/Free Footsteps Pack/Gravel - Run.wav"
	player = player_scene.instance()
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(-365, -40)
	if PlayerStats.visited_practice_tool:
		player.global_position = global_position + Vector2(735, 310)
		PlayerStats.visited_practice_tool = false
	target.get_child(0).limit_right = 820
	target.get_child(0).limit_left = -480
	target.get_child(0).limit_top = -200
	target.get_child(0).limit_bottom = 400
	get_child(0).add_child(player)
	PlayerStats.player = player
	get_child(0).add_child(target)
	yield(get_tree().create_timer(0.5),"timeout")
	in_range_for_talk = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if in_range_for_talk:
			_use_dialogue()
		if can_exit:
			PlayerStats.next_scene = "res://Levels/CityHall.tscn"
			Transition.load_scene(PlayerStats.next_scene)
			#get_tree().change_scene(PlayerStats.next_scene)
		if can_enter_new:
			PlayerStats.next_scene = "res://Levels/PracticeTool.tscn"
			Transition.load_scene(PlayerStats.next_scene)

func _use_dialogue():
	var dialogue = get_node("Dialogue")
	if dialogue:
		dialogue._start()

func _on_Dialogue_active(active) -> void:
	var value = AudioServer.get_bus_volume_db(0)
	if active:
		value -= 10
		AudioServer.set_bus_volume_db(0, value)
		audiop.playing = true
	else:
		value += 10
		AudioServer.set_bus_volume_db(0, value)
		audiop.playing = false

func _on_Area2D_body_entered(body):
	in_range_for_talk = true
	can_exit = false
	can_enter_new = false


func _on_Area2D_body_exited(body):
	in_range_for_talk = false


func _on_Door_body_entered(body):
	can_exit = true
	in_range_for_talk = false
	can_enter_new = false


func _on_Door_body_exited(body):
	can_exit = false

func _on_Door2_body_entered(body: Node) -> void:
	can_enter_new = true
	can_exit = false
	in_range_for_talk = false
	$Door2/Label.visible = true
	$AnimationPlayer.play("default")


func _on_Door2_body_exited(body: Node) -> void:
	can_enter_new = false
	$AnimationPlayer.stop(true)
	$Door2/Label.visible = false
