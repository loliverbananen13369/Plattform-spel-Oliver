extends Control

#Assassin

onready var celeb_audio = $AudioStreamPlayer
onready var celeb_audio_timer = $Timer
onready var layer = $CanvasLayer


var dark_tween_values := [0.9, 0.2]
var dark_tween_time := 4.0



const TEXT = preload("res://Instance_Scenes/NewSkillAssassin.tscn")

func _ready():
	celeb_audio_timer.connect("timeout", self, "on_celeb_audio_timer_finished")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SkillTree"):
		layer.visible = true
		
	if event.is_action_released("SkillTree"):
		layer.visible = false

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
	get_tree().current_scene.add_child(text)
	_new_skill()

func on_celeb_audio_timer_finished():
	celeb_audio.stop()


func _on_BasicAttack1_on_learned(_node):
	PlayerStats.assassin_smearsprite_q = "Smear6H"
	PlayerStats.assassin_smearsprite_w = "Smear6V"
	PlayerStats.assassin_smearsprite_e = "Smear6H"
	PlayerStats.assassin_basic_dmg = 8
	PlayerStats.life_steal = 1
	PlayerStats.emit_signal("AttackDamageChanged", "basic_attack_damage")
	_spawn_text("BasicAttack evolved! +1 life steal")


func _on_BasicAttack2_on_learned(_node):
	PlayerStats.assassin_smearsprite_q = "Smear8H"
	PlayerStats.assassin_smearsprite_w = "Smear8V"
	PlayerStats.assassin_smearsprite_e = "Smear8H"
	PlayerStats.assassin_basic_dmg = 12
	PlayerStats.emit_signal("AttackDamageChanged", "basic_attack_damage")
	_spawn_text("BasicAttack evolved!")

func _on_BasicAttack3_on_learned(_node):
	PlayerStats.assassin_smearsprite_q = "Smear10H"
	PlayerStats.assassin_smearsprite_w = "Smear10V"
	PlayerStats.assassin_smearsprite_e = "Smear10H"
	PlayerStats.assassin_basic_dmg = 15
	PlayerStats.life_steal = 5
	PlayerStats.emit_signal("AttackDamageChanged", "basic_attack_damage")
	_spawn_text("BasicAttack evolved! + 4 life steal" )

func _on_BasicAttack4_on_learned(_node):
	PlayerStats.assassin_smearsprite_q = "Smear9H"
	PlayerStats.assassin_smearsprite_w = "Smear9V"
	PlayerStats.assassin_smearsprite_e = "Smear9H"
	PlayerStats.assassin_basic_dmg = 20
	PlayerStats.emit_signal("AttackDamageChanged", "basic_attack_damage")
	_spawn_text("BasicAttack evolved!")

func _on_Clone1_on_learned(_node):
	PlayerStats.assassin_clone_targets = 1
	_spawn_text("Press Shift while comboing to spawn 1 clone")
	
func _on_Clone2_on_learned(_node):
	PlayerStats.assassin_clone_targets = 3
	_spawn_text("Clone amount increased slightly")

func _on_Clone3_on_learned(_node):
	PlayerStats.assassin_clone_targets = 8
	_spawn_text("Clone amount increased significantly")


func _on_Combo1_on_learned(_node):
	PlayerStats.assassin_combo_list.append([1,3,2,1])
	_spawn_text("Combo1 learned!")

func _on_Combo2_on_learned(_node):
	PlayerStats.assassin_combo_list.append([3, 1, 2, 3])
	_spawn_text("Combo2 learned!")


func _on_Combo3_on_learned(_node):
	PlayerStats.assassin_combo_list.append([2, 1, 3, 2])
	_spawn_text("Combo3 learned!")


func _on_DashAttack1_on_learned(_node) -> void:
	PlayerStats.assassin_can_dash_attack = true
	PlayerStats.assassin_dash_attack_dmg = 9
	_spawn_text("Press Q to dashattack")

func _on_DashAttack2_on_learned(_node) -> void:
	PlayerStats.assassin_dash_attack_dmg = 14
	_spawn_text("Dashattack slightly stronger")

func _on_DashAttack3_on_learned(_node) -> void:
	PlayerStats.assassin_dash_attack_dmg = 30
	_spawn_text("Dashattack signicantly stronger")
