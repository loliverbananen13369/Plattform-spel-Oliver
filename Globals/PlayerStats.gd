extends Node



var game_data = {}

var player_instance = preload("res://Scenes/PlayerIntroBody.tscn")#("res://Scenes/Player.tscn")# ## ("res://Scenes/PlayerAssassin.tscn") #
var player



var is_assassin = false
var is_mage = false
var current_lvl = 1
var current_xp = 0
var xp_needed = 40
var hp = 100
var life_steal = 0

signal PlayerHurt()
signal EnemyHurt()
signal EnemyDead(test_enemy)
signal GolemStatus(active)
signal TutorialFinished()
signal ChooseClass()
signal AttackDamageChanged(type)

var master_vol_value = 0

var enemy_who_hurt
var enemy_who_hurt_list = []
var enemies_hit_by_player = []
var enemies_for_golem = []

var skilltree_points = 0

var assassin_can_dash_attack = false
var assassin_combo_ewqe = "comboewqe1"
var assassin_combo1_learned = "hej"
var assassin_smearsprite_q = "Smear7H"
var assassin_smearsprite_w = "Smear7V"
var assassin_smearsprite_e = "Smear3H"
var assassin_basic_dmg = 5
var assassin_dash_attack_dmg = 10
var assassin_combo1_dmg = 10
var assassin_combo2_dmg = 10
var assassin_combo3_dmg = 10
var assassin_clone_targets = 1
var assassin_combo_list = []
var assassin_current_basic_attack = 0



var mage_basic_dmg = 5
var empowered_skeleton = false
var dead_skeleton_dmg = 3
var dead_skeleton_exp_dmg = 5
var golem_dmg = 5
var golem_life_time = 5.0
var ability1_learned = false
var ability2_learned = false
var golem_active = false
var can_add_ls = false
var can_add_dark = false
var can_add_holy = false
var can_thrust = false
var can_add_golem = false


var visited_bs_house = false
var visited_tutorial = false
var visited_katalina_house = false
var visited_practice_tool = false
var next_scene = "res://Levels/CityHall.tscn"#"res://UI/ChooseClassScene.tscn"#"res://Levels/CityHall.tscn"
var prev_scene = "res://Levels/CityHall.tscn"


var footsteps_sound = preload("res://Sounds/ImportedSounds/Footsteps/Free Footsteps Pack/Snow.wav")



var enemy_hpbar_color 
var winter_skin = preload("res://Enemy/EnemySkins/SkeletonWarriorWinter.tres")
var green_skin = preload("res://Enemy/EnemySkins/SkeletonWarriorGreen.tres")
var winter_hit = preload("res://Enemy/EnemySkins/EnemyHitWinter.tres")
var green_hit = preload("res://Enemy/EnemySkins/EnemyHitGreen.tres")

var ground_color
var enemy_skin = winter_skin#"res://EnemySkins/SkeletonWarriorGreen.tres"
var enemy_hit = winter_hit

var first_time = true
var can_s_d = false

func _ready() -> void:
	pass
	#load_data()
"""
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
"""
