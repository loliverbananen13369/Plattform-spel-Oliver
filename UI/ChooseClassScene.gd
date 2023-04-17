extends Control

onready var assassin = preload("res://Scenes/PlayerAssassin.tscn")
onready var mage = preload("res://Scenes/Player.tscn")
onready var soundplayer = $AudioStreamPlayer
onready var label = $CanvasLayer/Label

func _ready():
	$CanvasLayer/AssassinButton.grab_focus()

func _on_AssassinButton_pressed():
	PlayerStats.player = assassin.instance()
	PlayerStats.player_instance = preload("res://Scenes/PlayerAssassin.tscn")
	PlayerStats.is_assassin = true
	soundplayer.pitch_scale = 0.7
	soundplayer.play()
	Transition.load_scene("res://Levels/CityHall.tscn")
	Quests.emit_signal("ClassChosen")
	#get_tree().change_scene("res://Levels/CityHall.tscn")#("res://UI/MainMenuTest.tscn")
	


func _on_MageButton_pressed() -> void:
	PlayerStats.player = mage.instance()
	PlayerStats.player_instance = preload("res://Scenes/Player.tscn")
	PlayerStats.is_mage = true
	soundplayer.pitch_scale = 0.7
	soundplayer.play()
	Transition.load_scene("res://Levels/CityHall.tscn")
	Quests.emit_signal("ClassChosen")
	#get_tree().change_scene("res://Levels/CityHall.tscn")#get_tree().change_scene("res://UI/MainMenuTest.tscn")


func _on_MageButton_focus_entered():
	label.text = "A class with strong abilities, extraordinarie buffs and can even summon the dead"

func _on_MageButton_focus_exited():
	pass # Replace with function body.

func _on_AssassinButton_focus_entered():
	label.text = "A class with high mobility, crushing attacks and divine combos"

func _on_AssassinButton_focus_exited():
	pass # Replace with function body.
