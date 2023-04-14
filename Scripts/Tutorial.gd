extends Node2D

var player_scene = preload("res://Scenes/PlayerIntroBody.tscn")

var player
var sprite
var area

var croucharea = false

var anchor_scene = preload("res://Scenes/Anchor.tscn")
var portal_scene = preload("res://Scenes/PortalNext.tscn")

var next_scene
var walk_sprite_values = [-146, -136]

var attack_pressed = []

signal entered_attack()


onready var animp = $AnimationPlayer


var test = 0

func _ready() -> void:
	BackgroundMusic.play_sound("MainMenuMusic")
	PlayerStats.next_scene = "res://UI/ChooseClassScene.tscn"
	PlayerStats.ground_color = "788830"
	PlayerStats.enemy_hpbar_color = "788830"
	player = player_scene.instance()
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(0, -20)#Vector2(0, -20)
	target.get_child(0).limit_right = 2720
	target.get_child(0).limit_left = -280
	target.get_child(0).limit_bottom = 40
	target.get_child(0).limit_top = -200
	get_child(1).add_child(player)
	get_child(1).add_child(target)
	PlayerStats.player = player
	PlayerStats.connect("TutorialFinished", self, "on_TutorialFinished")
#	yield(get_tree().create_timer(2), "timeout")
	#$AttackArea.monitoring = true


func _input(event: InputEvent) -> void:
	if croucharea:
		if Input.is_action_just_pressed("Crouch"):
			print("down")
			$CrouchArea/Sprite.visible = false
			animp.stop(true)
			$CrouchShiftArea/Sprite.visible = true
			animp.play("CrouchShiftArea")
		if Input.is_action_just_released("Crouch"):
			$CrouchShiftArea/Sprite.visible = false
			animp.stop(true)
			$CrouchArea/Sprite.visible = true
			animp.play("CrouchArea")
	
func _on_WalkArea_body_entered(body: Node) -> void:
	$WalkArea/Sprite.visible = true
	animp.play("WalkArea")

func _on_WalkArea_body_exited(body: Node) -> void:
	$WalkArea/Sprite.visible = false
	animp.stop(true)


func _on_JumpArea_body_entered(body: Node) -> void:
	print("Jump")
	$JumpArea/Sprite.visible = true
	animp.play("JumpArea")


func _on_JumpArea_body_exited(body: Node) -> void:
	$JumpArea/Sprite.visible = false
	animp.stop(true)


func _on_CrouchArea_body_entered(body: Node) -> void:
	$CrouchArea/Sprite.visible = true
	animp.play("CrouchArea")
	croucharea = true



func _on_CrouchArea_body_exited(body: Node) -> void:
	croucharea = false
	$CrouchArea/Sprite.visible = false
	$CrouchShiftArea/Sprite.visible = false
	animp.stop(true)


func _on_DashArea_body_entered(body: Node) -> void:
	$DashArea/Sprite.visible = true
	animp.play("DashArea")

func _on_DashArea_body_exited(body: Node) -> void:
	$DashArea/Sprite.visible = false
	animp.stop(true)


func _on_AttackArea_body_entered(body):
	if body.is_in_group("Player"):
		$AttackArea/Sprite.visible = true
		animp.play("AttackArea")

		


func _on_AttackArea_body_exited(body):
	$AttackArea/Sprite.visible = false
	animp.stop(true)

func on_TutorialFinished():
	var portal = portal_scene.instance()
	portal.global_position = Vector2(2500, -30)
	add_child(portal)

