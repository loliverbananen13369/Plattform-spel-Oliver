extends KinematicBody2D

const MAX_SPEED = 200
const ACCELERATION = 1000
const GRAVITY = 1000
const JUMP_STRENGHT = -410

var direction_x = "RIGHT"
var velocity := Vector2.ZERO
var direction := Vector2.ZERO

func _apply_basic_movement(delta) -> void:
	if direction.x != 0:
		velocity = velocity.move_toward(direction*MAX_SPEED, ACCELERATION*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION*delta)
	
	velocity.y += GRAVITY*delta
	velocity = move_and_slide(velocity, Vector2.UP)
	

func _dash_state(delta):
	if Input.is_action_just_pressed("Dash"):
		velocity = velocity.move_toward(direction*MAX_SPEED*6, ACCELERATION*delta*6)
	
		velocity = move_and_slide(velocity, Vector2.UP)





