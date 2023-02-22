extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_TextureButton_pressed() -> void:
	get_tree().change_scene("res://UI/MainMenuTest.tscn")


func _on_Acid_2_on_learned(node) -> void:
	PlayerStats.ewqe1_learned = true


func _on_Acid_5_on_learned(node):
	PlayerStats.ewqe2_learned = true



