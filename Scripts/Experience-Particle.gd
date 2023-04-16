class_name Missile
extends Node2D

var LAUNCH_SPEED := 500


var max_speed := 300
var drag_factor := 0.15 setget set_drag_factor

onready var target = PlayerStats.player#get_parent().get_child(3).get_child(1).get_child(0)
var dir = 1#Vector2.RIGHT


var current_velocity := Vector2.ZERO

onready var sprite := $Sprite
onready var hitbox := $HitBox
onready var player_detector := $PlayerDetector


var rng = RandomNumberGenerator.new()

func _ready():
	if target.direction_x != "RIGHT":
		dir = -1#Vector2.LEFT
	rng.randomize()
	LAUNCH_SPEED *= rng.randf_range(1, 2.5)
	#current_velocity = LAUNCH_SPEED * 3 * dir.rotated(rotation)
	current_velocity.x = LAUNCH_SPEED * dir
	current_velocity.y = LAUNCH_SPEED * -1
	
	
func _physics_process(delta: float) -> void:
	var direction := Vector2.RIGHT.rotated(rotation).normalized()
	if is_instance_valid(target):
		direction = global_position.direction_to((target.global_position + Vector2(0, 0)))
	else:
		queue_free()

	var desired_velocity := direction * max_speed
	var change = (desired_velocity - current_velocity) * drag_factor
	
	current_velocity += change
	
	position += current_velocity * delta


	
func set_drag_factor(new_value: float) -> void:
	drag_factor = clamp(new_value, 0.01, 0.5)



func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("Player"):
		target = body


func _on_HitBox_area_entered(area):
	if area.is_in_group("PlayerCollectParticlesArea"):
		queue_free()
