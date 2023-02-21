class_name Player
extends KinematicBody2D

#Se till att använda den där tiktok rösten som narrator
#Det här är för att se om github fungerar
enum {IDLE, RUN, AIR, DASH, STOP, ATTACK_GROUND, ATTACK_DASH, ATTACK_AIR, JUMP_ATTACK, PREPARE_ATTACK_AIR, HURT, COMBO, INVISIBLE}

const MAX_SPEED = 200
const ACCELERATION = 1000
const GRAVITY = 1300
const JUMP_STRENGHT = -480

export(String)var direction_x = "RIGHT"
var velocity := Vector2.ZERO
var direction := Vector2.ZERO

var state = IDLE

var rng = RandomNumberGenerator.new()

var can_jump := true
var can_dash := true
var can_attack := true
var can_take_damage := true
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

signal test(length)
signal HPChanged(hp)
signal XPChanged(current_xp)
signal LvlUp(current_lvl, xp_needed)


var ghost_scene = preload("res://Scenes/NewTestGhostDash.tscn")
var jl_scene = preload("res://Scenes/LandnJumpDust.tscn")
var dust_scene = preload("res://Scenes/ParticlesDust.tscn")
var skeleton_enemy_scene = preload("res://Scenes/SkeletonWarrior.tscn")
var prepare_attack_particles_scene = preload("res://Scenes/PreparingAttackParticles.tscn")
var buff_scene = preload("res://Scenes/BuffEffect.tscn")
var holy_particles_scene = preload("res://Scenes/HolyParticles.tscn")
var air_explosion_scene = preload("res://Scenes/AirExplosion.tscn")


var ghosttime := 0.0


onready var playersprite = $PlayerSprite
onready var animatedsmears = $SmearSprites
onready var animationplayer = $AnimationPlayer
onready var coyotetimer = $CoyoteTimer
onready var dashtimer = $DashTimer
onready var dashparticles = $Position2D/DashParticles
onready var attackparticles = $AttackParticles
onready var dashline = $Position2D/Line2D
onready var tween = $Tween
onready var player_stats_save_file = PlayerStats.game_data


export var damage_a1 := 5
export var damage_combo_qweq := 15
export var damage_combo_ewqe1 := 10
export var damage_combo_ewqe2 := 50
export var holy_buff_active := false
export var dark_buff_active := false
export var test_active := false
export (Vector2) var tester := Vector2.ZERO



var dash_to_enemy_distance = 50

var hit_the_ground = false
var motion_previous = Vector2()
var last_step = 0
var side = "RIGHT"
var xp_needed = 40
var has_leveled_up = false
var testpos = Vector2.ZERO
var testpos2 = Vector2.ZERO


#Player stats
var hp = 100
var max_hp = 100
var hp_regeneration = 1
var mana = 100
var mana_max = 100
var mana_regeneration = 2
var current_xp = 0
var current_lvl = 1

var comboewqe1_learned 


func _ready() -> void:
	player_stats_save_file
	$AnimationPlayer.playback_speed = 1

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
		INVISIBLE:
			_invisible_state(delta)

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

func _get_closest_enemy():
	var all_enemy = get_tree().get_nodes_in_group("Enemy")
	if len(all_enemy) > 0:
		var closest_enemy = all_enemy[0]
		for i in range(1, len(all_enemy)):
			if global_position.distance_to(all_enemy[i].global_position) < global_position.distance_to((closest_enemy.global_position)):
				closest_enemy = all_enemy[i]

		return closest_enemy

func _get_direction_to_enemy():
	var all_enemy = get_tree().get_nodes_in_group("Enemy")
	if len(all_enemy) > 0:
		var closest_enemy = _get_closest_enemy()
		var asdasd = global_position.direction_to(closest_enemy.global_position)
		
		tester = asdasd

func _get_furthest_away_enemy():
	var all_enemy = get_tree().get_nodes_in_group("Enemy")
	var furthest_away_enemy = all_enemy[0]
	if direction_x == "RIGHT":
		for i in range(1, len(all_enemy)):
			if all_enemy[i].global_position.x > furthest_away_enemy.global_position.x :
			#if global_position.distance_to(all_enemy[i].global_position) > global_position.distance_to((furthest_away_enemy.global_position)):
				furthest_away_enemy = all_enemy[i]
	else:
		for i in range(1, len(all_enemy)):
			if all_enemy[i].global_position.x < furthest_away_enemy.global_position.x :
			#if global_position.distance_to(all_enemy[i].global_position) > global_position.distance_to((furthest_away_enemy.global_position)):
				furthest_away_enemy = all_enemy[i]

	return furthest_away_enemy

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
	dashparticles.position.x = 0
	dashparticles.position.y = 0
	if right:
		playersprite.flip_h = false
		animatedsmears.flip_h = false
		$ComboSprites.flip_h = false
		animatedsmears.position.x = 30
		attackparticles.position.x = 30
		$NormalAttackArea/AttackGround.position.x = 46
		$SpecialAttackArea/Acid2.position.x = 62
		$SpecialAttackArea/Acid5.position.x = 92
		$SwordCutArea/SpinAttack.position.x = 44
	else:
		playersprite.flip_h = true
		animatedsmears.flip_h = true
		$ComboSprites.flip_h = true
		animatedsmears.position.x = -10
		attackparticles.position.x = -10
		$NormalAttackArea/AttackGround.position.x = -26
		$SpecialAttackArea/Acid2.position.x = -42
		$SpecialAttackArea/Acid5.position.x = -72
		$SwordCutArea/SpinAttack.position.x = -24

func _add_dash_ghost() -> void:
	var ghost = ghost_scene.instance()
	ghost.global_position = global_position + Vector2(0, -22)
	#ghost.global_position.y -= 20
	ghost.flip_h = playersprite.flip_h
	get_tree().get_root().add_child(ghost)

func _add_walk_dust(amount: int) -> void:
	var dust = dust_scene.instance()
	dust.amount = amount
	dust.global_position = playersprite.global_position + Vector2(0,23)
	dust.emitting = true
	get_tree().get_root().add_child(dust)

func _add_land_dust()-> void:
	var dust = jl_scene.instance()
	dust.global_position = playersprite.global_position + Vector2(0, 22) # 15
	dust.play("LandSmoke")
	get_tree().get_root().add_child(dust)


func _add_jump_dust() -> void:
	var dust = jl_scene.instance()
	#dust_scene.instance()
	#dust.amount = number
	#dust.global_position = playersprite.global_position + Vector2(0,23)
	#dust.emitting = true
	dust.global_position = playersprite.global_position + Vector2(0, 20)
	dust.play("JumpSmokeSide")
	get_tree().get_root().add_child(dust)

func _add_holy_particles(amount: int) -> void:
	for i in range(amount):
		rng.randomize()
		var random_number = rng.randi_range(1, 2)
		if random_number == 1:
			$Position2D2.position.x = 30
			$Position2D3.position.x = -10
		else:
			$Position2D2.position.x = -10
			$Position2D3.position.x = 30
		var particles = holy_particles_scene.instance()
		particles.global_position = global_position
		particles.emitting = true
		get_tree().get_root().add_child(particles)
		yield(get_tree().create_timer(0.5), "timeout")

func _add_buff(buff_name: String) -> void:
	var buff = buff_scene.instance()
	var effect1 = buff.get_child(0)
	buff.global_position = playersprite.global_position 
	if buff_name == "lvl_up":
		effect1.animation = "lvl_up"
	if buff_name == "holy":
		effect1.animation = "holy"
		playersprite.modulate.r = 2
		emit_signal("test", 0.3)
	if buff_name == "dark2":
		effect1.animation = "dark2"
	if buff_name == "lifesteal_particles":
		effect1.animation = "lifesteal_particles"
	if buff_name == "life_steal":
		effect1.animation = "life_steal"
		playersprite.modulate.r8 = 255
		playersprite.modulate.g8 = 130
		playersprite.modulate.b8 = 116
	get_tree().get_root().add_child(buff)
	
"""
	var all_enemy = get_tree().get_nodes_in_group("Enemy")
	if len(all_enemy) > 0:
		var closest_enemy = all_enemy[0]
		for i in range(1, len(all_enemy)):
			if global_position.distance_to(all_enemy[i].global_position) < global_position.distance_to((closest_enemy.global_position)):
				closest_enemy = all_enemy[i]
"""

func _add_first_air_explosion() -> void:
	state = INVISIBLE
	playersprite.visible = false
	$HurtBox/CollisionShape2D.disabled = true
	var explosion = air_explosion_scene.instance()
	var closest_enemy = _get_closest_enemy()
	explosion.global_position = global_position + Vector2(5, -15)
	get_tree().get_root().add_child(explosion)
	if (closest_enemy.global_position.x - global_position.x < 50 ) or ( global_position.x - closest_enemy.global_position.x < 50 ):
		tween.interpolate_property(explosion, "position", explosion.global_position, closest_enemy.global_position + Vector2(5, -15), 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		testpos = closest_enemy.global_position + Vector2(5, -15)
		testpos2 = closest_enemy.global_position
		global_position = testpos2

func _add_airexplosions(amount: int) -> void:
	var all_enemy = get_tree().get_nodes_in_group("Enemy")
	if len(all_enemy) > 1:
		for i in range(amount):
			if len(all_enemy) > 1:
				var explosion = air_explosion_scene.instance()
				var closest_enemy = all_enemy[0]
				if len(all_enemy) > 1:
					for j in range(1, len(all_enemy)):
						if testpos.distance_to(all_enemy[j].global_position) < testpos.distance_to((closest_enemy.global_position)):
							closest_enemy = all_enemy[j]
				explosion.global_position = testpos
				get_tree().get_root().add_child(explosion)
				if (closest_enemy.global_position.x - testpos.x < 50 ) or ( testpos.x - closest_enemy.global_position.x < 50 ):
					tween.interpolate_property(explosion, "position", testpos, closest_enemy.global_position + Vector2(5, -15), 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)#tween.targeting_property(explosion, "global_position", closest_enemy, "global_position", closest_enemy.global_position, 1.0, Tween.TRANS_SINE , Tween.EASE_IN)
					tween.start()
					testpos = closest_enemy.global_position + Vector2(5, -15)
					testpos2 = closest_enemy.global_position
					global_position = testpos2
				all_enemy.erase(closest_enemy)
				yield(get_tree().create_timer(0.2), "timeout")
					
	
	playersprite.visible = true
	_enter_idle_state()
	yield(get_tree().create_timer(1), "timeout")
	$HurtBox/CollisionShape2D.disabled = false
	
func take_damage(amount: int, direction: int) -> void:
	state = HURT
	if enemy_side_of_you == "right":
		direction_x = "RIGHT"
		velocity.x = -400
	if enemy_side_of_you == "left":
		direction_x = "LEFT"
		velocity.x = 400
	velocity.y = -300
	enemy_side_of_you = ""
	flash()
	frameFreeze(0.1, 0.5)
	playersprite.play("Hit")
	#$ImmuneTimer.start(2)
	can_take_damage = false
	hp -= amount
	emit_signal("HPChanged", hp)
	yield(get_tree().create_timer(0.3), "timeout")
	$FlashTimer.start(2)
	_alpha_tween()
	_enter_idle_state()

func frameFreeze(timescale, duration):
	Engine.time_scale = timescale
	yield(get_tree().create_timer(duration * timescale), "timeout")
	Engine.time_scale = 1

func flash():
	playersprite.material.set_shader_param("flash_modifier", 0.6)
	yield(get_tree().create_timer(0.2), "timeout")
	playersprite.material.set_shader_param("flash_modifier", 0.0)
	
func _alpha_tween() -> void:
	var alpha_tween_values = [255, 60]
	for i in range (4):
		tween.interpolate_property(playersprite, "modulate:a8", alpha_tween_values[0], alpha_tween_values[1], 0.25)
		tween.start()
		yield(get_tree().create_timer(0.25), "timeout")
		alpha_tween_values.invert()
		tween.interpolate_property(playersprite, "modulate:a8", alpha_tween_values[0], alpha_tween_values[1], 0.25)
		tween.start()
		alpha_tween_values.invert()
		
func _modulate_tween()-> void:
	var modulate_tween_values = [1, 10]
	for i in range(4):
		tween.interpolate_property(playersprite, "modulate:r", modulate_tween_values[0], modulate_tween_values[1], 0.25)
		tween.start()
		yield(get_tree().create_timer(0.25), "timeout")
		modulate_tween_values.invert()
		tween.interpolate_property(playersprite, "modulate:r", modulate_tween_values[0], modulate_tween_values[1], 0.25)
		tween.start()
		modulate_tween_values.invert()

func _player_immune():
	playersprite.modulate.a8 = lerp(playersprite.modulate.a8, 255, 60)
	yield(get_tree().create_timer(0.2), "timeout")

func _remember_jump() -> void:
	yield(get_tree().create_timer(jump_buffer), "timeout")
	jump_pressed = false

func _remember_attack() -> void:
	yield(get_tree().create_timer(attack_buffer), "timeout")
	attack_pressed = 0

func _dash_to_enemy(switch_side: bool) -> void:
	var close_enemy = _get_closest_enemy()
	var far_enemy = _get_furthest_away_enemy()
	if can_follow_enemy:
		print("dukan")
		if not switch_side:
			if global_position.x >= close_enemy.global_position.x:
				tween.interpolate_property(self, "global_position", global_position, close_enemy.global_position + Vector2(30, 0), 0.05, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)# + Vector2(5, -15), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				tween.start()
				#global_position.x = close_enemy.global_position.x + 30 #Vector2(30, 0)
				direction_x = "LEFT"
				_flip_sprite(false)
			else:
				tween.interpolate_property(self, "global_position", global_position.x, close_enemy.global_position.x - 30, 0.05, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)# + Vector2(5, -15), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				tween.start()
				
				#global_position.x = close_enemy.global_position.x - 30# Vector2(30, 0)
				direction_x = "RIGHT"
				_flip_sprite(true)
		else:
			if global_position.x <= far_enemy.global_position.x:
				global_position.x = far_enemy.global_position.x + 30# + Vector2(30, -4)
				direction_x = "LEFT"
				_flip_sprite(false)
			else:
				global_position.x = far_enemy.global_position.x - 30# - Vector2(30, 4)
				direction_x = "RIGHT"
				_flip_sprite(true)
	
func check_combo() -> void:
	var re_combo_list = []
	for i in range(0, combo_list.size()):
		re_combo_list.push_front(combo_list[i])
	if re_combo_list[0] == 1:
		if re_combo_list[1] == 3:
			if re_combo_list[2] == 2:
				if re_combo_list[3] == 1: 
					_enter_combo_state(1)
	elif re_combo_list[0] == 3:
		if re_combo_list[1] == 1:
			if re_combo_list[2] == 2:
				if re_combo_list[3] == 3: 
					_enter_combo_state(2)

func player_stats_lvl(current_lvl):
	if current_lvl == 2:
		$SpecialAttackArea.add_to_group("ComboEWQE2")
		$SpecialAttackArea.remove_from_group("ComboEWQE1")

func player_stats():
	if holy_buff_active:
		damage_a1 = 10
		damage_combo_ewqe1 = 20
		damage_combo_ewqe2 = 100
		damage_combo_qweq = 30
	elif dark_buff_active:
		damage_a1 = 7
		damage_combo_ewqe1 = 15
		damage_combo_ewqe2 = 37
		damage_combo_qweq = 23
	else:
		damage_a1 = 5
		damage_combo_ewqe1 = 10
		damage_combo_ewqe2 = 50
		damage_combo_qweq = 15

func _level_up(current_xp, xp_needed):
	if current_xp >= xp_needed:
		current_lvl += 1
		has_leveled_up = true
		player_stats_lvl(current_lvl)
		_add_buff("lvl_up")
		return true
	else:
		return false

func _set_sprite_position(anim_name):
	if anim_name == "ComboEWQE2":
		if direction_x == "RIGHT":
			$ComboSprites.position.x = 95
			$ComboSprites.flip_h = false 
		if direction_x == "LEFT":
			$ComboSprites.position.x = -75
			$ComboSprites.flip_h = true
	if anim_name == "ComboEWQE3":
		if direction_x == "RIGHT":
			$ComboSprites.position.x = 35
			$ComboSprites.flip_h = false 
		else:
			$ComboSprites.position.x = -15
			$ComboSprites.flip_h = true

func _add_preparing_attack_particles(amount) -> void:
	for n in range (amount):
		rng.randomize()
		var nrx = rng.randi_range(-100, 100)
		var nry = rng.randi_range(-100, 100)
		var particles = prepare_attack_particles_scene.instance()
		particles.global_position = playersprite.global_position + Vector2(nrx, nry)
		get_tree().get_root().add_child(particles)
	
#STATES:
func _idle_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	
	if Input.is_action_just_pressed("SkillTree"):
		get_tree().change_scene("res://UI/SkillSystemMenu.tscn")
	
	if (Input.is_action_just_pressed("Jump") and can_jump) or jump_pressed == true:
		_add_walk_dust(15)
		_enter_air_state(true)
		return
	
	if Input.is_action_just_pressed("HolyBuff1") and not holy_buff_active:
		_add_buff("holy")
		_add_holy_particles(10)
		holy_buff_active = true
		can_take_damage = false
		yield(get_tree().create_timer(3), "timeout")
		#_modulate_tween()
		yield(get_tree().create_timer(2), "timeout")
		playersprite.modulate.r = 1
		can_take_damage = true
		holy_buff_active = false
	
	if Input.is_action_just_pressed("DarkBuff") and not dark_buff_active:
		_add_buff("dark2")
		dark_buff_active = true
		yield(get_tree().create_timer(7.2), "timeout")
		dark_buff_active = false
	
	if Input.is_action_just_pressed("Fx000"):
		test_active = true
		yield(get_tree().create_timer(10), "timeout")
		test_active = false
		#_add_buff("life_steal")
		#yield(get_tree().create_timer(2), "timeout")
		#playersprite.modulate.r8 = 255
		#playersprite.modulate.g8 = 255
		#playersprite.modulate.b8 = 255
	
	if Input.is_action_just_pressed("AirExplosion"):
		_get_direction_to_enemy()
		_add_first_air_explosion()
		#emit_signal("test", 0.8)
		yield(get_tree().create_timer(0.2), "timeout")
		_add_airexplosions(10)
	
	if Input.is_action_just_pressed("Dash"):
		_dash_to_enemy(false)

	
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

	if playersprite.frame == 1:
		last_step += 1
		if last_step == 4:
			_add_walk_dust(5)
			last_step = 0
				
	if (Input.is_action_just_pressed("Jump") and can_jump) or jump_pressed == true:
		_add_jump_dust()
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
	_air_movement(delta)		

func _invisible_state(delta) -> void:
	pass
	#global_position = testpos2
	#playersprite.visible = false
	#$HurtBox/CollisionShape2D.disabled = true


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
	player_stats()
	is_attacking = true
	animatedsmears.position.y = -15
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
	combo_list.append(previous_attack) 
	if combo_list.size() >= 4:
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
		frameFreeze(0.3, 0.4)

func _enter_combo_state(number : int) -> void:
	state = COMBO
	if Input.is_action_pressed("Dash"):
		_dash_to_enemy(true)
	if number == 1: 
		animationplayer.play("ComboSpinAttack")
		combo_list.clear()
	if number == 2:
		if direction_x == "RIGHT":
			if current_lvl <= 1:
				$ComboSprites.position.x = 62
			else:
				$ComboSprites.position.x = 95
			$ComboSprites.flip_h = false
		else:
			if current_lvl <= 1:
				$ComboSprites.position.x = -42
			else:
				$ComboSprites.position.x = -75
			$ComboSprites.flip_h = true
		if current_lvl <= 1 and player_stats_save_file.EWQE1 == true:#(comboewqe1_learned == true):
			animationplayer.play("ComboEWQE1")
		else:
			animationplayer.play("ComboEWQE2")
			emit_signal("test", 0.2)
		combo_list.clear()
		
#Signals

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack1":
		if state == COMBO:
			_enter_attack1_state(2, true)
		else:
			can_attack = true
			if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
				_enter_run_state()
			elif Input.is_action_pressed("Dash"):
				_dash_to_enemy(false)
			else:
				_enter_idle_state()
	if anim_name == "Attack2":
		can_attack = true
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			_enter_run_state()
		elif Input.is_action_pressed("Dash"):
			_dash_to_enemy(false)
		else:
			_enter_idle_state()
	if anim_name == "Attack3":
		if state == COMBO:
			pass
		else:
			can_attack = true
			if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
				_enter_run_state()
			elif Input.is_action_pressed("Dash"):
				_dash_to_enemy(false)
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
	if anim_name == "ComboEWQE1":
		_enter_idle_state()
		can_attack = true
	if anim_name =="ComboEWQE2":
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
#	
func _on_timer_timeout() -> void:
	#frameFreeze(0.1, 0.5)
	pass



func _on_HurtBox_area_entered(area):
	var amount = 5
	if dark_buff_active:
		amount = 10
	if can_take_damage:
		if area.is_in_group("EnemySword"):
			take_damage(amount, direction.x)
	#	if area.is_in_group("Enemy"):
	#		take_damage(amount, direction.x)
	
		

func _on_CollectParticlesArea_area_entered(area) -> void:
	if area.is_in_group("XP-Particle"):
		current_xp += 40
		if _level_up(current_xp, xp_needed):
			current_xp = 0
			xp_needed = xp_needed + pow(1.5, (current_lvl*2))
			emit_signal("LvlUp", current_lvl, xp_needed)
		emit_signal("XPChanged", current_xp)

func _on_KinematicBody2D_dead() -> void:
	pass

func _on_KinematicBody2D_hurt() -> void:
	pass
	
		


func _on_NormalAttackArea_area_entered(area):
	if area.is_in_group("EnemyHitbox"):
		if not can_follow_enemy:
			can_follow_enemy = true
			$NewTimer.start(1)
		if test_active:
			_add_buff("lifesteal_particles")
		
		

func _on_KinematicBody2D_side_of_player(which_side):
	enemy_side_of_you = which_side




#Timers
func _on_ImmuneTimer_timeout():
	pass
	#can_take_damage = true
	#_enter_idle_state()

func _on_FlashTimer_timeout():
	if not holy_buff_active:
		can_take_damage = true
	tween.stop(playersprite)


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

func _on_NewTimer_timeout():
	can_follow_enemy = false


func _on_KinematicBody2D_pos(position) -> void:
	pass # Replace with function body.


