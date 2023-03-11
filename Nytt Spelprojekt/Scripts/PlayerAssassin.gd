extends KinematicBody2D

#Se till att använda den där tiktok rösten som narrator
#Det här är för att se om github fungerar
enum {IDLE, RUN, AIR, DASH_AIR, DASH_GROUND, STOP, ATTACK_GROUND, ATTACK_DASH, ATTACK_AIR, JUMP_ATTACK, PREPARE_ATTACK_AIR, HURT, COMBO, INVISIBLE}


const MAX_SPEED = 250
const ACCELERATION = 1000
const GRAVITY = 1000
const JUMP_STRENGHT = -500



export(String)var direction_x = "RIGHT"
export(String) var direction_y = "UP"

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
var can_add_ass_ghost := false
var attack_pressed = 0
var previous_attack = 0
var combo_list = []
var hit_count = 0

var enemy_side_of_you

var jump_buffer = 0.15
var attack_buffer = 0.3
var hit_amount = 0

signal test(length)
signal HPChanged(hp)
signal XPChanged(current_xp)
signal EnergyChanged(energy)
signal LvlUp(current_lvl, xp_needed)

const JUMP_SOUNDS = [preload("res://Sounds/ImportedSounds/JumpSounds/004_jump.wav"), preload("res://Sounds/ImportedSounds/JumpSounds/003_jump.wav"), preload("res://Sounds/ImportedSounds/JumpSounds/001_jump.wav"), preload("res://Sounds/ImportedSounds/JumpSounds/007_jump.wav"), preload("res://Sounds/ImportedSounds/JumpSounds/002_jump.wav")]
const ATTACK_SOUNDS = [preload("res://Sounds/ImportedSounds/AttackSounds/001_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/002_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/003_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/004_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/005_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/006_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/007_swing.wav")]
var can_jump_sound = true
var can_attack_sound = true


var ghost_scene = preload("res://Instance_Scenes/GhostDashAssassin.tscn")
var speedline_scene = preload("res://Instance_Scenes/Speedlines.tscn")
var new_ghost_scene = preload("res://Instance_Scenes/AssassinGhost.tscn")
var dash_smoke_scene = preload("res://Instance_Scenes/DashSmokeAssassin.tscn")
var jl_scene = preload("res://Instance_Scenes/LandnJumpDust.tscn")
var dust_scene = preload("res://Instance_Scenes/ParticlesDustAssassin.tscn")
var skeleton_enemy_scene = preload("res://Scenes/SkeletonWarrior.tscn")
var prepare_attack_particles_scene = preload("res://Scenes/PreparingAttackParticles.tscn")
var buff_scene = preload("res://Instance_Scenes/BuffEffect.tscn")
var holy_particles_scene = preload("res://Scenes/HolyParticles.tscn")
var air_explosion_scene = preload("res://Instance_Scenes/AirExplosion.tscn")
var dash_particles_scene = preload("res://Instance_Scenes/DashParticlesAssassin.tscn")
var shockwave_scene = preload("res://Instance_Scenes/Shockwave.tscn")
var clone_scene = preload("res://Instance_Scenes/AssassinClone.tscn")
var dash_attack_scene = preload("res://Instance_Scenes/AssassinDashAttack.tscn")
var impact_scene = preload("res://Scenes/Impact_Scene.tscn")
var energy_scene = preload("res://Instance_Scenes/AssassinEnergyParticle.tscn")

var ghosttime := 0.0

onready var playersprite = $PlayerSprite
onready var animatedsmears = $SmearSprites
onready var animationplayer = $AnimationPlayer
onready var coyotetimer = $CoyoteTimer
onready var dashtimer = $DashTimer
onready var attackparticles = $AttackParticles
onready var tween = $Tween
onready var player_stats_save_file = PlayerStats.game_data


export var damage_a1 := 5
export var damage_combo_qweq := 15
export var damage_combo_ewqe1 := 10
export var damage_combo_ewqe2 := 50
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
var test_var_enemy 


#Player stats
var hp = 100
var max_hp = 100
var energy = 50
var max_energy = 50
var current_xp = 0
var current_lvl = 1
var previous_state = IDLE



func _ready() -> void:

	PlayerStats.connect("EnemyDead", self, "on_EnemyDead")
	playersprite.visible = true
	$AnimationPlayer.playback_speed = 1
	$SkillTreeInGameAssassin/Control/CanvasLayer.visible = false

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		RUN:
			_run_state(delta)
		AIR:
			_air_state(delta)
		DASH_AIR:
			_dash_state_air(delta)
		DASH_GROUND:
			_dash_state_ground(delta)
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

func check_sprites():
	$NormalAttackArea/AirAttack.disabled = true
	$NormalAttackArea/AttackGround.disabled = true
	$NormalAttackArea/AttackJump.disabled = true
	$SwordCutArea/SpinAttack.disabled = true
	$Thrusts.visible = false
	$ComboSprites.visible = false
	animatedsmears.visible = false
	can_attack = true

func _get_random_sound(type: String) -> void:
	rng.randomize()
	if type == "Jump":
		var number = rng.randi_range(0, JUMP_SOUNDS.size()-1)
		$JumpSound.stream = JUMP_SOUNDS[number]
		var jump_sound_timer = Timer.new()
		jump_sound_timer.one_shot = true
		jump_sound_timer.connect("timeout", self, "on_jump_sound_timer_timeout")
		add_child(jump_sound_timer)
	#	jump_sound_timer.start(1.0)
	if type == "Attack":
		var number = rng.randi_range(0, ATTACK_SOUNDS.size()-1)
		$AttackSound.stream = ATTACK_SOUNDS[number]
		var attack_sound_timer = Timer.new()
		attack_sound_timer.one_shot = true
		attack_sound_timer.connect("timeout", self, "on_attack_sound_timer_timeout")
		add_child(attack_sound_timer)
	#	attack_sound_timer.start(0.5)
	$JumpSound.pitch_scale = BackgroundMusic.voice_pitch_scale
	$AttackSound.pitch_scale = BackgroundMusic.voice_pitch_scale
		

func _add_impact(dir):
	var flip 
	var impact = impact_scene.instance()
	impact.global_position = global_position + Vector2(dir*100, 15)
	impact.flip_h = playersprite.flip_h
	get_tree().get_root().add_child(impact)

func _add_dash_attack():
	var dash = dash_attack_scene.instance()
	if direction_x == "RIGHT":
		dash.global_position = global_position + Vector2(50, -10)
	else:
		dash.global_position = global_position + Vector2(-50, -10)
	dash.global_position = global_position
	dash.flip_h = playersprite.flip_h
	dashtimer.start(0.25)
	add_child(dash)
	yield(get_tree().create_timer(0.25),"timeout")
	_add_impact(direction.x)
	
func _add_dash_smoke(name: String):
	var smoke = dash_smoke_scene.instance()
	var flip 
	if playersprite.flip_h == true:
		flip = false
	else:
		flip = true
	if name == "ImpactDustKick":
		smoke.animation = "ImpactDustKick"
		smoke.global_position = global_position + Vector2(-10*direction.x, -10)
		smoke.flip_h = flip
	if name == "test2":
		smoke.animation = "New Anim 1"
		smoke.global_position = global_position + Vector2(-30* direction.x, 0)
		smoke.flip_h = flip
	get_tree().get_root().add_child(smoke)
	
func _add_speedlines():
	var lines = speedline_scene.instance()
	lines.global_position = global_position
	add_child(lines)

func _spawn_energy(enemy):
	var energy = energy_scene.instance()
	energy.global_position = enemy.global_position
	hit_count = 0
	get_tree().get_root().call_deferred("add_child", energy)
	

func _add_shockwave():
	var wave = shockwave_scene.instance()
	add_child(wave)
	#_add_speedlines()
	yield(get_tree().create_timer(0.5),"timeout")
	wave.queue_free()

func _add_clone(enemy, anim: String):
	var all_enemy = PlayerStats.enemies_hit_by_player
	rng.randomize()
	if all_enemy.size() > 0:
		var enemy_ind = rng.randi_range(0, all_enemy.size() - 1)
		enemy = all_enemy[enemy_ind]
		var clone = clone_scene.instance()
		var animplayer = clone.get_child(2)
		var smearsp = clone.get_child(1)
		var flip 
		var dir
		if playersprite.flip_h == true:
			flip = false
			dir = -1
		else:
			flip = true
			dir = 1
		smearsp.animation = animatedsmears.animation
		#clone.ani = _get_smearsprite("q")
		clone.global_position = enemy.global_position + Vector2(30*dir, -5)
		clone.flip_h = flip #playersprite.flip_h
		get_tree().get_root().add_child(clone)

func _add_assassin_ghost(amount:int):
	if amount == 0:
		var ghost = new_ghost_scene.instance()
		ghost.animation = playersprite.animation
		ghost.frame = playersprite.frame
		ghost.global_position = global_position
		#ghost.global_position.y -= 20
		ghost.flip_h = playersprite.flip_h
		get_tree().get_root().add_child(ghost)
	else:
		for i in range(amount):
			var ghost = new_ghost_scene.instance()
			ghost.animation = playersprite.animation
			ghost.frame = playersprite.frame
			ghost.global_position = global_position
			#ghost.global_position.y -= 20
			ghost.flip_h = playersprite.flip_h
			get_tree().get_root().add_child(ghost)
			yield(get_tree().create_timer(0.1), "timeout")

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

func _get_closest_enemy_index(enemy_group):
	var index 
	if len(enemy_group) > 0:
		var closest_enemy = enemy_group[0]
		for i in range(1, len(enemy_group)):
			if global_position.distance_to(enemy_group[i].global_position) < global_position.distance_to((closest_enemy.global_position)):
				closest_enemy = enemy_group[i]
				index = i
	
		return index
		

	

func _get_closest_enemy(enemy_group):
	if len(enemy_group) > 0:
		var closest_enemy = enemy_group[0]
		for i in range(0, len(enemy_group)-1):
			if is_instance_valid(enemy_group[i]):
				if global_position.distance_to(enemy_group[i].global_position) < global_position.distance_to((closest_enemy.global_position + Vector2(5, 0))):
					closest_enemy = enemy_group[i]
			else:
				return closest_enemy

		return closest_enemy

func _get_direction_to_enemy(enemy):
	var all_enemy = get_tree().get_nodes_in_group("Enemy")
	if len(all_enemy) > 0:
		
		var direction = global_position.direction_to(enemy.global_position)
		tester = direction
		
		return direction
	

func _get_furthest_away_enemy(enemy_group):
	if len(enemy_group) > 0:
		var furthest_enemy = enemy_group[0]
		for i in range(0, len(enemy_group)-1):
			if is_instance_valid(enemy_group[i]):
				if global_position.distance_to(enemy_group[i].global_position) > global_position.distance_to((furthest_enemy.global_position )):
					furthest_enemy = enemy_group[i]
			else:
				return furthest_enemy

		return furthest_enemy


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
		$ComboSprites.flip_h = false
		animatedsmears.position.x = 20
		attackparticles.position.x = 20
		$NormalAttackArea/AttackGround.position.x = 36
		$NormalAttackArea/AttackJump.position.x = 20
		$SwordCutArea/SpinAttack.position.x = 34
	else:
		playersprite.flip_h = true
		animatedsmears.flip_h = true
		$ComboSprites.flip_h = true
		animatedsmears.position.x = -20
		attackparticles.position.x = -20
		$NormalAttackArea/AttackGround.position.x = -36
		$NormalAttackArea/AttackJump.position.x = -20
		$SwordCutArea/SpinAttack.position.x = -34

func _add_dash_ghost() -> void:
	var ghost = ghost_scene.instance()
	ghost.global_position = global_position + Vector2(0, -2)
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
	dust.play("LandSmokeAssassin")
	get_tree().get_root().add_child(dust)

func _add_jump_dust() -> void:
	var dust = jl_scene.instance()
	dust.global_position = playersprite.global_position + Vector2(0, 20)
	dust.play("JumpSmokeSideAssassin")
	get_tree().get_root().add_child(dust)


func _add_dash_particles(amount: int) -> void:
	for i in range(amount):
		var particles = dash_particles_scene.instance()
		particles.global_position = global_position + Vector2(0, 5)
		particles.emitting = true
		get_tree().get_root().add_child(particles)
		yield(get_tree().create_timer(0.01), "timeout") 

func _add_buff(buff_name: String) -> void:
	var buff = buff_scene.instance()
	var effect1 = buff.get_child(0)
	buff.global_position = playersprite.global_position 
	if buff_name == "lvl_up":
		effect1.animation = "lvl_up"
	get_tree().get_root().add_child(buff)
	

func _add_first_air_explosion() -> void:
	var all_enemy = get_tree().get_nodes_in_group("Enemy")
	state = INVISIBLE
	playersprite.visible = false
	$HurtBox/CollisionShape2D.disabled = true
	var explosion = air_explosion_scene.instance()
	var closest_enemy = _get_closest_enemy(all_enemy)
	explosion.global_position = global_position + Vector2(5, -15)
	if is_instance_valid(closest_enemy):
		get_tree().get_root().add_child(explosion)
		if global_position.distance_to(closest_enemy.global_position) < 60:#(closest_enemy.global_position.x - global_position.x < 50 ) or ( global_position.x - closest_enemy.global_position.x < 50 ):
			tween.interpolate_property(explosion, "position", explosion.global_position, closest_enemy.global_position + Vector2(5, -15), 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.start()
			testpos = closest_enemy.global_position + Vector2(5, -15)
			testpos2 = closest_enemy.global_position + Vector2(0, - 30)
			global_position = testpos2

func _add_airexplosions() -> void:
	state = INVISIBLE
	var all_enemy = get_tree().get_nodes_in_group("Enemy")
	var variable_enemy = all_enemy
	var closest_enemy 
	for i in range(all_enemy.size()):
		var explosion = air_explosion_scene.instance()
		if len(variable_enemy) > 0:
			closest_enemy = _get_closest_enemy(variable_enemy)
			explosion.global_position = testpos
			get_tree().get_root().add_child(explosion)
			if is_instance_valid(closest_enemy):	
				if (closest_enemy.global_position.x - testpos.x < 50 ) or ( testpos.x - closest_enemy.global_position.x < 50 ):
					tween.interpolate_property(explosion, "position", testpos, closest_enemy.global_position + Vector2(5, -15), 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)#tween.targeting_property(explosion, "global_position", closest_enemy, "global_position", closest_enemy.global_position, 1.0, Tween.TRANS_SINE , Tween.EASE_IN)
					tween.start()
					testpos = closest_enemy.global_position + Vector2(5, -15)
					testpos2 = closest_enemy.global_position + Vector2(0, - 30)
					global_position = testpos2
					variable_enemy.erase(closest_enemy)
				yield(get_tree().create_timer(0.1), "timeout")
				
	
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

func _dash_to_enemy(enemy, switch_side: bool) -> void:
	if can_follow_enemy:
		if not switch_side:
			if is_instance_valid(enemy):
				if global_position.x >= enemy.global_position.x:
					#tween.interpolate_property(self, "global_position", global_position.x, enemy.global_position.x + 30, 0.05, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)# + Vector2(5, -15), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					#tween.start()
					global_position.x = enemy.global_position.x + 30 #Vector2(30, 0)
					direction_x = "LEFT"
					_flip_sprite(false)
				else:
					#tween.interpolate_property(self, "global_position", global_position.x, enemy.global_position.x - 30, 0.05, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)# + Vector2(5, -15), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					#tween.start()
					
					global_position.x = enemy.global_position.x - 30# Vector2(30, 0)
					direction_x = "RIGHT"
					_flip_sprite(true)
		else:
			if is_instance_valid(enemy):
				if global_position.distance_to(enemy.global_position) < 100:
					if global_position.x <= enemy.global_position.x:
						global_position.x = enemy.global_position.x + 30# + Vector2(30, -4)
						direction_x = "LEFT"
						_flip_sprite(false)
					else:
						global_position.x = enemy.global_position.x - 30# - Vector2(30, 4)
						direction_x = "RIGHT"
						_flip_sprite(true)
		
			
		

func _get_smearsprite(button: String):
	if button == "q":
		animatedsmears.animation = PlayerStats.assassin_smearsprite_q
	if button == "w":
		animatedsmears.animation = PlayerStats.assassin_smearsprite_w
	if button == "e":
		animatedsmears.animation = PlayerStats.assassin_smearsprite_e

func check_combo() -> void:
	var re_combo_list = []
	for i in range(0, combo_list.size()):
		re_combo_list.push_front(combo_list[i])
	if re_combo_list[0] == 1 and energy >= 10:
		if re_combo_list[1] == 3:
			if re_combo_list[2] == 2:
				if re_combo_list[3] == 1: 
					_enter_combo_state(1)
	elif re_combo_list[0] == 3 and energy >= 20: # elif
		if re_combo_list[1] == 1:
			if re_combo_list[2] == 2:
				if re_combo_list[3] == 3: 
					_enter_combo_state(2)
	elif re_combo_list[0] == 2 and energy >= 20:
		if re_combo_list[1] == 1:
			if re_combo_list[2] == 3:
				if re_combo_list[3] == 2:
					_enter_combo_state(3)
	else:
		_enter_idle_state()
	

func _get_random_attack():
	var attack = "Attack"
	rng.randomize()
	var nr = rng.randi_range(1, 3)
	attack = "Attack"+str(nr)
	print("attack: " + str(attack))
	return attack

func on_lvl_up_variables(current_lvl):
	pass
	
func player_stats_lvl(current_lvl):
	if current_lvl == 2:
		pass
		#$SpecialAttackArea.add_to_group("ComboEWQE2")
		#$SpecialAttackArea.remove_from_group("ComboEWQE1")

func player_stats():
	damage_a1 = 5
	damage_combo_ewqe1 = 10
	damage_combo_qweq = 15
func _level_up(current_xp, xp_needed):
	if current_xp >= xp_needed:
		current_lvl += 1
		has_leveled_up = true
		on_lvl_up_variables(current_lvl)
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
	
	if Input.is_action_pressed("SkillTree"):
		$SkillTreeInGameAssassin/Control/CanvasLayer.visible = true
		
	if Input.is_action_just_released("SkillTree"):
		$SkillTreeInGameAssassin/Control/CanvasLayer.visible = false
	
	if (Input.is_action_just_pressed("Jump") and can_jump) or jump_pressed == true:
		_add_walk_dust(15)
		_enter_air_state(true)
		if can_jump_sound:
			_get_random_sound("Jump")
			$JumpSound.play()
			#can_jump_sound = false
		return
	
	if Input.is_action_just_pressed("AirExplosion"):
		pass

	
	
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
		if can_jump_sound:
			_get_random_sound("Jump")
			$JumpSound.play()
			#can_jump_sound = false
		return
	
	if Input.is_action_just_pressed("Dash") and can_dash:
		_add_dash_smoke("ImpactDustKick")
		#_add_dash_particles(25)
		_enter_dash_state(false, true)
		return
		
	if Input.is_action_just_pressed("EAttack1"):
		_enter_dash_attack_state(1)
	if Input.is_action_just_pressed("AttackE"):
		_enter_dash_attack_state(1)
	
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
		#_add_dash_smoke("ImpactMedium1")
		_add_dash_smoke("test2")
		_enter_dash_state(false, false)
		return
	
	if Input.is_action_just_pressed("EAttack1"):
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

	ghosttime += delta
	if ghosttime >= 0.08:
		_add_assassin_ghost(0)
		ghosttime = 0.0

	_air_movement(delta)
	var current_animation = playersprite.get_animation()
	if is_on_floor(): 
		#if jump_pressed == false:
		_add_land_dust()
		_enter_idle_state()
		$JustLandedTimer.start(2)
		can_add_ass_ghost = true
		return
	if velocity.y >= 0:
		if velocity.x == 0:
			playersprite.play("FallN")
			return
		else: 
			playersprite.play("FallF")
			return

	

func _dash_state_air(delta):
	velocity = velocity.move_toward(direction*MAX_SPEED*3, ACCELERATION*delta*3)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	ghosttime += delta
	
	if ghosttime >= 0.09:
		_add_dash_ghost()
		ghosttime = 0.07

func _dash_state_ground(delta):
	velocity = velocity.move_toward(direction*MAX_SPEED*3, ACCELERATION*delta*3)
	
	velocity = move_and_slide(velocity, Vector2.UP)

func _stop_state(delta):
	direction.x = _get_input_x_update_direction()
	var input_x = Input.get_axis("move_left", "move_right")
	_apply_basic_movement(delta)

	if Input.is_action_just_pressed("Jump") and can_jump:
		_enter_air_state(true)
		if can_jump_sound:
			_get_random_sound("Jump")
			$JumpSound.play()
			can_jump_sound = false
		return
	
	if Input.is_action_just_pressed("Dash") and can_dash:
		_enter_dash_state(false, true)
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
	velocity = velocity.move_toward(direction*MAX_SPEED*3, ACCELERATION*delta*3)
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
	if Input.is_action_just_pressed("Dash"):
		_dash_to_enemy(test_var_enemy, true)
	
	
func _hurt_state(delta) -> void:	
	_air_movement(delta)		
func _invisible_state(delta) -> void:
	pass
	#global_position = testpos2
	#playersprite.visible = false
	#$HurtBox/CollisionShape2D.disabled = true


#Enter states
func _enter_idle_state() -> void:
	check_sprites()
	state = IDLE
	playersprite.play("Idle")
	can_jump = true
	if can_add_ass_ghost:
		pass
		#_add_assassin_ghost(20)

func _enter_dash_state(attack: bool, ground:bool) -> void:
	check_sprites()
	_add_shockwave()
	direction = Input.get_vector("move_left", "move_right","ui_up", "ui_down")
	if state == IDLE and direction == Vector2.DOWN:
		return
	elif direction == Vector2.ZERO:
		direction.x = 1 if direction_x == "RIGHT" else -1
		direction_y = "DOWN"
	if direction == Vector2.UP:
		direction_y = "UP"
		#direction
	$DashSound.play()
	if ground == false:
		#3, 3, 3
		#playersprite.modulate.r = 0.15
		#playersprite.modulate.g = 0.23
		#playersprite.modulate.b = 0.37
		#playersprite.play("Dash")
		state = DASH_AIR
		#_add_dash_particles(25)
		#dashline.visible = true
		#can_dash = false
		#dashtimer.start(0.25)
	else:
		state = DASH_GROUND
		#playersprite.modulate.r = 2.75
		#playersprite.modulate.g = 1
		#playersprite.modulate.b = 1.85
	playersprite.modulate.r = 0.15
	playersprite.modulate.g = 0.23
	playersprite.modulate.b = 0.37
	#playersprite.material.set_shader_param("flash_modifier", 0.8)
	playersprite.play("Dash")
	#dashline.visible = true
	can_dash = false
	dashtimer.start(0.25)
		
func _enter_air_state(jump: bool) -> void:
	check_sprites()
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
	check_sprites()
	state = RUN
	can_jump = true
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
	animatedsmears.position.y = 5
	if attack == 1:
		animationplayer.play("Attack1")
		previous_attack = 1
		#$NormalAttackArea/AttackGround.disabled = false
	if attack == 2:
		animationplayer.play("Attack2")
		previous_attack = 2
	if attack == 3:
		animationplayer.play("Attack3")
		previous_attack = 3
	if attack == 4:
		animationplayer.play("SpinAttack")
	can_attack = false
	if can_attack_sound:
		_get_random_sound("Attack")
		$AttackSound.play()
		#can_attack_sound = false
	combo_list.append(previous_attack) 
	if combo_list.size() >= 4:
		check_combo()
	#if combo_list.size() == 0:
	#	_enter_idle_state()

func _enter_dash_attack_state(attack: int) -> void:
	if attack == 1 and energy >= 5:
		state = ATTACK_DASH
		#animationplayer.play("DashAttack")
		playersprite.play("SpinAttack")
		_add_dash_attack()
		energy -= 5
		emit_signal("EnergyChanged", energy)
		can_attack = false

func _enter_attack_air_state(Jump: bool) -> void:
	if Jump:
		animatedsmears.position.y = 0
		state = JUMP_ATTACK
		animationplayer.play("JumpAttack")
		$NormalAttackArea/AttackJump.disabled = false
	else:
		animationplayer.play("PrepareAirAttack")
		frameFreeze(0.3, 0.4)

func _enter_combo_state(number : int) -> void:
	ghosttime = 0.0
	var enemy_list = PlayerStats.enemies_hit_by_player
	var enemy = _get_closest_enemy(PlayerStats.enemies_hit_by_player)
	var furthest_away_enemy = _get_furthest_away_enemy(PlayerStats.enemies_hit_by_player)
	test_var_enemy = enemy
#	var side = _get_direction_to_enemy(enemy)
	state = COMBO
	if number == 1: 
		animationplayer.play("ComboSpinAttack")
		combo_list.clear()
		energy -= 10
		if Input.is_action_pressed("Dash") and energy >= 10:
			for i in range(PlayerStats.assassin_clone_targets):
				_add_clone(enemy, "Attack1") # spinattack
				energy -= 10
		emit_signal("EnergyChanged", energy)
	if number == 2:
		can_take_damage = false
		var list = PlayerStats.enemies_hit_by_player
		var clone_added = false
		energy -= 20
		for i in range(0, list.size() -1):
			if list.size()-1 >= i:
				var attack = _get_random_attack()
				animationplayer.playback_speed = 4.0
				animationplayer.play(attack)
				frameFreeze(0.2*i, 0.2)
				_dash_to_enemy(list[i], true)
				if Input.is_action_pressed("Dash") and energy >= 10:
					_add_clone(list[i], attack)
					clone_added = true
				yield(get_tree().create_timer(0.06675), "timeout")
		animationplayer.playback_speed = 1.0
		if clone_added:
			energy -= 10
		emit_signal("EnergyChanged", energy)
	if number == 3:
		_add_first_air_explosion()
		energy -= 20
		#emit_signal("test", 0.8)
		yield(get_tree().create_timer(0.2), "timeout")
		_add_airexplosions()
		if Input.is_action_pressed("Dash")  and energy >= 10:
			energy -= 10
			for i in range(PlayerStats.assassin_clone_targets):
				_add_clone(enemy, "Attack1")
		emit_signal("EnergyChanged", energy)
		
	combo_list.clear()
		
#Signals

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack1" or "Attack2" or "Attack3":
		can_attack = true
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			_enter_run_state()
		else:
			_enter_idle_state()
	if anim_name == "SpinAttack":
		can_attack = true
		_enter_idle_state()
	if anim_name == "ComboSpinAttack":
		$SwordCutArea/SpinAttack.disabled = true
		can_attack = true
		_enter_idle_state()
	if anim_name == "comboewqe1":
		_enter_idle_state()
		can_attack = true
	if anim_name =="comboewqe2":
		_enter_idle_state()
		can_attack = true
	if anim_name == "comboewqe3":
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

func on_jump_sound_timer_timeout() -> void:
	can_jump_sound = true

func on_attack_sound_timer_timeout() -> void:
	can_attack_sound = true

func _on_HurtBox_area_entered(area):
	var amount = 5
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
			PlayerStats.skilltree_points += 1
			emit_signal("LvlUp", current_lvl, xp_needed)
		emit_signal("XPChanged", current_xp)
	if area.is_in_group("EnergyParticle"):
		energy += 5
		if energy > 50:
			energy = 50
		emit_signal("EnergyChanged", energy)



func _on_KinematicBody2D_hurt() -> void:
	pass

func _on_NormalAttackArea_area_entered(area):
	if area.is_in_group("EnemyHitbox"):
		hit_count += 1
		if not PlayerStats.enemies_hit_by_player.has(area.get_parent()):
			PlayerStats.enemies_hit_by_player.append(area.get_parent())
		$EnemyHitTimer.start(10)
		if not can_follow_enemy:
			can_follow_enemy = true
			$NewTimer.start(1)
		if hit_count >= 2:
			_spawn_energy(area.get_parent())
		
		
func _on_KinematicBody2D_side_of_player(which_side):
	enemy_side_of_you = which_side

#Timers
func _on_ImmuneTimer_timeout():
	pass
	#can_take_damage = true
	#_enter_idle_state()

func _on_FlashTimer_timeout():
	can_take_damage = true
	tween.stop(playersprite)


func _on_ComboTimer_timeout():
	combo_list.clear()

func _on_CoyoteTimer_timeout():
	can_jump = false

func _on_DashTimer_timeout():
	playersprite.material.set_shader_param("flash_modifier", 0.0)
	_enter_idle_state()
	velocity = direction * MAX_SPEED
	direction.y = 0
	#dashline.visible = false
	ghosttime = 0.0
	can_dash = true
	yield(get_tree().create_timer(0.1), "timeout")
	playersprite.modulate.r = 1
	playersprite.modulate.g = 1
	playersprite.modulate.b = 1

func _on_NewTimer_timeout():
	can_follow_enemy = false

func _on_KinematicBody2D_pos(position) -> void:
	pass # Replace with function body.


func _on_JustLandedTimer_timeout() -> void:
	can_add_ass_ghost = false


func _on_EnemyHitTimer_timeout() -> void:
	pass
	
func on_EnemyDead(body) -> void:
	if PlayerStats.enemies_hit_by_player.has(body):
		PlayerStats.enemies_hit_by_player.erase(body)
	
