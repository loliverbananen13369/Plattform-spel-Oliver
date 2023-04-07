extends KinematicBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
const GRAVITY = 300
var direction_x = 1
var velocity := Vector2()
var player

var rng = RandomNumberGenerator.new()

onready var animsprite = $AnimatedSprite
onready var animplayer = $AnimationPlayer
onready var hiteffect = $HitEffect

const INDICATOR_DAMAGE = preload("res://UI/DamageIndicator.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PlayerStats.player

func _physics_process(delta: float) -> void:
	_air_movement(delta)
	print(global_position.y)
	if is_on_floor() or global_position.y >= -22:
		_stop_physics()
		return

func _air_movement(delta) -> void:
	if not is_on_floor():
		velocity.y = velocity.y + GRAVITY * delta if velocity.y + GRAVITY * delta < 500 else 500 
		velocity = move_and_slide(velocity, Vector2.UP)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _hit_effect() -> void:
	var dir = direction_x
	rng.randomize()
	var ran = rng.randi_range(1, 3)
	hiteffect.animation = str(ran)
	

func _spawn_dmg_indicator(damage: int, crit: bool):
	var dir = direction_x
	var indicator = INDICATOR_DAMAGE.instance()
	var anim = indicator.get_node("AnimationPlayer")

	indicator.get_node("Label").text = str(damage)
	if not crit:
		anim.play("ShowDamage")
	else:
		anim.play("ShowCrit")
	indicator.global_position = global_position + Vector2(-direction_x*5, -30)
	get_tree().current_scene.add_child(indicator)

func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerSword"):
		_get_direction()
		_take_damage()
		
func _take_damage() -> void:
	var amount 
	amount = 10
	animplayer.play("Hurt")
	_hit_effect()
	_spawn_dmg_indicator(amount, false)

func _stop_physics() -> void:
	set_physics_process(false)

func _get_direction():
	var player = PlayerStats.player
	#var pos = get_parent().get_parent().get_node("Node2D").get_child(0).global_position.x #get_parent().get_parent().get_node("Node2D").get_child(0).global_position.x#
	var pos = player.global_position.x#PlayerStats.player.global_postion.x
	if pos > global_position.x:
		direction_x = 1
		animsprite.flip_h = true
		hiteffect.flip_h = true
	else:
		direction_x = -1
		animsprite.flip_h = false
		hiteffect.flip_h = false
		
