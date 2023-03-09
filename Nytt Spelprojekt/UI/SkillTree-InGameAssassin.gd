extends Node2D

#Assassin
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player_stats_save_file = PlayerStats.game_data

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_TextureButton_pressed() -> void:
	get_tree().change_scene("res://UI/MainMenuTest.tscn")


