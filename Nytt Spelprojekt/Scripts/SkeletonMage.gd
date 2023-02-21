extends KinematicBody2D

enum {IDLE, RUN, ATTACK, DEAD, HURT, HUNTING, SPAWN}

const MAX_SPEED = 100
const ACCELERATION = 1000
const GRAVITY = 1000
const JUMP_STRENGHT = -410

var state = RUN

export var direction_x = 1
var velocity := Vector2()
var direction := Vector2.ZERO


onready var animatedsprite = $AnimatedSprite
onready var player = get_parent().get_node("../Node2D/Player")

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			pass
		RUN:
			pass
		ATTACK:
			pass
		DEAD:
			pass
		HURT: 
			pass
		HUNTING:
			pass
		SPAWN:
			pass




func _air_movement(delta) -> void:
	if not is_on_floor():
		velocity.y = velocity.y + GRAVITY * delta if velocity.y + GRAVITY * delta < 500 else 500 
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
		velocity = move_and_slide(velocity, Vector2.UP)

func _apply_basic_movement(delta) -> void:
	
	velocity.y += GRAVITY*delta
	
	velocity.x = MAX_SPEED * direction_x
	velocity = move_and_slide(velocity, Vector2.UP)
	if direction_x == -1:
		animatedsprite.flip_h = true
		$Position2D.position.x = 21
	if direction_x == 1:
		animatedsprite.flip_h = false
		$Position2D.position.x = 1
