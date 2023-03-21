extends Node2D


var player_scene = PlayerStats.player_instance
var player
var anchor_scene = preload("res://Scenes/Anchor.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	player = player_scene.instance()
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(0, -20)
	target.get_child(0).limit_right = 1860
	target.get_child(0).limit_left = 0
	target.get_child(0).limit_bottom = 64
	target.get_child(0).limit_top = -640
	get_child(0).add_child(player)
	get_child(0).add_child(target)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
