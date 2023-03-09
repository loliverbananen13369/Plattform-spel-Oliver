extends Node2D

#mage
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player_stats_save_file = PlayerStats.game_data

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_TextureButton_pressed() -> void:
	get_tree().change_scene("res://UI/MainMenuTest.tscn")


func _on_Acid_2_on_learned(node) -> void:
	print("Acid2 learned")
	

func _on_Acid_5_on_learned(node):
	print("Acid5 learned")
