extends KinematicBody2D

enum {IDLE, RUN, AIR, DASH, STOP, ATTACK_GROUND, ATTACK_AIR}

const MAX_SPEED = 200
const ACCELERATION = 1000
const GRAVITY = 1000
const JUMP_STRENGHT = -410

var direction_x = "RIGHT"
var velocity := Vector2.ZERO
var direction := Vector2.ZERO

var state = IDLE

var rng = RandomNumberGenerator.new()

var can_jump := true
var can_dash := true
var can_attack := true
var jump_attack := false

onready var animatedsprite = $PlayerSprite
onready var animatedsmears = $SmearSprites
onready var animationplayer = $AnimationPlayer
onready var coyotetimer = $CoyoteTimer
onready var dashtimer = $DashTimer
onready var attacktimer = $AttackTimer
onready var dashparticles = $DashParticles
onready var attackparticles = $AttackParticles
onready var dashline = $Line2D


func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		RUN:
			_run_state(delta)
		AIR:
			_air_state(delta)
		DASH:
			_dash_state(delta)
		STOP:
			_stop_state(delta)
		ATTACK_GROUND:
			_attack_state_ground(delta)
		ATTACK_AIR:
			_attack_state_air(delta)

#Help functions
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
	animatedsprite.flip_h = direction_x != "RIGHT"
	animatedsmears.flip_h = direction_x != "RIGHT"
	
	
	return input_x


func _air_movement(delta) -> void:
	velocity.y = velocity.y + GRAVITY * delta if velocity.y + GRAVITY * delta < 500 else 500 
	direction.x = _get_input_x_update_direction()
	if direction.x != 0:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED, ACCELERATION*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
	velocity = move_and_slide(velocity, Vector2.UP)


#STATES:
func _idle_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	if Input.is_action_just_pressed("Jump") and can_jump:
		_enter_air_state(true)
		return
	
	if Input.is_action_just_pressed("Dash") and can_dash:
		_enter_dash_state()
		return
	
	if Input.is_action_just_pressed("EAttack1"):
		_enter_attack1_state(1)
	
	
		
	_apply_basic_movement(delta)
	
	if not is_on_floor():
		_enter_air_state(false)
		return
	if velocity.x != 0:
		_enter_run_state()
		return
		
func _run_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	var input_x = Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("Jump") and can_jump:
		_enter_air_state(true)
		return
	
	if Input.is_action_just_pressed("Dash") and can_dash:
		_enter_dash_state()
		return
		
	if Input.is_action_just_pressed("EAttack1"):
		_enter_attack1_state(1)
	
	if (input_x == 1 and velocity.x < 0) or (input_x == -1 and velocity.x > 0):
		_enter_stop_state()
		return
	
	_apply_basic_movement(delta)
	
	if not is_on_floor():
		_enter_air_state(false)
		return
	elif velocity.length() == 0:
		_enter_idle_state()
		return


func _air_state(delta) -> void:
	if Input.is_action_just_pressed("Dash") and can_dash:
		_enter_dash_state()
		return
	
	if Input.is_action_pressed("EAttack1"):
		if velocity.x != 0:
			_enter_attack_air_state(false)
			return
		else:
			_enter_attack_air_state(true)
			return
		return
	
	elif Input.is_action_just_pressed("Jump") and can_jump:
		velocity.y = JUMP_STRENGHT
		can_jump = false
		coyotetimer.stop()

	
	_air_movement(delta)
	var current_animation = animatedsprite.get_animation()
	if velocity.y > 0  and not ( current_animation == "FallN" ) and ( velocity.x == 0 ):
		animatedsprite.play("FallN")
	elif velocity.y > 0 and not ( current_animation == "FallF" ) and ( velocity.x != 0 ):
		animatedsprite.play("FallF")
	if is_on_floor():
		_enter_idle_state()
		return

func _dash_state(delta):
	velocity = velocity.move_toward(direction*MAX_SPEED*6, ACCELERATION*delta*6)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	

func _stop_state(delta):
	direction.x = _get_input_x_update_direction()
	var input_x = Input.get_axis("move_left", "move_right")
	_apply_basic_movement(delta)

	if Input.is_action_just_pressed("Jump") and can_jump:
		_enter_air_state(true)
		return
	
	if Input.is_action_just_pressed("Dash") and can_dash:
		_enter_dash_state()
		return
		
	if (input_x == 1 and velocity.x > 0) or (input_x == -1 and velocity.x < 0):
		_enter_run_state()
		return
	
	_apply_basic_movement(delta)
	
	if not is_on_floor():
		_enter_air_state(false)
		return
	elif velocity.length() == 0:
		_enter_idle_state()
		return
	
func _attack_state_ground(_delta) -> void:
	if Input.is_action_just_released("EAttack1"):
		_enter_idle_state()
	
func _attack_state_air(delta) -> void:
	velocity.y = velocity.y + GRAVITY *2* delta if velocity.y + GRAVITY * delta < 500 else 700 
	direction.x = _get_input_x_update_direction()

	if jump_attack:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
		if is_on_floor():
			_enter_idle_state()
			jump_attack = false
	elif not jump_attack:
		if direction.x == 1:
			velocity.x = 400
		elif direction.x == -1:
			velocity.x = -400
		if is_on_floor():
			animationplayer.play("AirAttack")
			_enter_idle_state()
	
	velocity = move_and_slide(velocity, Vector2.UP)
		





#SIGNALS
func _on_DashTimer_timeout():
	_enter_idle_state()
	velocity = direction * MAX_SPEED
	direction.y = 0
	dashparticles.emitting = false
	dashline.visible = false
	yield(get_tree().create_timer(0.5), "timeout")
	can_dash = true

func _on_CoyoteTimer_timeout():
	can_jump = false

func _on_AttackTimer_timeout() -> void:
	can_attack = true
	if Input.is_action_pressed("EAttack1"):
		rng.randomize()
		var random_attack_number = rng.randi_range(1,3)
		_enter_attack1_state(random_attack_number)
	else:
		_enter_idle_state()


#Enter states
func _enter_idle_state() -> void:
	state = IDLE
	animatedsprite.play("Idle")
	can_jump = true


func _enter_dash_state() -> void:
	direction = Input.get_vector("move_left", "move_right","ui_up", "ui_down")
	if state == IDLE and direction == Vector2.DOWN:
		return
	elif direction == Vector2.ZERO:
		direction.x = 1 if direction_x == "RIGHT" else -1
	animatedsprite.play("Dash")
	state = DASH
	dashparticles.emitting = true
	dashline.visible = true
	can_dash = false
	dashtimer.start(0.25)

func _enter_air_state(jump: bool) -> void:
	if jump:
		velocity.y = JUMP_STRENGHT
	#else:
		if velocity.x == 0:
			animatedsprite.play("JumpN")
		else:
			animatedsprite.play("JumpF")
	coyotetimer.start()
	state = AIR

func _enter_run_state() -> void:
	state = RUN
	animatedsprite.play("Run")

func _enter_stop_state() -> void:
	state = STOP
	animatedsprite.play("Stop")

func _enter_attack1_state(attack: int) -> void:
	state = ATTACK_GROUND
	if direction_x != "RIGHT":
		animatedsmears.position.x = -10
		attackparticles.position.x = -10
	elif direction_x == "RIGHT":
		animatedsmears.position.x = 30
		attackparticles.position.x = 30
	if attack == 1:
		animationplayer.play("Attack1")
		attacktimer.start(0.2667)
		can_attack = false
	elif attack == 2:
		animationplayer.play("Attack2")
		attacktimer.start(0.2667)
		can_attack = false
	elif attack == 3:
		animationplayer.play("Attack3")
		attacktimer.start(0.2667)
		can_attack = false

func _enter_attack_air_state(Jump: bool) -> void:
	state = ATTACK_AIR
	if Jump:
		animationplayer.play("JumpAttack")
		jump_attack = true
	else:
		animationplayer.play("PrepareAirAttack")

				


	

	

















