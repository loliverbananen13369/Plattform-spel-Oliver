extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var player_stats_save_file = PlayerStats.game_data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.






func _on_TextureButton_pressed() -> void:
	get_tree().change_scene("res://UI/MainMenuTest.tscn")


func _on_Acid_2_on_learned(node) -> void:
	PlayerStats.ewqe1_learned = true
	

func _on_Acid_5_on_learned(node):
	PlayerStats.ewqe2_learned = true





