extends Node



const KILLS_NEEDED = 50
var kills_left = KILLS_NEEDED
var kills = 0

onready var label = $CanvasLayer/Label
onready var animp = $AnimationPlayer

func _ready() -> void:
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
	
	
