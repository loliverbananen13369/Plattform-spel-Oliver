extends KinematicBody2D

enum {IDLE, RUN, AIR, DASH, STOP, ATTACK_GROUND}

const MAX_SPEED = 200
const ACCELERATION = 1000
const GRAVITY = 1000
const JUMP_STRENGHT = -410

var direction_x = "RIGHT"
var velocity := Vector2.ZERO
var direction := Vector2.ZERO

var state = IDLE
var ghosttime := 0.0

var can_jump := true
var can_dash := true
var can_attack := true
var can_attack1 := true
var can_attack2 := false
var can_attack3 := false


onready var animatedsprite = $PlayerSprite
onready var animatedattacksprite1 = $Attack1Sprite
onready var animatedattacksprite2 = $Attack2Sprite
onready var animatedattacksprite3 = $Attack3Sprite
onready var animationplayer = $AnimationPlayer
onready var coyotetimer = $CoyoteTimer
onready var dashtimer = $DashTimer
onready var attackcombotimer1 = $AttackComboTimer1
onready var attackcombotimer2 = $AttackComboTimer2
onready var attack1timer = $Attack1Timer
onready var attack2timer = $Attack2Timer
onready var attack3timer = $Attack3Timer
onready var sattacktimer = $SAttackTimer


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
	animatedattacksprite1.flip_h = direction_x != "RIGHT"
	animatedattacksprite2.flip_h = direction_x != "RIGHT"
	animatedattacksprite3.flip_h = direction_x != "RIGHT"
	
	
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
		if can_attack1:
			_enter_attack1_state(1)
			return
		elif can_attack2:
			_enter_attack1_state(2)
			return
		elif can_attack3:
			_enter_attack1_state(3)
			return
		else:
			return
	
	
		
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
	
	if Input.is_action_just_pressed("EAttack1") and can_attack1:
		_enter_attack1_state(1)
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
	velocity = velocity.move_toward(direction*MAX_SPEED*5, ACCELERATION*delta*5)
	
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
	
func _attack_state_ground(delta) -> void:
	direction.x = _get_input_x_update_direction()
	_apply_basic_movement(delta)




#SIGNALS
func _on_DashTimer_timeout():
	_enter_idle_state()
	velocity = direction * MAX_SPEED
	direction.y = 0
	yield(get_tree().create_timer(0.5), "timeout")
	can_dash = true

func _on_CoyoteTimer_timeout():
	can_jump = false

func _on_Attack1Timer_timeout() -> void:
	_enter_idle_state()
	attackcombotimer1.start(1)
	can_attack2 = true

func _on_Attack2Timer_timeout() -> void:
	_enter_idle_state()
	attackcombotimer2.start(1)
	can_attack3 = true

func _on_Attack3Timer_timeout() -> void:
	_enter_idle_state()
	can_attack3 = false
	can_attack1 = true

	
func _on_AttackComboTimer1_timeout() -> void:
	can_attack2 = false
	can_attack1 = true

func _on_AttackComboTimer2_timeout() -> void:
	can_attack3 = false
	can_attack1 = true


func _on_SAttackTimer_timeout() -> void:
	_enter_idle_state()
	can_attack1 = true



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
	if is_on_floor():
		animationplayer.play("GroundDashSmoke")
	else:
		animationplayer.play("AirDashSmoke")
	state = DASH
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
	if attack == 1:
		animatedsprite.play("Attack1")
		animationplayer.play("Attack1")
		attack1timer.start(0.5)
		can_attack1 = false
	elif attack == 2:
		animatedsprite.play("Attack2")
		animationplayer.play("Attack2")
		attack2timer.start(0.5)
		can_attack2 = false
	elif attack == 3:
		animatedsprite.play("Attack3")
		animationplayer.play("Attack3")
		attack3timer.start(0.5)
		can_attack3 = false

	

	

#Attack


	
	
















