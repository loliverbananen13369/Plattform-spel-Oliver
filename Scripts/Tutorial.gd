extends Node2D

var player_scene = PlayerStats.player_instance

var player
var sprite
var area

var anchor_scene = preload("res://Scenes/Anchor.tscn")

var next_scene
var walk_sprite_values = [-146, -136]

signal entered_attack()


onready var animp = $AnimationPlayer

var test = 0

func _ready() -> void:
	PlayerStats.next_scene = "res://UI/ChooseClassScene.tscn"
	PlayerStats.ground_color = "788830"
	player = player_scene.instance()
	var target = anchor_scene.instance()
	player.global_position = global_position + Vector2(0, -20)#Vector2(0, -20)
	target.get_child(0).limit_right = 2720
	target.get_child(0).limit_left = -280
	target.get_child(0).limit_bottom = 40
	target.get_child(0).limit_top = -200
	get_child(0).add_child(player)
	get_child(0).add_child(target)
	PlayerStats.player = player
#	yield(get_tree().create_timer(2), "timeout")
	#$AttackArea.monitoring = true


	
	
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
	print("Crouch")
	$CrouchArea/Sprite.visible = true
	animp.play("CrouchArea")


func _on_CrouchArea_body_exited(body: Node) -> void:
	$CrouchArea/Sprite.visible = false
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
