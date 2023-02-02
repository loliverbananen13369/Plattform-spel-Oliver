extends KinematicBody2D

#Se till att använda den där tiktok rösten som narrator

enum {IDLE, RUN, AIR, DASH, STOP, ATTACK_GROUND, ATTACK_DASH, ATTACK_AIR, JUMP_ATTACK, PREPARE_ATTACK_AIR, HURT, COMBO}

const MAX_SPEED = 200
const ACCELERATION = 1000
const GRAVITY = 1300
const JUMP_STRENGHT = -480

var direction_x = "RIGHT"
var velocity := Vector2.ZERO
var direction := Vector2.ZERO

var state = IDLE

var rng = RandomNumberGenerator.new()

var can_jump := true
var can_dash := true
var can_attack := true
var jump_attack := false
var is_attacking := false
var is_air_attacking := false
var jump_pressed := false
var can_follow_enemy := false
var attack_pressed = 0
var previous_attack = 0
var combo_list = []

var enemy_side_of_you

var jump_buffer = 0.15
var attack_buffer = 0.3
var hit_amount = 0

signal test
signal HPChanged(hp)

var ghost_scene = preload("res://Scenes/NewTestGhostDash.tscn")
var jl_scene = preload("res://Scenes/LandnJumpDust.tscn")
var dust_scene = preload("res://Scenes/ParticlesDust.tscn")
var skeleton_enemy_scene = preload("res://Scenes/SkeletonWarrior.tscn")
var ghosttime := 0.0

onready var playersprite = $PlayerSprite
onready var animatedsmears = $SmearSprites
onready var animationplayer = $AnimationPlayer
onready var coyotetimer = $CoyoteTimer
onready var dashtimer = $DashTimer
onready var dashparticles = $Position2D/DashParticles
onready var attackparticles = $AttackParticles
onready var dashline = $Position2D/Line2D
onready var enemy =  get_tree().get_nodes_in_group("Enemy")[0]

onready var all_enemy = get_tree().get_nodes_in_group("Enemy")[0]
var dash_to_enemy_distance = 50
var close_enemy 

var hit_the_ground = false
var motion_previous = Vector2()
var last_step = 0
var side = "RIGHT"

#Player stats
var hp = 100
var max_hp = 100
var hp_regeneration = 1
var mana = 100
var mana_max = 100
var mana_regeneration = 2


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
		ATTACK_DASH:
			_attack_state_dash(0, delta)
		PREPARE_ATTACK_AIR:
			_prepare_attack_air_state(delta)
		ATTACK_AIR:
			_attack_state_air(delta)
		JUMP_ATTACK:
			_jump_attack_state(delta)
		COMBO:
			_combo_state(delta)
		HURT:
			_hurt_state(delta)

#Help functions
func _apply_basic_movement(delta) -> void:
	if direction.x != 0:
		velocity = velocity.move_toward(direction*MAX_SPEED, ACCELERATION*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION*delta)
	
	velocity.y += GRAVITY*delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if not hit_the_ground and is_on_floor():
		hit_the_ground = true
		playersprite.scale.y = range_lerp(abs(motion_previous.y), 0, abs(200), 0.9, 0.8)
		playersprite.scale.x = range_lerp(abs(motion_previous.x), 0, abs(200), 0.9, 0.9)
	
	playersprite.scale.y = lerp(playersprite.scale.y, 1, 1 - pow(0.01, delta))
	playersprite.scale.x = lerp(playersprite.scale.x, 1, 1 - pow(0.01, delta))

func _get_input_x_update_direction() -> float:
	var input_x = Input.get_axis("move_left", "move_right")
	if input_x > 0:
		direction_x = "RIGHT"
		_flip_sprite(true)
	elif input_x < 0:
		direction_x = "LEFT"
		_flip_sprite(false)
	playersprite.flip_h = direction_x != "RIGHT"
	animatedsmears.flip_h = direction_x != "RIGHT"
	
	#$Thrusts.flip_h  = direction_x != "RIGHT"

	
	
	return input_x

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
		playersprite.scale.y = range_lerp(abs(velocity.y), 0, abs(JUMP_STRENGHT), 0.8, 1)
		playersprite.scale.x = range_lerp(abs(velocity.x), 0, abs(JUMP_STRENGHT), 1, 0.8)

func _attack_function():
	if Input.is_action_just_pressed("EAttack1") or (attack_pressed == 1):
		if can_attack:
			_enter_attack1_state(1, false)
			previous_attack = 1
		else:
			attack_pressed = 1
			_remember_attack()
	if Input.is_action_just_pressed("Attack2") or (attack_pressed == 2):
		if can_attack:
			_enter_attack1_state(2, false)
			previous_attack = 2
		else:
			attack_pressed = 2
			_remember_attack()
	if Input.is_action_just_pressed("Attack3") or (attack_pressed == 3):
		if can_attack:
			_enter_attack1_state(3, false)
			previous_attack = 3
		else:
			attack_pressed = 3
			_remember_attack()
			
func _flip_sprite(right: bool) -> void:
	if right:
		playersprite.flip_h = false
		animatedsmears.flip_h = false
		animatedsmears.position.x = 30
		dashparticles.position.x = 30
		$NormalAttackArea/AttackGround.position.x =46
		$SpecialAttackArea/Acid2.position.x = 62
		$SwordCutArea/SpinAttack.position.x = 44
	else:
		playersprite.flip_h = true
		animatedsmears.flip_h = true
		animatedsmears.position.x = -10
		dashparticles.position.x = -10
		$NormalAttackArea/AttackGround.position.x = -26
		$SpecialAttackArea/Acid2.position.x = -42
		$SwordCutArea/SpinAttack.position.x = -24

func _add_dash_ghost() -> void:
	var ghost = ghost_scene.instance()
	ghost.global_position = global_position + Vector2(0, -22)
	#ghost.global_position.y -= 20
	ghost.flip_h = playersprite.flip_h
	get_tree().get_root().add_child(ghost)

func _add_land_dust()-> void:
	var dust = jl_scene.instance()
	dust.global_position = playersprite.global_position + Vector2(0, 15)
	dust.play("DustExplosion")
	get_tree().get_root().add_child(dust)

func _add_jump_dust(number: int) -> void:
	var dust = dust_scene.instance()
	dust.amount = number
	dust.global_position = playersprite.global_position + Vector2(0,23)
	dust.emitting = true
	get_tree().get_root().add_child(dust)

func take_damage(amount: int, direction: int) -> void:
	state = HURT
	flash()
	frameFreeze(0.1, 0.5)
	playersprite.play("Hit")
	$BeenHurtTimer.start(0.1)
	hp -= amount
	emit_signal("HPChanged", hp)

func frameFreeze(timescale, duration):
	Engine.time_scale = timescale
	yield(get_tree().create_timer(duration * timescale), "timeout")
	Engine.time_scale = 1

func flash():
	$FlashTimer.one_shot = false
	playersprite.material.set_shader_param("flash_modifier", 0.6)
	$FlashTimer.start()

func _remember_jump() -> void:
	yield(get_tree().create_timer(jump_buffer), "timeout")
	jump_pressed = false

func _remember_attack() -> void:
	yield(get_tree().create_timer(attack_buffer), "timeout")
	attack_pressed = 0

func _dash_to_enemy(switch_side: bool) -> void:
	if not switch_side:
		if global_position.x >= enemy.position.x:
			global_position = enemy.position + Vector2(30, -4)
			_flip_sprite(false)
		else:
			global_position = enemy.position - Vector2(30, 4)
			direction_x = "RIGHT"
			_flip_sprite(true)
	else:
		if global_position.x <= enemy.position.x:
			global_position = enemy.position + Vector2(30, -4)
			direction_x = "LEFT"
			_flip_sprite(false)
		else:
			global_position = enemy.position - Vector2(30, 4)
			direction_x = "RIGHT"
			_flip_sprite(true)
		
func check_combo() -> void:
	if combo_list.front() == 1:
		if combo_list == [1,2,3,1]:
			_enter_combo_state(1)
	elif combo_list.front() == 3:
		if combo_list == [3,2,1,3]:
			_enter_combo_state(2)
	if combo_list.size() == 5:
		combo_list.clear()
	else:
		return
#STATES:
func _idle_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	if (Input.is_action_just_pressed("Jump") and can_jump) or jump_pressed == true:
		_add_jump_dust(15)
		_enter_air_state(true)
		return
	
	_attack_function()
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

	if playersprite.frame == 0:
		last_step += 1
		if last_step == 4:
			_add_jump_dust(5)
			last_step = 0
				
	if (Input.is_action_just_pressed("Jump") and can_jump) or jump_pressed == true:
		_add_jump_dust(15)
		_enter_air_state(true)
		return
	
	if Input.is_action_just_pressed("Dash") and can_dash:
		_enter_dash_state(false)
		return
		
	if Input.is_action_just_pressed("EAttack1"):
		_enter_dash_attack_state(1)
	if Input.is_action_just_pressed("AttackE"):
		pass
	
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
		_enter_dash_state(false)
		return
	
	if Input.is_action_pressed("EAttack1"):
		_enter_attack_air_state(true)
		return
	if Input.is_action_pressed("AttackE"):
		_enter_attack_air_state(false)
		return

	
	if Input.is_action_just_pressed("Jump"):
		if can_jump:
			_enter_air_state(true)
			can_jump = false
			coyotetimer.stop()
		else:
			jump_pressed = true
			_remember_jump()

		
	#_squash_player(delta)
	_air_movement(delta)
	var current_animation = playersprite.get_animation()
	if velocity.y > 0  and not ( current_animation == "FallN" ) and ( velocity.x == 0 ):
		playersprite.play("FallN")
	elif velocity.y > 0 and not ( current_animation == "FallF" ) and ( velocity.x != 0 ):
		playersprite.play("FallF")
	if is_on_floor(): 
		#if jump_pressed == false:
		_add_land_dust()
		_enter_idle_state()
		return

func _dash_state(delta):
	velocity = velocity.move_toward(direction*MAX_SPEED*3, ACCELERATION*delta*3)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	ghosttime += delta
	
	if ghosttime >= 0.03:
		_add_dash_ghost()
		ghosttime = 0.0
	
func _stop_state(delta):
	direction.x = _get_input_x_update_direction()
	var input_x = Input.get_axis("move_left", "move_right")
	_apply_basic_movement(delta)

	if Input.is_action_just_pressed("Jump") and can_jump:
		_enter_air_state(true)
		return
	
	if Input.is_action_just_pressed("Dash") and can_dash:
		_enter_dash_state(false)
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
	_attack_function()
	
func _attack_state_dash(attack_nr : int, delta) -> void:
	velocity = velocity.move_toward(direction*MAX_SPEED*1, ACCELERATION*delta*1)
	
	velocity = move_and_slide(velocity, Vector2.UP)

func _prepare_attack_air_state(delta) -> void:
	frameFreeze(0.3, 0.4)
	playersprite.scale.y = lerp(playersprite.scale.y, 1, 1 - pow(0.01, delta))
	playersprite.scale.x = lerp(playersprite.scale.x, 1, 1 - pow(0.01, delta))

func _attack_state_air(delta) -> void:
	$HurtBox/CollisionShape2D.disabled = true
	if direction_x != "RIGHT":
		animatedsmears.rotation_degrees = -45
		$NormalAttackArea/AirAttack.rotation_degrees = -45
	else: 
		animatedsmears.rotation_degrees = 45
		$NormalAttackArea/AirAttack.rotation_degrees = 45
	animationplayer.play("Thrust2")
	$NormalAttackArea/AirAttack.disabled = false
	if direction_x == "RIGHT":
		velocity.x = MAX_SPEED*10
	elif direction_x != "RIGHT":
		velocity.x = -MAX_SPEED*10
	velocity.y = GRAVITY*2
	
	if is_on_floor():
		velocity.x = 0
	
	velocity = move_and_slide(velocity, Vector2.UP)	
	
func _jump_attack_state(delta) -> void:
	_air_movement(delta)
	#velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
	if is_on_floor():
		_enter_idle_state()

func _combo_state(delta) -> void:
	pass

func _hurt_state(delta) -> void:	
	print(enemy_side_of_you)
	if enemy_side_of_you == "right":
		direction_x = "RIGHT"
		velocity.x = -300
	if enemy_side_of_you == "left":
		direction_x = "LEFT"
		velocity.x = 300
	velocity.y = -300
	_air_movement(delta)
	enemy_side_of_you = ""
		

#Enter states
func _enter_idle_state() -> void:
	state = IDLE
	playersprite.play("Idle")
	can_jump = true

func _enter_dash_state(attack: bool) -> void:
	if attack == false:
		direction = Input.get_vector("move_left", "move_right","ui_up", "ui_down")
		if state == IDLE and direction == Vector2.DOWN:
			return
		elif direction == Vector2.ZERO:
			direction.x = 1 if direction_x == "RIGHT" else -1
		playersprite.play("Dash")
		state = DASH
		dashparticles.emitting = true
		#dashline.visible = true
		can_dash = false
		dashtimer.start(0.25)
	else:
		pass

func _enter_air_state(jump: bool) -> void:
	if jump:
		velocity.y = JUMP_STRENGHT
	#else:
		if velocity.x == 0:
			playersprite.play("JumpN")
		else:
			playersprite.play("JumpF")
	coyotetimer.start()
	state = AIR

func _enter_run_state() -> void:
	can_jump = true
	state = RUN
	playersprite.play("Run")

func _enter_stop_state() -> void:
	can_jump = true
	state = STOP
	playersprite.play("Stop")

func _enter_attack1_state(attack: int, combo: bool) -> void:
	
	if combo:
		state = COMBO
	else:
		state = ATTACK_GROUND
		$ComboTimer.start(1)
	is_attacking = true
	animatedsmears.position.y = -15
	if direction_x != "RIGHT":
		animatedsmears.position.x = -10
		attackparticles.position.x = -10
		$NormalAttackArea/AttackGround.position.x = -26
	elif direction_x == "RIGHT":
		animatedsmears.position.x = 30
		attackparticles.position.x = 30
		$NormalAttackArea/AttackGround.position.x = 46
	if attack == 1:
		animationplayer.play("Attack1")
		can_attack = false
		previous_attack = 1
		#$NormalAttackArea/AttackGround.disabled = false
	if attack == 2:
		animationplayer.play("Attack2")
		can_attack = false
		previous_attack = 2
	if attack == 3:
		animationplayer.play("Attack3")
		can_attack = false
		previous_attack = 3
	if attack == 4:
		animationplayer.play("SpinAttack")
		can_attack = false
	if can_follow_enemy:
		_dash_to_enemy(false)
	combo_list.append(previous_attack) 
	check_combo()
	if combo_list.size() == 0:
		_enter_idle_state()

func _enter_dash_attack_state(attack: int) -> void:
	state = ATTACK_DASH
	if attack == 1:
		animationplayer.play("SpinAttack")
		can_attack = false

func _enter_attack_air_state(Jump: bool) -> void:	
	if Jump:
		if direction_x != "RIGHT":
			$NormalAttackArea/AttackJump.position.x = -10
		elif direction_x == "RIGHT":
			$NormalAttackArea/AttackJump.position.x = 30
		state = JUMP_ATTACK
		animationplayer.play("JumpAttack")
		$NormalAttackArea/AttackJump.disabled = false

	else:
		animationplayer.play("PrepareAirAttack")

func _enter_combo_state(number : int) -> void:
	state = COMBO
	if number == 1: 
		#_dash_to_enemy(true)
		animationplayer.play("ComboSpinAttack")
		combo_list.clear()
	if number == 2:
		if direction_x == "RIGHT":
			$ComboSprites.position.x = 62
			$ComboSprites.flip_h = false
		else:
			$ComboSprites.position.x = -42
			$ComboSprites.flip_h = true
		animationplayer.play("TestCombo")
		combo_list.clear()
		
#Signals

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack1":
		if state == COMBO:
			if can_follow_enemy:
				#_dash_to_enemy(true)
				_enter_attack1_state(2, true)
			else:
				_enter_attack1_state(2, true)
		else:
			can_attack = true
			if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
				_enter_run_state()
			else:
				_enter_idle_state()
	if anim_name == "Attack2":
		if state == COMBO:
			if can_follow_enemy:
				#_dash_to_enemy(true)
				_enter_attack1_state(2, true)
				combo_list.clear()
			else:
				_enter_attack1_state(2, true)
		else:
			can_attack = true
			if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
				_enter_run_state()
			else:
				_enter_idle_state()
	if anim_name == "Attack3":
		if state == COMBO:
			pass
		else:
			can_attack = true
			if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
				_enter_run_state()
			else:
				_enter_idle_state()
	if anim_name == "SpinAttack":
		can_attack = true
		if state == COMBO:
			_enter_attack1_state(1, true)
		else:
			_enter_idle_state()
	if anim_name == "ComboSpinAttack":
		$SwordCutArea/SpinAttack.disabled = true
		can_attack = true
		_enter_idle_state()
	if anim_name == "TestCombo":
		_enter_idle_state()
		can_attack = true
	if anim_name == "JumpAttack":
		$NormalAttackArea/AttackJump.disabled = true
		_enter_idle_state()
		can_attack = true
	if anim_name == "PrepareAirAttack":
		state = ATTACK_AIR
	if anim_name == "Thrust2":
		$HurtBox/CollisionShape2D.disabled = false
		$NormalAttackArea/AirAttack.disabled = true
		animatedsmears.rotation_degrees = 0
		if is_on_floor():
			velocity.x = 0
			animationplayer.play("OnGroundAfterAttack")
			_enter_idle_state()
			can_jump = false
			return
	if anim_name == "OnGroundAfterAttack":
		can_jump = true

func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "PrepareAirAttack":
		state = PREPARE_ATTACK_AIR

func _on_HurtBox_area_entered(area):
	if area.is_in_group("EnemySword"):
		take_damage(5, direction.x)
	
	if area.is_in_group("Enemy"):
		take_damage(5, direction.x)



func _on_KinematicBody2D_dead() -> void:
	pass

func _on_KinematicBody2D_hurt() -> void:
	can_follow_enemy = true
	yield(get_tree().create_timer(1), "timeout")
	can_follow_enemy = false

func _on_KinematicBody2D_side_of_player(which_side):
	enemy_side_of_you = which_side




#Timers
func _on_BeenHurtTimer_timeout():
	velocity.y = 0
	_enter_idle_state()
	$FlashTimer.one_shot = true

func _on_FlashTimer_timeout():
	playersprite.material.set_shader_param("flash_modifier", 0)

func _on_ComboTimer_timeout():
	combo_list.clear()

func _on_CoyoteTimer_timeout():
	can_jump = false

func _on_DashTimer_timeout():
	_enter_idle_state()
	velocity = direction * MAX_SPEED
	direction.y = 0
	dashparticles.emitting = false
	#dashline.visible = false
	ghosttime = 0.0
	can_dash = true




