extends Node2D


var player_scene = PlayerStats.player_instance
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")
var dummy_scene = preload("res://Instance_Scenes/PracticeDummy.tscn")
var can_exit = false
var can_add_dummy = false



func _ready() -> void:
	PlayerStats.ground_color = "3a2122"
	#player = PlayerStats.player
	player = player_scene.instance()
	var target = anchor_scene.instance()
	var dummy = dummy_scene.instance()
	
	target.get_child(0).limit_right = 440
	target.get_child(0).limit_left = -395
	target.get_child(0).limit_top = -510
	target.get_child(0).limit_bottom = 400
	PlayerStats.visited_practice_tool = true
	dummy.global_position = Vector2(200, -20)
	get_child(0).add_child(player)
	PlayerStats.player = player
	player.global_position = global_position + Vector2(360, -165)
	get_child(0).add_child(target)
	get_node("Node").add_child(dummy)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if can_exit:
			PlayerStats.next_scene = "res://Scenes/AssHouse.tscn"
			Transition.load_scene(PlayerStats.next_scene)
		elif can_add_dummy:
			_add_dummy()

func _add_dummy() -> void:
	var dummy = dummy_scene.instance()
	dummy.global_position = player.global_position + Vector2(0, -40)
	get_node("Node").add_child(dummy)

func _on_Area2D_body_entered(body: Node) -> void:
	can_exit = true
	can_add_dummy = false


func _on_Area2D_body_exited(body: Node) -> void:
	can_exit = false
	can_add_dummy = true
