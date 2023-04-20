extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
const KILLS_NEEDED = 1
var kills_left = KILLS_NEEDED
var kills = 0

onready var label = $CanvasLayer/Label
onready var animp = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerStats.skilltree_points = 20
	PlayerStats.connect("EnemyDead", self, "_on_EnemyDead")
	_new_text()
	
func _new_text() -> void:
	label.text = "Kill " + str(kills_left) + " More Golden skeletons to finish the game!"

func _on_EnemyDead(_type):
	kills += 1
	kills_left = KILLS_NEEDED - kills
	if kills <= KILLS_NEEDED:
		get_tree().change_scene("res://Instance_Scenes/EndScene.tscn")
		return
	_new_text()
	animp.stop()
	animp.play("Kill")
	
	
