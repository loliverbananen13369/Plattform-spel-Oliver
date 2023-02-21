class_name Missile
extends Node2D

const LAUNCH_SPEED := 200


var max_speed := 200
var drag_factor := 0.15 setget set_drag_factor

onready var target = get_node("../Level 0/Node2D/Player")

var current_velocity := Vector2.ZERO

onready var sprite := $Sprite

onready var hitbox := $HitBox
onready var player_detector := $PlayerDetector




func _ready():
	
	current_velocity = max_speed * 5 * Vector2.RIGHT.rotated(rotation)

	
func _physics_process(delta: float) -> void:
	var direction := Vector2.RIGHT.rotated(rotation).normalized()
	
	if target:
		direction = global_position.direction_to((target.global_position + Vector2(3, -5)))

	var desired_velocity := direction * max_speed
	var change = (desired_velocity - current_velocity) * drag_factor
	
	current_velocity += change
	
	position += current_velocity * delta
	look_at(global_position + current_velocity)


	
func set_drag_factor(new_value: float) -> void:
	drag_factor = clamp(new_value, 0.01, 0.5)




func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("Player"):
		target = body


func _on_HitBox_area_entered(area):
	if area.is_in_group("PlayerCollectParticlesArea"):
		queue_free()
