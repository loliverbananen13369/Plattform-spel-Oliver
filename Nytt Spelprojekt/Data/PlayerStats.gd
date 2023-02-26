extends Node


const SAVE_PLAYER_STATS_FILE = "res://Data/PlayerStats.gd"
var game_data = {}

var ewqe1_learned = false
var ewqe2_learned = false
var is_assassin = false
var is_mage = false
var player_lvl = 1
var assassin_combo_ewqe = "comboewqe1"

func _ready() -> void:
	load_data()

func save_data():
	var file = File.new()
	file.open(SAVE_PLAYER_STATS_FILE, File.WRITE)
	file.store_var(game_data)
	file.close()


func load_data():
	var file = File.new()
	if not file.file_exists(SAVE_PLAYER_STATS_FILE):
		game_data = {
			"hp" : 100,
			"EWQE1": bool(false),
			"EWQE2": bool(false),
			"player_lvl" : 1,
			
			
			
		}
		save_data()
	file.open(SAVE_PLAYER_STATS_FILE, File.READ)
	#game_data = file.get_var()
	file.close()

