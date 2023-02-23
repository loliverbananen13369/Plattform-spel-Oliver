extends Control



func _on_AssassinButton_pressed():
	PlayerStats.is_assassin = true
	get_tree().change_scene("res://UI/MainMenuTest.tscn")
	


func _on_MageButton_pressed() -> void:
	PlayerStats.is_mage = true
	get_tree().change_scene("res://UI/MainMenuTest.tscn")
