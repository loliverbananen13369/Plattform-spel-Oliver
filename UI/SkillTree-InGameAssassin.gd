extends Node2D

#Assassin
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player_stats_save_file = PlayerStats.game_data
onready var celeb_audio = $AudioStreamPlayer
onready var celeb_audio_timer = $Timer


var dark_tween_values := [0.9, 0.2]
var dark_tween_time := 4.0


const TEXT = preload("res://Instance_Scenes/NewSkillAssassin.tscn")

# Called when the node enters the scene tree for the first time.

	
func _ready():
	celeb_audio_timer.connect("timeout", self, "on_celeb_audio_timer_finished")

func _new_skill() -> void:
	var env = get_node("/root/WorldEnv")
	env.new_skill_animation()
	celeb_audio.play()
	celeb_audio_timer.start(3)

func _spawn_text(skill: String):
	var text = TEXT.instance()
	var anim = text.get_node("AnimationPlayer")

	text.get_node("CanvasLayer/Label").text = str(skill)
	anim.play("default")
	#text.global_position = Vector2(205, 120)
	#text.global_position = global_position + Vector2(-direction_x*5, -30)
	get_tree().current_scene.add_child(text)
	_new_skill()

func _on_TextureButton_pressed() -> void:
	get_tree().change_scene("res://UI/MainMenuTest.tscn")

func _on_BasicAttack1_on_learned(node):
	PlayerStats.assassin_smearsprite_q = "Smear6H"
	PlayerStats.assassin_smearsprite_w = "Smear6V"
	PlayerStats.assassin_smearsprite_e = "Smear6H"
	_spawn_text("BasicAttack evolved!")


func _on_BasicAttack2_on_learned(node):
	PlayerStats.assassin_smearsprite_q = "Smear10H"
	PlayerStats.assassin_smearsprite_w = "Smear10V"
	PlayerStats.assassin_smearsprite_e = "Smear10H"
	_spawn_text("BasicAttack evolved!")

func _on_BasicAttack3_on_learned(node):
	PlayerStats.assassin_smearsprite_q = "Smear12H"
	PlayerStats.assassin_smearsprite_w = "Smear8V"
	PlayerStats.assassin_smearsprite_e = "Smear12H"
	_spawn_text("BasicAttack evolved!")

func _on_BasicAttack4_on_learned(node):
	PlayerStats.assassin_smearsprite_q = "Smear9H"
	PlayerStats.assassin_smearsprite_w = "Smear9V"
	PlayerStats.assassin_smearsprite_e = "Smear9H"
	_spawn_text("BasicAttack evolved!")

func _on_Clone1_on_learned(node):
	PlayerStats.assassin_clone_targets = 1
	
func _on_Clone2_on_learned(node):
	PlayerStats.assassin_clone_targets = int(PlayerStats.enemies_hit_by_player.size()/2)

func _on_Clone3_on_learned(node):
	PlayerStats.assassin_clone_targets = PlayerStats.enemies_hit_by_player.size()


func _on_Combo1_on_learned(node):
	PlayerStats.assassin_combo_list.append([1,3,2,1])
	_spawn_text("Combo1 learned!")

func _on_Combo2_on_learned(node):
	PlayerStats.assassin_combo_list.append([3, 1, 2, 3])
	_spawn_text("Combo2 learned!")


func _on_Combo3_on_learned(node):
	PlayerStats.assassin_combo_list.append([2, 1, 3, 2])
	_spawn_text("Combo2 learned!")

func on_celeb_audio_timer_finished():
	celeb_audio.stop()

