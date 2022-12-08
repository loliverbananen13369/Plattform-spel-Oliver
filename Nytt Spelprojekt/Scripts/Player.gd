extends KinematicBody2D


enum {IDLE, RUN, STOP, DASH}

const MAX_SPEED = 200
const ACCELERATION = 500
const GRAVITY = 1000
const JUMP_STRENGTH = -410
const DASH_STRENGTH = 400

var direction_x = "RIGHT"
var velocity := Vector2.ZERO
var direction := Vector2.ZERO

var state = IDLE

var can_jump = true
var can_dash = true

onready var animatedsprite = $AnimatedSprite
onready var dashtimer = $DashTimer

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		RUN:
			_run_state(delta)
		DASH:
			_dash_state(delta)
		STOP: 
			_stop_state(delta)


func _apply_basic_movement(delta) -> void:
	if direction.x != 0:
		velocity = velocity.move_toward(direction*MAX_SPEED, ACCELERATION*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION*delta)
	
	velocity.y += GRAVITY*delta
	velocity = move_and_slide(velocity, Vector2.UP)

func _get_input_x_update_direction() -> float:
	var input_x = Input.get_axis("move_left", "move_right")
	if input_x > 0:
		direction_x = "RIGHT"
	elif input_x < 0:
		direction_x = "LEFT"
	$AnimatedSprite.flip_h = direction_x != "RIGHT"
	return input_x



func _idle_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
		
	_apply_basic_movement(delta)
	
	if velocity.x != 0:
		state = RUN
		animatedsprite.play("Run")
		can_dash = true
		return
	
		
func _run_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	var input_x = Input.get_axis("move_left", "move_right")
	_apply_basic_movement(delta)
	
	if Input.is_action_just_pressed("Dash") and can_dash:
		can_dash = false
		$DashTimer.start()
		if direction.x > 0:
			velocity.x = DASH_STRENGTH
		elif direction.x < 0:
			velocity.x = -DASH_STRENGTH
		state = DASH
		animatedsprite.play("Dash")
		return
	
	elif (input_x == 1 and velocity.x <= 0) or (input_x == -1 and velocity.x >= 0):
		state = STOP
		animatedsprite.play("Stop")
		return
	elif velocity.length() == 0:
		state = IDLE
		animatedsprite.play("Idle")
		return
	
	
func _stop_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	var input_x = Input.get_axis("move_left", "move_right")
	_apply_basic_movement(delta)
	
	if (input_x == 1 and velocity.x >= 0) or (input_x == -1 and velocity.x <= 0):
		state = RUN
		animatedsprite.play("Run")
		return
	elif velocity.length() == 0:
		state = IDLE
		animatedsprite.play("Idle")
		return
	

func _dash_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	
	_apply_basic_movement(delta)
	
	if velocity.length() == 0:
		state = IDLE
		animatedsprite.play("Idle")
		return
	
func _on_DashTimer_timeout() -> void:
	state = IDLE
	yield(get_tree().create_timer(1.0), "timeout")
	can_dash = true
