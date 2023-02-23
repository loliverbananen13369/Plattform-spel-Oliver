class_name Tester
extends Node2D

const LAUNCH_SPEED := 300


var max_speed := 300

onready var target = get_parent().get_child(2).get_child(1).get_child(0)

var current_velocity := Vector2.ZERO

onready var sprite := $Sprite

onready var hitbox := $HitBox
onready var player_detector := $PlayerDetector



func _ready():
	current_velocity = max_speed * 5 * Vector2.RIGHT.rotated(rotation)
	

	
func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO.rotated(rotation).normalized()
	
	
	if target:
		direction = global_position.direction_to((target.global_position + Vector2(3, -5)))

	var desired_velocity := direction * max_speed
	var previous_velocity = current_velocity
	var change = (desired_velocity - current_velocity) 
	
	current_velocity += change
	sprite.scale.x += (current_velocity.x/300)
	
	position += current_velocity * delta
	look_at(global_position + current_velocity)


	


func _on_HitBox_area_entered(area):
	if area.is_in_group("PlayerCollectParticlesArea"):
		queue_free()
