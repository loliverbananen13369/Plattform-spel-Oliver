extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MENU_BACK = preload("res://Sounds/ImportedSounds/Retro2.wav")
const BUTTON_PRESSED = preload("res://Sounds/ImportedSounds/Abstract2.wav")

onready var mainmenu = $MainMenu
onready var optionsmenu = $Options
onready var soundplayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$MainMenu/StartButton.grab_focus()


func _on_StartButton_pressed():
	get_tree().change_scene("res://Scenes/NewTestWorld.tscn")
	soundplayer.pitch_scale = 0.7
	soundplayer.play()


func _on_OptionsButton_pressed():
	mainmenu.hide()
	optionsmenu.show()
	soundplayer.pitch_scale = 0.7
	soundplayer.play()


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_MasterSlider_value_changed(value):
	if value == -30:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_volume_db(0, value)


func _on_BackButton_pressed():
	mainmenu.show()
	optionsmenu.hide()
	soundplayer.pitch_scale = 0.5
	soundplayer.play()
