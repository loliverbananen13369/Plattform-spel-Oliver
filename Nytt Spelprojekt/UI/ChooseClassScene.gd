extends Control

onready var assassin = preload("res://Scenes/PlayerAssassin.tscn")
onready var mage = preload("res://Scenes/Player.tscn")

func _ready():
	BackgroundMusic.play_sound("MainMenuMusic")

func _on_AssassinButton_pressed():
	PlayerStats.player = assassin.instance()
	PlayerStats.is_assassin = true
	get_tree().change_scene("res://UI/MainMenuTest.tscn")
	


func _on_MageButton_pressed() -> void:
	PlayerStats.player = mage.instance()
	PlayerStats.is_mage = true
	get_tree().change_scene("res://UI/MainMenuTest.tscn")
