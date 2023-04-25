extends Node

var voice_pitch_scale = 1 
var db = -40.0
var pitch = 1.0
onready var tween = $Tween
onready var MainMenuMusic = $MainMenuMusic
onready var GameMusic = $GameMusic
onready var FinalLevelMusic = $FinalLevelMusic

var play_game_music = false
var play_mainmenu_music = false
var rng = RandomNumberGenerator.new()

var gamemusic_music_list = [preload("res://The Haunt - Balanced - Medium - wav/01-LANDR-01 - Last to Fall (F) 200MS-Balanced-Medium.wav"), preload("res://The Haunt - Balanced - Medium - wav/02-LANDR-02 - Own Blood (F) 200MS-Balanced-Medium.wav"), preload("res://The Haunt - Balanced - Medium - wav/05-LANDR-05 - Crystal Garden (F) 200MS-Balanced-Medium.wav"), preload("res://The Haunt - Balanced - Medium - wav/08-LANDR-08 - Way of the Wolf (F) 200MS-Balanced-Medium.wav"), preload("res://The Haunt - Balanced - Medium - wav/10-LANDR-10 - First to Rise (F) 200MS-Balanced-Medium.wav")]
var background_music_list = [preload("res://Sounds/ImportedSounds/Background/chinese-peaceful-heartwarming-harp-asian-emotional-traditional-music-21041.mp3"), preload("res://Sounds/ImportedSounds/Background/magic-in-the-air-43177.mp3"), preload("res://Sounds/ImportedSounds/Background/my-little-garden-of-eden-112845.mp3")]

func play_sound(sound: String) -> void:
	for node in get_children():
		if node is AudioStreamPlayer:
			node.stop()
	if sound == "GameMusic":
		db = -37.0
		_randomize_gamemusic_sound()
		play_game_music = true
		play_mainmenu_music = false
		MainMenuMusic.stop()
	if sound == "MainMenuMusic":
		db = -20.5
		_randomize_mainmenumusic_sound()
		play_game_music = false
		play_mainmenu_music = true
		GameMusic.stop()
	if sound == "FinalLevelMusic":
		play_game_music = false
		play_mainmenu_music = false
		db = -35
	get_node(sound).volume_db = -60
	tween.interpolate_property(get_node(sound), "volume_db", -60, db, 2.0)
	tween.start()
	get_node(sound).play()

func _randomize_gamemusic_sound():
	rng.randomize()
	var random_sound = rng.randi_range(0, gamemusic_music_list.size() - 1)
	GameMusic.stream = gamemusic_music_list[random_sound]

func _randomize_mainmenumusic_sound():
	rng.randomize()
	var random_sound = rng.randi_range(0, background_music_list.size() - 1)
	MainMenuMusic.stream = background_music_list[random_sound]

func _on_GameMusic_finished():
	if play_game_music:
		_randomize_gamemusic_sound()
		GameMusic.playing = true

func _on_MainMenuMusic_finished():
	if play_mainmenu_music:
		_randomize_mainmenumusic_sound()
		MainMenuMusic.playing = true
