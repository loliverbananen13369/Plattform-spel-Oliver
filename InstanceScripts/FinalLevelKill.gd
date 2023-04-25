extends Node



const KILLS_NEEDED = 50
var kills_left = KILLS_NEEDED
var kills = 0

onready var label = $CanvasLayer/Label
onready var animp = $AnimationPlayer
onready var tween = $Tween

func _ready() -> void:
	PlayerStats.connect("EnemyDead", self, "_on_EnemyDead")
	_new_text()
	tween.interpolate_property(BackgroundMusic.GameMusic, "volume_db", -37.0, -50, 3.0)
	tween.start()
	yield(get_tree().create_timer(3.0), "timeout")
	BackgroundMusic.play_sound("FinalLevelMusic")
	
func _new_text() -> void:
	label.text = "Kill " + str(kills_left) + " More Golden skeletons to finish the game!"

func _on_EnemyDead(_type):
	kills += 1
	kills_left -=1
	if kills >= KILLS_NEEDED:
		get_tree().change_scene("res://Instance_Scenes/EndScene.tscn")
		return
	_new_text()
	animp.stop()
	animp.play("Kill")
	

func _on_Tween_tween_completed(object, key):
	BackgroundMusic.GameMusic.playing = false
