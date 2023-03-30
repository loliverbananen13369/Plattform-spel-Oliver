extends Control

onready var assassin = preload("res://Scenes/PlayerAssassin.tscn")
onready var mage = preload("res://Scenes/Player.tscn")
onready var soundplayer = $AudioStreamPlayer

func _ready():
	BackgroundMusic.play_sound("MainMenuMusic")

func _on_AssassinButton_pressed():
	PlayerStats.player = assassin.instance()
	PlayerStats.player_instance = preload("res://Scenes/PlayerAssassin.tscn")
	PlayerStats.is_assassin = true
	soundplayer.pitch_scale = 0.7
	soundplayer.play()
	Transition.load_scene("res://Levels/CityHall.tscn")

	#get_tree().change_scene("res://Levels/CityHall.tscn")#("res://UI/MainMenuTest.tscn")
	


func _on_MageButton_pressed() -> void:
	PlayerStats.player = mage.instance()
	PlayerStats.player_instance = preload("res://Scenes/Player.tscn")
	PlayerStats.is_mage = true
	soundplayer.pitch_scale = 0.7
	soundplayer.play()
	Transition.load_scene("res://Levels/CityHall.tscn")
	#get_tree().change_scene("res://Levels/CityHall.tscn")#get_tree().change_scene("res://UI/MainMenuTest.tscn")
