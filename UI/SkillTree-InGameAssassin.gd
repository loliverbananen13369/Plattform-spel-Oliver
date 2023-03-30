extends Node2D

#Assassin
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player_stats_save_file = PlayerStats.game_data

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_TextureButton_pressed() -> void:
	get_tree().change_scene("res://UI/MainMenuTest.tscn")

func _on_BasicAttack1_on_learned(node):
	PlayerStats.assassin_smearsprite_q = "Smear6H"
	PlayerStats.assassin_smearsprite_w = "Smear6V"
	PlayerStats.assassin_smearsprite_e = "Smear6H"


func _on_BasicAttack2_on_learned(node):
	PlayerStats.assassin_smearsprite_q = "Smear10H"
	PlayerStats.assassin_smearsprite_w = "Smear10V"
	PlayerStats.assassin_smearsprite_e = "Smear10H"


func _on_BasicAttack3_on_learned(node):
	PlayerStats.assassin_smearsprite_q = "Smear12H"
	PlayerStats.assassin_smearsprite_w = "Smear8V"
	PlayerStats.assassin_smearsprite_e = "Smear12H"


func _on_BasicAttack4_on_learned(node):
	PlayerStats.assassin_smearsprite_q = "Smear9H"
	PlayerStats.assassin_smearsprite_w = "Smear9V"
	PlayerStats.assassin_smearsprite_e = "Smear9H"


func _on_Clone1_on_learned(node):
	PlayerStats.assassin_clone_targets = 1
	
func _on_Clone2_on_learned(node):
	PlayerStats.assassin_clone_targets = int(PlayerStats.enemies_hit_by_player.size()/2)

func _on_Clone3_on_learned(node):
	PlayerStats.assassin_clone_targets = PlayerStats.enemies_hit_by_player.size()
