class_name Tester
extends Node2D
var max_speed := 450

onready var target = PlayerStats.player

var current_velocity := Vector2.ZERO

onready var sprite := $Sprite

onready var hitbox := $HitBox/CollisionShape2D



func _ready():
	current_velocity = max_speed * 5 * Vector2.RIGHT.rotated(rotation)
	

	
func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO.rotated(rotation).normalized()
	
	
	direction = global_position.direction_to((target.global_position + Vector2(3, -5)))

	var desired_velocity := direction * max_speed
	var previous_velocity = current_velocity
	var change = (desired_velocity - current_velocity) 
	
	current_velocity += change
	sprite.scale.x += (current_velocity.x/300)
	hitbox.scale.x += (current_velocity.x/300)
	
	position += current_velocity * delta
	look_at(global_position + current_velocity)


func _on_HitBox_area_entered(area):
	if area.is_in_group("PlayerCollectParticlesArea"):
		queue_free()
