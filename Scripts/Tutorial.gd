extends Node2D

var player_scene = preload("res://Scenes/PlayerIntroBody.tscn")

var player
var sprite
var area

var croucharea = false

var anchor_scene = preload("res://Scenes/Anchor.tscn")
var portal_scene = preload("res://Instance_Scenes/PortalAuto.tscn")

var next_scene
var walk_sprite_values = [-146, -136]

var attack_pressed = []

signal entered_attack()


onready var animp = $AnimationPlayer

var test = 0

func _ready() -> void: #När scenen först spelas. 
	BackgroundMusic.play_sound("MainMenuMusic")
	PlayerStats.next_scene = "res://Levels/CityHall.tscn"
	PlayerStats.ground_color = "788830"
	PlayerStats.enemy_hpbar_color = "788830"
	player = player_scene.instance()
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(0, -20)
	target.get_child(0).limit_right = 2720 #Ger kameran begränsningar
	target.get_child(0).limit_left = -280 
	target.get_child(0).limit_bottom = 40
	target.get_child(0).limit_top = -200
	get_child(1).add_child(player)
	get_child(1).add_child(target)
	PlayerStats.player = player
	PlayerStats.player_instance = player_scene
	PlayerStats.connect("TutorialFinished", self, "on_TutorialFinished")
	PlayerStats.visited_tutorial = true



func _input(event: InputEvent) -> void: #Kollar om spelaren crouchar i crouch arean. Om den gör det, visas "press shift to jump down" istället för "Press 'crouch' to crouch"
	if croucharea:
		if Input.is_action_just_pressed("Crouch"):
			$CrouchArea/Sprite.visible = false
			animp.stop(true)
			$CrouchShiftArea/Sprite.visible = true
			animp.play("CrouchShiftArea")
		if Input.is_action_just_released("Crouch"):
			$CrouchShiftArea/Sprite.visible = false
			animp.stop(true)
			$CrouchArea/Sprite.visible = true
			animp.play("CrouchArea")
	

#Här nedan kommer "signaler" när spelaren har stigit in i en viss area. Beroende på area, kommer arean att visa / berätta vad spelaren ska göra
func _on_WalkArea_body_entered(body) -> void: 
	if body.is_in_group("Player"):
		$WalkArea/Sprite.visible = true
		animp.play("WalkArea")

func _on_WalkArea_body_exited(body) -> void:
	if body.is_in_group("Player"):
		$WalkArea/Sprite.visible = false
		animp.stop(true)


func _on_JumpArea_body_entered(body) -> void:
	if body.is_in_group("Player"):
		$JumpArea/Sprite.visible = true
		animp.play("JumpArea")


func _on_JumpArea_body_exited(body) -> void:
	if body.is_in_group("Player"):
		$JumpArea/Sprite.visible = false
		animp.stop(true)


func _on_CrouchArea_body_entered(body) -> void:
	if body.is_in_group("Player"):
		$CrouchArea/Sprite.visible = true
		animp.play("CrouchArea")
		croucharea = true



func _on_CrouchArea_body_exited(body) -> void:
	if body.is_in_group("Player"):
		croucharea = false
		$CrouchArea/Sprite.visible = false
		$CrouchShiftArea/Sprite.visible = false
		animp.stop(true)


func _on_DashArea_body_entered(body) -> void:
	if body.is_in_group("Player"):
		$DashArea/Sprite.visible = true
		animp.play("DashArea")

func _on_DashArea_body_exited(body) -> void:
	if body.is_in_group("Player"):
		$DashArea/Sprite.visible = false
		animp.stop(true)


func _on_AttackArea_body_entered(body):
	if body.is_in_group("Player"):
		$AttackArea/Sprite.visible = true
		animp.play("AttackArea")



func _on_AttackArea_body_exited(body):
	if body.is_in_group("Player"):
		$AttackArea/Sprite.visible = false
		animp.stop(true)

func on_TutorialFinished():
	var portal = portal_scene.instance()
	portal.next_scene = PlayerStats.next_scene
	portal.global_position = Vector2(2404, -64)
	add_child(portal)
	Quests.emit_signal("TutorialFinished") #Skickar till Quests att tutorialen är klar. Quests kommer sedan vänta tills cityhall har laddat, och sedan skicka ut en till signal som säger åt den att nästa konversation ska vara 'choose_class'

