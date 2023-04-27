class_name Player #Hhar inte använt det här dock. 
extends KinematicBody2D

"""
Förklaringar finns i PlayerAssassin. Assassin är egentligen divine warrior medan mage/bara player är necromancer. Jag bytte namn på dem i slutet
"""


enum {IDLE, CROUCH, RUN, AIR, DASH, STOP, ATTACK_GROUND, ATTACK_DASH, ATTACK_AIR, JUMP_ATTACK, PREPARE_ATTACK_AIR, HURT, ABILITY, DEAD}

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
var attack_pressed = 0
var previous_attack = 0

var enemy_side_of_you

var hit_amount = 0


signal HPChanged(hp)
signal XPChanged(current_xp)
signal LvlUp(current_lvl, xp_needed)

const JUMP_SOUNDS = [preload("res://Sounds/ImportedSounds/JumpSounds/004_jump.wav"), preload("res://Sounds/ImportedSounds/JumpSounds/003_jump.wav"), preload("res://Sounds/ImportedSounds/JumpSounds/001_jump.wav"), preload("res://Sounds/ImportedSounds/JumpSounds/007_jump.wav"), preload("res://Sounds/ImportedSounds/JumpSounds/002_jump.wav")]
const ATTACK_SOUNDS = [preload("res://Sounds/ImportedSounds/AttackSounds/001_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/002_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/003_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/004_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/005_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/006_swing.wav"), preload("res://Sounds/ImportedSounds/AttackSounds/007_swing.wav")]
const DEATH_SOUND = preload("res://Sounds/ImportedSounds/JumpSounds/001_we-lost.wav")
var footstep_sounds 

var ghost_scene = preload("res://Instance_Scenes/GhostDashMage.tscn")
var land_scene = preload("res://Instance_Scenes/LandDust.tscn")
var jump_scene = preload("res://Instance_Scenes/JumpDust.tscn")
var dust_scene = preload("res://Instance_Scenes/ParticlesDust.tscn")
var skeleton_enemy_scene = preload("res://Scenes/SkeletonWarrior.tscn")
var prepare_attack_particles_scene = preload("res://Scenes/PreparingAttackParticles.tscn")
var buff_scene = preload("res://Instance_Scenes/BuffEffect.tscn")
var shockwave_scene = preload("res://Instance_Scenes/Shockwave.tscn")
var dash_smoke_scene = preload("res://Instance_Scenes/DashSmoke.tscn")
var pet_scene = preload("res://Instance_Scenes/MageGolem.tscn")
var dead_skeletton_scene = preload("res://Instance_Scenes/DeadSkeletton.tscn")
var crouch_smoke_scene = preload("res://Instance_Scenes/CrouchSmoke.tscn")


var ghosttime := 0.0
var crouchtime := 0.0
var attacktime := 0.0

var player_glow_array = [0.79, 0, 0.73, 1.0]
var player_default_array = [1, 1, 1, 1]
var player_holy_array = [0.8, 0.4, 0.8, 1.0]

onready var playersprite = $PlayerSprite
onready var animatedsmears = $SmearSprites
onready var animationplayer = $AnimationPlayer
onready var coyotetimer = $CoyoteTimer
onready var dashtimer = $DashTimer
onready var holybufftimer = $HolyBuffTimer
onready var darkbufftimer = $DarkBuffTimer
onready var flashtimer = $FlashTimer
onready var dashparticles = $DashParticles
onready var tween = $Tween
onready var hurtbox = $HurtBox/CollisionShape2D
onready var area_ground_attack = $NormalAttackArea/AttackGround
onready var area_jump_attack = $NormalAttackArea/AttackJump
onready var area_air_attack = $NormalAttackArea/AirAttack
onready var area_spin_attack = $SwordCutArea/SpinAttack
onready var dashsound = $DashSound
onready var jumpsound = $JumpSound
onready var attacksound = $AttackSound
onready var stepsound = $FootStepSound
onready var thrusts = $Thrusts
onready var abilitysprites = $AbilitySprites
onready var lifesteal_pos1 = $LifeStealPos1
onready var lifesteal_pos2 = $LifeStealPos2
onready var acid2area = $Acid2Area
onready var acid2shape = $Acid2Area/Acid2
onready var acid5area = $Acid5Area
onready var acid5shape = $Acid5Area/Acid5
onready var cut = $CutSprite
onready var cutarea = $CutArea/CollisionShape2D
onready var hud = $HUD
onready var jumpbuffer = $JumpBuffer
onready var attackbuffer = $AttackBuffer

var basic_attack_dmg = PlayerStats.mage_basic_dmg
var dead_skeleton_dmg = PlayerStats.dead_skeleton_dmg
var dead_skeleton_exp_dmg = PlayerStats.dead_skeleton_exp_dmg
var golem_dmg = PlayerStats.golem_dmg
var can_add_ls = PlayerStats.can_add_ls
var can_add_dark = PlayerStats.can_add_dark
var can_add_holy = PlayerStats.can_add_holy
var can_thrust = PlayerStats.can_thrust
var can_add_golem = PlayerStats.can_add_golem
var golem_life_time = PlayerStats.golem_life_time
var ability1_learned = PlayerStats.ability1_learned
var ability2_learned = PlayerStats.ability2_learned
var golem_active = PlayerStats.golem_active
var spin_attack_dmg := 7
var cut_dmg := 50
var damage_ability1 := 10
var damage_ability2 := 25
var holy_buff_active := false
var dark_buff_active := false
var test_active := false
var tester := Vector2.ZERO

var can_attack_sound = true
var can_footstep_sound = true


var dash_to_enemy_distance = 50

var hit_the_ground = false
var motion_previous = Vector2()
var last_step = 0
var side = "RIGHT"
var xp_needed = 40
var has_leveled_up = false
var testpos = Vector2.ZERO
var testpos2 = Vector2.ZERO

var smearsprite_q = "Smear2H"
var smearsprite_w = "Smear1V"
var smearsprite_e = "Smear3H"

#Player stats
var hp = PlayerStats.hp
var max_hp = 100
var hp_regeneration = 1
var current_xp = 0
var current_lvl = 1
var ability_anim



func _ready() -> void:
	PlayerStats.connect("AttackDamageChanged", self, "_on_attack_damage_changed") 
	PlayerStats.connect("EnemyDead", self, "on_EnemyDead")
	Quests.connect("xp_changed", self, "_on_xp_changed")
	_enter_idle_state()
	playersprite.visible = true
	animationplayer.playback_speed = 1
	footstep_sounds = PlayerStats.footsteps_sound
	hud.visible = true
	cut.visible = false
	thrusts.visible = false
	abilitysprites.visible = false
	cut.visible = false


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
		ATTACK_DASH:
			_attack_state_dash(0, delta)
		PREPARE_ATTACK_AIR:
			_prepare_attack_air_state(delta)
		ATTACK_AIR:
			_attack_state_air(delta)
		JUMP_ATTACK:
			_jump_attack_state(delta)
		HURT:
			_hurt_state(delta)
		ABILITY:
			_ability_state(delta)
		DEAD:
			_dead_state(delta)

#Help functions
func set_active(active):
	set_physics_process(active)
	set_process(active)
	set_process_input(active)

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
	for i in range(1, len(all_enemy)):
		if abs(all_enemy[i].global_position.x) > abs(furthest_away_enemy.global_position.x):
			furthest_away_enemy = all_enemy[i]

	return furthest_away_enemy

func _attack_function():
	if Input.is_action_just_pressed("EAttack1") or (attack_pressed == 1):
		if can_attack:
			_enter_attack1_state(1)
			attack_pressed = 0
			previous_attack = 1
		else:
			attack_pressed = 1
			_remember_attack()
	if Input.is_action_just_pressed("Attack2") or (attack_pressed == 2):
		if can_attack:
			_enter_attack1_state(2)
			attack_pressed = 0
			previous_attack = 2
		else:
			attack_pressed = 2
			_remember_attack()
	if Input.is_action_just_pressed("Attack3") or (attack_pressed == 3):
		if can_attack:
			_enter_attack1_state(3)
			attack_pressed = 0
			previous_attack = 3
		else:
			attack_pressed = 3
			_remember_attack()

func _set_player_mod(array: Array):
	playersprite.modulate.r = array[0]
	playersprite.modulate.g = array[1]
	playersprite.modulate.b = array[2]
	playersprite.modulate.a = array[3]

func _get_random_sound(type: String) -> void:
	rng.randomize()
	if type == "Jump":
		var number = rng.randi_range(0, JUMP_SOUNDS.size()-1)
		jumpsound.stream = JUMP_SOUNDS[number]
	#	jump_sound_timer.start(1.0)
	if type == "Attack":
		var number = rng.randi_range(0, ATTACK_SOUNDS.size()-1)
		attacksound.stream = ATTACK_SOUNDS[number]
	jumpsound.pitch_scale = BackgroundMusic.voice_pitch_scale
	attacksound.pitch_scale = BackgroundMusic.voice_pitch_scale

func _check_sprites() -> void:
	area_air_attack.set_deferred("disabled", true)
	area_ground_attack.set_deferred("disabled", true)
	area_jump_attack.set_deferred("disabled", true)
	area_spin_attack.set_deferred("disabled", true)
	acid2shape.set_deferred("disabled", true)
	acid5shape.set_deferred("disabled", true)
	thrusts.visible = false
	abilitysprites.visible = false
	animatedsmears.visible = false
	can_attack = true
	if not holy_buff_active:
		_set_player_mod(player_default_array)





"""
_input kollar om spelaren klickar en knapp. Jag har dessa i input, eftersom spelaren ska kunna göra detta oberoende på vilket state den befinner sig i

"""
func _input(event):
	if event.is_action_pressed("ui_accept"):
		PlayerStats.hp = hp
	
	if event.is_action_pressed("HolyBuff1") and not holy_buff_active and can_add_holy:
		_add_buff("holy")

	if event.is_action_pressed("DarkBuff") and not dark_buff_active and can_add_dark:
		_add_buff("dark2")
		dark_buff_active = true
		darkbufftimer.start(7.2)
	
	if event.is_action_pressed("add_pet") and can_add_golem:
		_add_pet()
	
func _flip_sprite(right: bool) -> void:
	var variable
	if right:
		variable = 1
		playersprite.flip_h = false
		animatedsmears.flip_h = false
	else:
		variable = -1
		playersprite.flip_h = true
		animatedsmears.flip_h = true
	animatedsmears.position.x = 20 * variable
	area_ground_attack.position.x = 36 * variable
	area_spin_attack.position.x = 34 * variable

func _add_pet(): #Lägger till golem. 
	if not PlayerStats.golem_active:
		var pet = pet_scene.instance()
		pet.global_position = global_position 
		get_tree().get_root().add_child(pet)
		hp -= 10
		emit_signal("HPChanged", hp)

func _add_crouch_ghost() -> void:
	var dir 
	if direction_x == "RIGHT":
		dir = 1
	else:
		dir = -1
	var smoke = crouch_smoke_scene.instance()
	smoke.global_position = global_position + Vector2(22*dir, 25)
	smoke.flip_h = playersprite.flip_h
	get_tree().get_root().add_child(smoke)

func _add_dead_skeletton(this_enemy): #Lägger till dödskeleton när en fiende dör
	var body = dead_skeletton_scene.instance()
	body.global_position = this_enemy.global_position
	get_tree().get_root().add_child(body)

func _add_shockwave():
	var wave = shockwave_scene.instance()
	add_child(wave)

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
	if name == "Air":
		smoke.animation = "New Anim"
		smoke.global_position = global_position + Vector2(-30* direction.x, 0)
		smoke.flip_h = flip
	get_tree().get_root().add_child(smoke)

func _add_dash_ghost() -> void:
	var ghost = ghost_scene.instance()
	ghost.global_position = global_position + Vector2(0, -2)
	ghost.flip_h = playersprite.flip_h
	get_tree().get_root().add_child(ghost)

func _add_walk_dust(amount: int) -> void:
	var dust = dust_scene.instance()
	dust.amount = amount
	dust.global_position = playersprite.global_position + Vector2(0,23)
	dust.emitting = true
	get_tree().get_root().add_child(dust)

func _add_land_dust()-> void:
	var dust = land_scene.instance()
	dust.global_position = playersprite.global_position + Vector2(0, 22) # 15
	get_tree().get_root().add_child(dust)

func _add_jump_dust() -> void:
	var dust = jump_scene.instance()
	dust.global_position = playersprite.global_position + Vector2(0, 15)
	get_tree().get_root().add_child(dust)


func _add_buff(buff_name: String) -> void: #Här finns fler buffs än i playerassassin. 
	var buff = buff_scene.instance()
	var effect1 = buff.get_child(0)
	buff.global_position = playersprite.global_position 
	if buff_name == "lvl_up":
		effect1.animation = "lvl_up"
	if buff_name == "holy":
		effect1.animation = "holy"
		_set_player_mod(player_holy_array)
		holybufftimer.start(5)
		holy_buff_active = true
		can_take_damage = false
		WorldEnv.emit_signal("Darken", "holy_mage") #WorldEnviroment ändrar på tonemap exposure, vilket leder till en mörkare värld i några sekunder
	if buff_name == "dark2":
		effect1.animation = "dark2"
	if buff_name == "lifesteal_particles":
		effect1.animation = "lifesteal_particles"
		_add_hp(2)
		emit_signal("HPChanged", hp)
	add_child(buff)

func _add_hp(amount: int) -> void: #Lägger till nytt hp. Necromancer har lifesteal
	hp += amount
	if hp > max_hp:
		hp = max_hp
	emit_signal("HPChanged", hp)

func take_damage(amount: int, direction: int) -> void:
	_enter_hurt_state()
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
	can_take_damage = false
	hp -= amount
	emit_signal("HPChanged", hp)
	_die(hp)
	yield(get_tree().create_timer(0.3), "timeout")
	flashtimer.start(2)
	_alpha_tween()
	_enter_idle_state()

func _get_smearsprite(button: String):
	if button == "q":
		animatedsmears.animation = smearsprite_q
	if button == "w":
		animatedsmears.animation = smearsprite_w
	if button == "e":
		animatedsmears.animation = smearsprite_e

func _die(hp):
	if hp <= 0:
		can_add_dark = false
		can_add_golem = false
		can_add_holy = false
		dashsound.stop()
		dashsound.stream = DEATH_SOUND
		dashsound.pitch_scale = 1.0
		dashsound.volume_db = 30
		dashsound.play()
		state = DEAD
		hurtbox.set_deferred("disabled", true)
		set_physics_process(false)
		playersprite.play("Death")
		var instance = load("res://Instance_Scenes/DeadScreen.tscn")
		var child = instance.instance()
		add_child(child)
		set_process_input(false)

func frameFreeze(timescale, duration): #Spelet går i timescale hastighet. 
	Engine.time_scale = timescale
	yield(get_tree().create_timer(duration * timescale), "timeout")
	Engine.time_scale = 1

func flash():
	playersprite.material.set_shader_param("flash_modifier", 0.8)
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

func _remember_jump() -> void:
	jumpbuffer.start(0.15)
	
func _remember_attack() -> void:
	attackbuffer.start(0.2)

func _level_up():
	if PlayerStats.current_xp >= PlayerStats.xp_needed:
		PlayerStats.current_xp = PlayerStats.current_xp - PlayerStats.xp_needed
		PlayerStats.xp_needed = PlayerStats.xp_needed + pow(1.5, (PlayerStats.current_lvl*2))
		PlayerStats.skilltree_points += 1
		PlayerStats.current_lvl += 1
		has_leveled_up = true
		_add_buff("lvl_up")
		return true
	else:
		return false

func _set_sprite_position(anim_name): #Anropas i animationplayer. Ser till att spritesen är på rätt position, beronede på vilken sprite som ska användas
	abilitysprites.flip_h = playersprite.flip_h
	var dir
	if direction_x == "RIGHT":
		dir = 1
	else:
		dir = -1
	if anim_name == "Thrust":
		cut.position = Vector2(-38*dir, -45)
		cutarea.position = Vector2(-53*dir, -65)
		cut.rotation_degrees = 45*dir
		cutarea.rotation_degrees = cut.rotation_degrees
	if anim_name == "Ability1":
		abilitysprites.position = Vector2(51*dir, 9)
		acid2shape.position.x = 52*dir
	if anim_name == "Ability2":
		abilitysprites.position = Vector2(80*dir, 0)
		acid5area.position.x = 82*dir
	if anim_name == "OnGroundAfterAttack":
		thrusts.position.x = 0
		thrusts.position.y = 1

func _add_preparing_attack_particles(amount) -> void: #Lägger till partiklar när spelaren laddar upp. Inspriation från DragonBall
	for n in range (amount):
		rng.randomize()
		var nrx = rng.randi_range(-200, 200)
		var nry = rng.randi_range(-200, 200)
		var particles = prepare_attack_particles_scene.instance()
		particles.global_position = playersprite.global_position + Vector2(nrx, nry)
		get_tree().get_root().add_child(particles)
	
#STATES:
func _idle_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	
	if (Input.is_action_just_pressed("Jump") and can_jump) or jump_pressed == true:
		_add_jump_dust()
		_enter_air_state(true)
		return


	if Input.is_action_just_pressed("Ability1") and PlayerStats.ability1_learned:
		_enter_ability_state(1)
	
	if Input.is_action_just_pressed("Ability2") and PlayerStats.ability2_learned:
		_enter_ability_state(2)
	
	if Input.is_action_just_pressed("Crouch"):
		_enter_crouch_state()
	
	
	_attack_function()
	_apply_basic_movement(delta)
	
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
			_enter_air_state(false)
	
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

	if playersprite.frame == 1:
		last_step += 1
		if last_step == 4:
			_add_walk_dust(3)
			last_step = 0
				
	if (Input.is_action_just_pressed("Jump") and can_jump) or jump_pressed == true:
		_add_jump_dust()
		_enter_air_state(true)
		return
	
	if Input.is_action_just_pressed("Crouch"):
		_enter_crouch_state()
	
	if Input.is_action_just_pressed("Dash") and can_dash:
		_add_dash_smoke("ImpactDustKick")
		_enter_dash_state()
		return
		
	if Input.is_action_just_pressed("EAttack1"):
		_enter_dash_attack_state(1)
	if Input.is_action_just_pressed("AttackE"):
		pass
	
	if Input.is_action_just_pressed("Ability1") and PlayerStats.ability1_learned:
		_enter_ability_state(1)
	
	if Input.is_action_just_pressed("Ability2") and PlayerStats.ability2_learned:
		_enter_ability_state(2)
	
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
		_add_dash_smoke("Air")
		_enter_dash_state()
		return
	
	if Input.is_action_pressed("EAttack1"):
		_enter_attack_air_state(true)
		return
	if Input.is_action_pressed("AttackE") and can_thrust:
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

	_air_movement(delta)
	var current_animation = playersprite.get_animation()
	if velocity.y > 0  and not ( current_animation == "FallN" ) and ( velocity.x == 0 ):
		playersprite.play("FallN")
	elif velocity.y > 0 and not ( current_animation == "FallF" ) and ( velocity.x != 0 ):
		playersprite.play("FallF")
	if is_on_floor(): 
		_add_land_dust()
		_enter_idle_state()
		return

func _dash_state(delta):
	velocity = velocity.move_toward(direction*MAX_SPEED*3, ACCELERATION*delta*3)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	ghosttime += delta
	
	if ghosttime >= 0.09:
		_add_dash_ghost()
		ghosttime = 0.06
	
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
	_attack_function()
	
func _attack_state_dash(attack_nr : int, delta) -> void:
	velocity = velocity.move_toward(direction*MAX_SPEED*1, ACCELERATION*delta*1)
	
	velocity = move_and_slide(velocity, Vector2.UP)

func _prepare_attack_air_state(delta) -> void:
	playersprite.scale.y = lerp(playersprite.scale.y, 1, 1 - pow(0.01, delta))
	playersprite.scale.x = lerp(playersprite.scale.x, 1, 1 - pow(0.01, delta))

func _attack_state_air(delta) -> void:
	hurtbox.disabled = true
	if direction_x != "RIGHT":
		animatedsmears.rotation_degrees = -45
		area_air_attack.rotation_degrees = -45
		velocity.x = -MAX_SPEED*10
	else: 
		animatedsmears.rotation_degrees = 45
		area_air_attack.rotation_degrees = 45
		velocity.x = MAX_SPEED*10
	animationplayer.play("Thrust2")
	area_air_attack.disabled = false
	velocity.y = GRAVITY*2
	
	if is_on_floor():
		velocity.x = 0
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
func _jump_attack_state(delta) -> void:
	_air_movement(delta)
	if is_on_floor():
		_enter_idle_state()

func _hurt_state(delta) -> void:
	_air_movement(delta)

func _ability_state(_delta) -> void: # Har de här statsen bara så att input inte kommer in eller så att spelaren rör på sig
	pass

func _dead_state(_delta) -> void:
	pass

#Enter states
func _enter_idle_state() -> void:
	_check_sprites()
	state = IDLE
	playersprite.play("Idle")
	can_jump = true

func _enter_crouch_state() -> void:
	state = CROUCH
	if velocity.x >= 1 or velocity.x <= -1:
		if direction_x == "RIGHT":
			_flip_sprite(false)
		else:
			_flip_sprite(true)
	playersprite.play("Crouch")

func _enter_dash_state() -> void:
	dashsound.play()

	direction = Input.get_vector("move_left", "move_right","ui_up", "ui_down")
	if state == IDLE and direction == Vector2.DOWN:
		return
	elif direction == Vector2.ZERO:
		direction.x = 1 if direction_x == "RIGHT" else -1
	_set_player_mod(player_glow_array)
	playersprite.play("Dash")
	state = DASH
	dashparticles.emitting = true
	can_dash = false
	dashtimer.start(0.25)

func _enter_air_state(jump: bool) -> void:
	if jump:
		velocity.y = JUMP_STRENGHT
		if velocity.x == 0:
			playersprite.play("JumpN")
		else:
			playersprite.play("JumpF")
		jumpsound.play()
	coyotetimer.start()
	state = AIR

func _enter_run_state() -> void:
	_check_sprites()
	can_jump = true
	state = RUN
	playersprite.play("Run")

func _enter_stop_state() -> void:
	can_jump = true
	state = STOP
	playersprite.play("Stop")

func _enter_hurt_state() -> void:
	_check_sprites()
	playersprite.visible = true
	state = HURT
	yield(get_tree().create_timer(0.5),"timeout")
	_enter_air_state(false)

func _enter_attack1_state(attack: int) -> void:
	state = ATTACK_GROUND
	playersprite.visible = true
	is_attacking = true
	animatedsmears.position.y = 5
	animationplayer.play("Attack" + str(attack))
	if can_attack_sound:
		_get_random_sound("Attack")
		attacksound.play()
		can_attack_sound = false
	can_attack = false
	previous_attack = attack


func _enter_dash_attack_state(attack: int) -> void:
	state = ATTACK_DASH
	if attack == 1:
		animationplayer.play("SpinAttack")
		can_attack = false

func _enter_ability_state(number: int) -> void: #Liknar _enter_attack1_state. Ger vilken animation animationspelaren ska spela
	state = ABILITY
	playersprite.visible = true
	if number == 1:
		hp -= 5
		animationplayer.play("Ability1")
	if number == 2:
		hp -= 10
		animationplayer.play("Ability2")
	emit_signal("HPChanged", hp)

func _enter_attack_air_state(Jump: bool) -> void:	
	if Jump:
		if direction_x != "RIGHT":
			area_jump_attack.position.x = -20
		elif direction_x == "RIGHT":
			area_jump_attack.position.x = 20
		state = JUMP_ATTACK
		animationplayer.play("JumpAttack")
		area_jump_attack.disabled = false
	else: 
		animationplayer.play("PrepareAirAttack")
		WorldEnv.emit_signal("Darken", "PrepareNecroMancer")
		state = PREPARE_ATTACK_AIR
		_add_preparing_attack_particles(10)
		_add_shockwave()
		#frameFreeze(0.2, 0.5)

#Signals

func _on_attack_damage_changed(type: String): #En signal från skilltree. Detta gör att spelaren slipper kollar detta varje gång den ska göra något. 
	if type == "ability1_learned":
		ability1_learned = true
	if type == "ability2_learned":
		ability2_learned = true
	if type == "can_add_ls":
		can_add_ls = true
	if type == "dead_skeleton":
		dead_skeleton_dmg = PlayerStats.dead_skeleton_dmg
		dead_skeleton_exp_dmg = PlayerStats.dead_skeleton_exp_dmg
	if type == "can_add_golem":
		can_add_golem = PlayerStats.can_add_golem
	if type == "golem":
		golem_dmg = PlayerStats.golem_dmg
		golem_life_time = PlayerStats.golem_life_time
	if type == "dark":
		can_add_dark = true
	if type == "holy":
		can_add_holy = true
	if type == "thrust":
		can_thrust = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack1" or "Attack2" or "Attack3" or "SpinAttack" or "Ability1" or "Ability2":
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			_enter_run_state()
		else:
			_enter_idle_state()
		can_attack = true
	if anim_name == "JumpAttack":
		area_jump_attack.disabled = true
		_enter_idle_state()
		can_attack = true
	if anim_name == "PrepareAirAttack":
		_get_random_sound("Attack")
		attacksound.pitch_scale = 0.8
		attacksound.play()
		state = ATTACK_AIR
	if anim_name == "Thrust2":
		hurtbox.disabled = false
		area_air_attack.disabled = true
		animatedsmears.rotation_degrees = 0
		if is_on_floor():
			velocity.x = 0
			animationplayer.play("OnGroundAfterAttack")
			_enter_idle_state()
			can_jump = false
			return
	if anim_name == "OnGroundAfterAttack":
		can_jump = true

func _on_HurtBox_area_entered(area):
	var amount
	if can_take_damage:
		if area.is_in_group("EnemySword"):
			amount = area.get_parent().damage_dealt
			if dark_buff_active:
				amount *= 2
			take_damage(amount, direction.x)
			if not PlayerStats.enemies_for_golem.has(area.get_parent()): 
				PlayerStats.enemies_for_golem.append(area.get_parent())
			if not PlayerStats.enemy_who_hurt_list.has(area.get_parent()):
				PlayerStats.enemy_who_hurt_list.append(area.get_parent())
			PlayerStats.emit_signal("PlayerHurt")
		#	if area.is_in_group("Enemy"):
	#		take_damage(amount, direction.x)
	
func _on_CollectParticlesArea_area_entered(area) -> void:
	if area.is_in_group("XP-Particle"):
		PlayerStats.current_xp += 5
		if _level_up():
			emit_signal("LvlUp", PlayerStats.current_lvl, PlayerStats.xp_needed)
			WorldEnv.emit_signal("Darken", "lvl_up")
			PlayerStats.skilltree_points += 1
		_change_xp()
		emit_signal("XPChanged", current_xp)

func _change_xp() -> void:
	emit_signal("XPChanged", PlayerStats.current_xp)

func _on_xp_changed() -> void:
	_change_xp()

func on_EnemyDead(body):
	_add_dead_skeletton(body)
	

func _on_NormalAttackArea_area_entered(area):
	if area.is_in_group("EnemyHitbox"):
		if not PlayerStats.enemies_for_golem.has(area.get_parent()):
			PlayerStats.enemies_for_golem.append(area.get_parent())
		PlayerStats.emit_signal("EnemyHurt")
		if can_add_ls:
			_add_buff("lifesteal_particles")

func _on_Acid2Area_area_entered(area):
	if area.is_in_group("EnemyHitbox"):
		if not PlayerStats.enemies_for_golem.has(area.get_parent()):
			PlayerStats.enemies_for_golem.append(area.get_parent())
		PlayerStats.emit_signal("EnemyHurt")
		if can_add_ls:
			_add_buff("lifesteal_particles")

func _on_Acid5Area_area_entered(area):
	if area.is_in_group("EnemyHitbox"):
		if not PlayerStats.enemies_for_golem.has(area.get_parent()):
			PlayerStats.enemies_for_golem.append(area.get_parent())
		PlayerStats.emit_signal("EnemyHurt")
		if can_add_ls:
			_add_buff("lifesteal_particles")

func _on_SwordCutArea_area_entered(area):
	if area.is_in_group("EnemyHitbox"):
		if not PlayerStats.enemies_for_golem.has(area.get_parent()):
			PlayerStats.enemies_for_golem.append(area.get_parent())
		PlayerStats.emit_signal("EnemyHurt")
		if can_add_ls:
			_add_buff("lifesteal_particles")



func _on_KinematicBody2D_side_of_player(which_side):
	enemy_side_of_you = which_side

#Timers

func _on_FlashTimer_timeout():
	if not holy_buff_active:
		can_take_damage = true
	tween.stop(playersprite)


func _on_CoyoteTimer_timeout():
	can_jump = false

func _on_DashTimer_timeout():
	if not holy_buff_active:
		_set_player_mod(player_default_array)
	_enter_idle_state()
	velocity = direction * MAX_SPEED
	direction.y = 0
	dashparticles.emitting = false
	#dashline.visible = false
	ghosttime = 0.0
	can_dash = true


func _on_HolyBuffTimer_timeout(): #Återställer spelarens modulate samt att den kan ta damage. 
	_set_player_mod(player_default_array)
	can_take_damage = true
	holy_buff_active = false

func _on_DarkBuffTimer_timeout():
	dark_buff_active = false

func _on_DropDetect_body_exited(body):
	set_collision_mask_bit(11, true)


func _on_AttackSound_finished():
	can_attack_sound = true


func _on_FootStepTimer_timeout():
	can_footstep_sound = true

func _on_JumpBuffer_timeout():
	jump_pressed = false

func _on_AttackBuffer_timeout():
	attack_pressed = 0
