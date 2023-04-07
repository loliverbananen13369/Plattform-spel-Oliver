extends KinematicBody2D


enum {IDLE, CROUCH, RUN, AIR, DASH, STOP, ATTACK_GROUND, ATTACK_AIR, JUMP_ATTACK, COMBO}

const MAX_SPEED = 200
const ACCELERATION = 1000
const GRAVITY = 1300
const JUMP_STRENGHT = -520

var direction_x = "RIGHT"

var velocity := Vector2.ZERO
var direction := Vector2.ZERO

var state = IDLE

var hit_the_ground = false
var motion_previous = Vector2()

export var can_jump := true
export var can_dash := true
export var can_attack := true

var jump_pressed := false

var jump_buffer = 0.15
var attack_buffer = 0.3
var last_step = 0
var attack_pressed

const JUMP_SOUNDS = [preload("res://Sounds/ImportedSounds/JumpSounds/004_jump.wav"), preload("res://Sounds/ImportedSounds/JumpSounds/003_jump.wav"), preload("res://Sounds/ImportedSounds/JumpSounds/001_jump.wav"), preload("res://Sounds/ImportedSounds/JumpSounds/007_jump.wav"), preload("res://Sounds/ImportedSounds/JumpSounds/002_jump.wav")]
const ATTACK_SOUNDS = [preload("res://Sounds/ImportedSounds/AttackSounds/001_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/002_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/003_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/004_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/005_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/006_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/007_swing.wav")]
var can_jump_sound = true
var can_attack_sound = true

var land_scene = preload("res://Instance_Scenes/LandDust.tscn")
var jump_scene = preload("res://Instance_Scenes/JumpDust.tscn")
var dust_scene = preload("res://Instance_Scenes/ParticlesDustAssassin.tscn")
var crouch_smoke_scene = preload("res://Instance_Scenes/CrouchSmoke.tscn")

var crouchtime := 0.0

onready var playersprite = $PlayerSprite
onready var coyotetimer = $CoyoteTimer
onready var dashtimer = $DashTimer
onready var attackhitboxtimer = $AttackHitBoxTimer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playersprite.play("Idle")

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		CROUCH:
			_crouch_state(delta)
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
		JUMP_ATTACK:
			_jump_attack_state(delta)
	
func _attack_function():
	
	if Input.is_action_just_pressed("EAttack1") or (attack_pressed == 1):
		if can_attack:
			_enter_attack_state(1)
		else:
			attack_pressed = 1
			_remember_attack()
	if Input.is_action_just_pressed("Attack2") or (attack_pressed == 2):
		if can_attack:
			_enter_attack_state(2)
		else:
			attack_pressed = 2
			_remember_attack()
	if Input.is_action_just_pressed("Attack3") or (attack_pressed == 3):
		if can_attack:
			_enter_attack_state(3)
		else:
			attack_pressed = 3
			_remember_attack()

func _remember_attack() -> void:
	yield(get_tree().create_timer(attack_buffer), "timeout")
	attack_pressed = 0

func _flip_sprite(right: bool) -> void:
	if right:
		playersprite.flip_h = false
		$Area2D/CollisionShape2D.position.x = 16
	else:
		playersprite.flip_h = true
		$Area2D/CollisionShape2D.position.x = -16

func _get_input_x_update_direction() -> float:
	var input_x = Input.get_axis("move_left", "move_right")
	if input_x > 0:
		direction_x = "RIGHT"
		_flip_sprite(true)
	elif input_x < 0:
		direction_x = "LEFT"
		_flip_sprite(false)
	
	return input_x

func _get_input_x_crouch_direction() -> float:
	var input_x = Input.get_axis("move_left", "move_right")
	if input_x > 0:
		direction_x = "RIGHT"
		_flip_sprite(false)
	elif input_x < 0:
		direction_x = "LEFT"
		_flip_sprite(true)
	
	return input_x

func _apply_basic_movement(delta) -> void:
	if direction.x != 0:
		velocity = velocity.move_toward(direction*MAX_SPEED, ACCELERATION*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION*delta)
	velocity.y += GRAVITY*delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if not hit_the_ground and is_on_floor():
		hit_the_ground = true
		playersprite.scale.y = range_lerp(abs(motion_previous.y), 0, abs(200), 0.9, 0.8) # 0.9, 0.8
		playersprite.scale.x = range_lerp(abs(motion_previous.x), 0, abs(200), 0.9, 0.9) # 0.9, 0.9
	
	playersprite.scale.y = lerp(playersprite.scale.y, 1, 1 - pow(0.01, delta))
	playersprite.scale.x = lerp(playersprite.scale.x, 1, 1 - pow(0.01, delta))

func _air_movement(delta) -> void:
	velocity.y = velocity.y + GRAVITY * delta if velocity.y + GRAVITY * delta < 500 else 500 
	direction.x = _get_input_x_update_direction()
	if direction.x != 0:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED, ACCELERATION*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if not is_on_floor():
		hit_the_ground = false
		playersprite.scale.y = range_lerp(abs(velocity.y), 0, abs(JUMP_STRENGHT), 0.9, 0.8) #0.8, 1
		playersprite.scale.x = range_lerp(abs(velocity.x), 0, abs(JUMP_STRENGHT), 0.9, 0.7)#0.9, 0.65) # 1, o.8


func _idle_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	
	if (Input.is_action_just_pressed("Jump") and can_jump) or jump_pressed == true:
	#	_add_walk_dust(15)
		_add_jump_dust()
		_enter_air_state(true)
	
	if Input.is_action_just_pressed("Crouch"):
		_enter_crouch_state()
	
	_apply_basic_movement(delta)
	
	_attack_function()
	
	if not is_on_floor():
		_enter_air_state(false)
		return
	if velocity.x != 0:
		_enter_run_state()
		return

func _crouch_state(delta) -> void:
	direction.x = _get_input_x_crouch_direction()
	velocity = velocity.move_toward(Vector2.ZERO, 0.5*ACCELERATION*delta)
	velocity.y += GRAVITY*delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if Input.is_action_just_pressed("Dash"):
		if Input.is_action_pressed("Crouch"):
			velocity.y = JUMP_STRENGHT * 0.1
			playersprite.play("JumpN")
			set_collision_mask_bit(11, false)
			state = AIR
	
	if Input.is_action_just_released("Crouch"):
		_enter_run_state()

	if abs(velocity.x) >= 50:
		crouchtime += delta
		if crouchtime >= 0.07:
			_add_crouch_ghost()
			crouchtime = 0

func _run_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	var input_x = Input.get_axis("move_left", "move_right")

	if playersprite.frame == 1 or 4:
		last_step += 1
		if last_step == 4:
			_add_walk_dust(5)
			last_step = 0
	if (Input.is_action_just_pressed("Jump") and can_jump) or jump_pressed == true:
		_add_jump_dust()
		_enter_air_state(true)
	
	if Input.is_action_just_pressed("Dash") and can_dash:
		_enter_dash_state()

	if Input.is_action_just_pressed("Crouch"):
		_enter_crouch_state()
	
	if (input_x == 1 and velocity.x < 0) or (input_x == -1 and velocity.x > 0):
		_enter_stop_state()
		return

	_apply_basic_movement(delta)
	
	if not is_on_floor():
		_enter_air_state(false)
		return

	if velocity.x == 0:
		_enter_idle_state()
		return

func _air_state(delta) -> void:
	if Input.is_action_just_pressed("Dash") and can_dash:
		if abs(velocity.x) >= 20:
			_enter_dash_state()
			return
	
	if Input.is_action_just_pressed("Jump"):
		if can_jump:
			_enter_air_state(true)
			can_jump = false
			coyotetimer.stop()
		else:
			jump_pressed = true
			_remember_jump()
	
	_air_movement(delta)
	if is_on_floor() or velocity.y == 0.0: 
		#if jump_pressed == false:
		playersprite.play("Idle")
		_add_land_dust()
		_enter_idle_state()

	if velocity.y > 0:
		if velocity.x == 0:
			playersprite.play("AirN")
			#return
		else: 
			playersprite.play("AirF")
			#return

func _dash_state(delta) -> void:
	velocity = velocity.move_toward(direction*MAX_SPEED*3, ACCELERATION*delta*3)
	
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
	crouchtime += delta
	if crouchtime >= 0.01:
		_add_stop_ghost()
		crouchtime = 0
	
	if not is_on_floor():
		_enter_air_state(false)
		return
	elif velocity.length() == 0:
		_enter_idle_state()
		return

func _attack_state_ground(_delta) -> void:
	pass

func _jump_attack_state(delta) -> void:
	_air_movement(delta)
	#velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
	if is_on_floor():
		_enter_idle_state()

func _enter_idle_state() -> void:
	state = IDLE
	playersprite.play("Idle")
	can_jump = true

func _enter_air_state(jump: bool) -> void:
	if jump:
		velocity.y = JUMP_STRENGHT
	if velocity.x == 0:
		playersprite.play("JumpN")
	else:
		playersprite.play("JumpF")
	coyotetimer.start()
	state = AIR

func _enter_crouch_state() -> void:
	state = CROUCH
	if velocity.x >= 1 or velocity.x <= -1:
		if direction_x == "RIGHT":
			_flip_sprite(false)
		else:
			_flip_sprite(true)
	playersprite.play("Crouch")

func _enter_run_state() -> void:
	state = RUN
	can_jump = true
	playersprite.play("Run")

func _enter_stop_state() -> void:
	can_jump = true
	state = STOP
	playersprite.play("Stop")

func _enter_dash_state() -> void:
	direction = Input.get_vector("move_left", "move_right","ui_up", "ui_down")
	if direction == Vector2.DOWN:
		return
	if direction == Vector2.ZERO:
		print("hejdå")
		direction.x = 1 if direction_x == "RIGHT" else -1
	state = DASH
	playersprite.play("Dash")
	can_dash = false
	dashtimer.start(0.25)

func _enter_attack_state(nr: int) -> void:
	state = ATTACK_GROUND
	playersprite.play("Attack" + str(nr))
	attackhitboxtimer.start(0.10)
	yield(playersprite, "animation_finished")
	$Area2D/CollisionShape2D.disabled = true
	_enter_idle_state()

func _add_walk_dust(amount: int) -> void:
	var dust = dust_scene.instance()
	dust.amount = amount
	dust.global_position = playersprite.global_position + Vector2(0,22)
	dust.emitting = true
	get_tree().get_root().add_child(dust)

func _add_land_dust()-> void:
	var dust = land_scene.instance()
	dust.global_position = playersprite.global_position + Vector2(0, 21) # 15
	get_tree().get_root().add_child(dust)

func _add_jump_dust():
	var dust = jump_scene.instance()#jl_scene.instance()
	dust.global_position = playersprite.global_position + Vector2(0, 14)
	#dust.play("JumpSmokeSideAssassin")
	get_tree().get_root().add_child(dust)# Called every frame. 'delta' is the elapsed time since the previous frame.

func _add_crouch_ghost() -> void:
	var dir 
	if direction_x == "RIGHT":
		dir = 1
	else:
		dir = -1
	var smoke = crouch_smoke_scene.instance()
	smoke.global_position = global_position + Vector2(22*dir, 24)
	smoke.flip_h = playersprite.flip_h
	get_tree().get_root().add_child(smoke)

func _add_stop_ghost() -> void:
	var smoke = crouch_smoke_scene.instance()
	smoke.global_position = global_position + Vector2(-25*direction.x, 24)
	smoke.flip_h = playersprite.flip_h
	get_tree().get_root().add_child(smoke)

func _remember_jump() -> void:
	yield(get_tree().create_timer(jump_buffer), "timeout")
	jump_pressed = false


func _on_DashTimer_timeout() -> void:
	_enter_idle_state()
	velocity = direction * MAX_SPEED
	direction.y = 0
	can_dash = true


func _on_DropDetect_body_exited(body) -> void:
	set_collision_mask_bit(11, true)


func _on_AttackHitBoxTimer_timeout() -> void:
	$Area2D/CollisionShape2D.disabled = false
