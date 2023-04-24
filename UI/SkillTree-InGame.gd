extends Control

#Necromancer

onready var celeb_audio = $AudioStreamPlayer
onready var celeb_audio_timer = $Timer
onready var layer = $CanvasLayer
onready var splabel = $CanvasLayer/SPLabel

const TEXT = preload("res://Instance_Scenes/NewSkillAssassin.tscn")


func _ready():
	celeb_audio_timer.connect("timeout", self, "on_celeb_audio_timer_finished")
	splabel.text = "Skillpoints: " + str(PlayerStats.skilltree_points)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SkillTree"):
		layer.visible = true
		
	if event.is_action_released("SkillTree"):
		layer.visible = false

func _new_skill() -> void:
	splabel.text = "Skillpoints: " + str(PlayerStats.skilltree_points)
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


func _on_Acid2_on_learned(node):
	PlayerStats.ability1_learned = true
	PlayerStats.emit_signal("AttackDamageChanged", "ability1_learned")
	_spawn_text("New Ability! Press A to try")

func _on_Acid5_on_learned(node):
	PlayerStats.ability2_learned = true
	PlayerStats.emit_signal("AttackDamageChanged", "ability2_learned")
	_spawn_text("Press S for stronger ability!")

func _on_LifeSteal_on_learned(node):
	PlayerStats.can_add_ls = true
	PlayerStats.emit_signal("AttackDamageChanged", "can_add_ls")
	_spawn_text("Lifesteal unlocked!")

func _on_Skeleton1_on_learned(node):
	PlayerStats.dead_skeleton_dmg = 12
	PlayerStats.dead_skeleton_exp_dmg = 15
	PlayerStats.empowered_skeleton = true
	PlayerStats.emit_signal("AttackDamageChanged", "dead_skeleton")
	_spawn_text("Saucy skeleton!")

func _on_Golem1_on_learned(node):
	PlayerStats.can_add_golem = true
	PlayerStats.emit_signal("AttackDamageChanged", "can_add_golem")
	_spawn_text("Press G to summon Golem!")

func _on_Skeleton2_on_learned(node):
	PlayerStats.dead_skeleton_dmg = 7
	PlayerStats.emit_signal("AttackDamageChanged", "dead_skeleton")
	_spawn_text("Skeletons deal more!")

func _on_Skeleton3_on_learned(node):
	PlayerStats.dead_skeleton_exp_dmg = 10
	PlayerStats.emit_signal("AttackDamageChanged", "dead_skeleton")
	_spawn_text("Skeletons upgraded!")

func _on_Golem3_on_learned(node):
	PlayerStats.golem_dmg = 8
	PlayerStats.emit_signal("AttackDamageChanged", "golem")
	_spawn_text("More damage. Rock solid!")

func _on_Golem2_on_learned(node):
	PlayerStats.golem_life_time = 15.0
	PlayerStats.emit_signal("AttackDamageChanged", "golem")
	_spawn_text("Longer lifetime. Rock solid!")

func _on_Golem4_on_learned(node):
	PlayerStats.golem_life_time = 25.0
	PlayerStats.golem_dmg = 15
	PlayerStats.emit_signal("AttackDamageChanged", "golem")
	_spawn_text("Stronger stone. Rock Solid!")

func _on_Dark_on_learned(node):
	PlayerStats.can_add_dark = true
	PlayerStats.emit_signal("AttackDamageChanged", "dark")
	_spawn_text("Press 2 for more damage...")

func _on_Holy_on_learned(node):
	PlayerStats.can_add_holy = true
	PlayerStats.emit_signal("AttackDamageChanged", "holy")
	_spawn_text("Press 3 and try")

func _on_Thrust_on_learned(node):
	PlayerStats.can_thrust = true
	PlayerStats.emit_signal("AttackDamageChanged", "thrust")
	_spawn_text("Press D for cool effect!")

