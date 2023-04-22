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

func _input(event):
	if event.is_action_pressed("SkillTree"):
		mainmenu.visible = false
	if event.is_action_released("SkillTree"):
		mainmenu.visible = true

func _on_StartButton_pressed():
	#get_tree().change_scene("res://Scenes/CityHall.tscn")
	soundplayer.pitch_scale = 0.7
	soundplayer.play()
	get_parent()._pause()


func _on_OptionsButton_pressed():
	mainmenu.visible = false
	optionsmenu.visible = true
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
	PlayerStats.master_vol_value = value
func _on_VoicePitch_value_changed(value):
	BackgroundMusic.voice_pitch_scale = value
	#AudioServer.set_bus(AudioServer.get_bus_index("Voice"), value)

func _on_BackButton_pressed():
	mainmenu.visible = true
	optionsmenu.visible = false
	soundplayer.pitch_scale = 0.5
	soundplayer.play()

