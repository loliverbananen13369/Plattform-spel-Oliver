extends KinematicBody2D


"""
Jag kör typ samma kod i den här som andra player
"""

enum {IDLE, DEAD, CROUCH, RUN, AIR, DASH_AIR, DASH_GROUND, STOP, ATTACK_GROUND, ATTACK_DASH, ATTACK_AIR, JUMP_ATTACK, PREPARE_ATTACK_AIR, HURT, COMBO, INVISIBLE}


const MAX_SPEED = 250
const ACCELERATION = 1000
const GRAVITY = 1000
const JUMP_STRENGHT = -500



export(String)var direction_x = "RIGHT"

var velocity := Vector2.ZERO
var direction := Vector2.ZERO
var hurt_direction := Vector2.ZERO

var state = IDLE

var rng = RandomNumberGenerator.new()

var can_jump := true
var can_dash := true
var can_attack := true
var can_footstep_sound = true
var can_jump_sound := true
var can_attack_sound := true
var can_take_damage := true
var jump_attack := false
var is_attacking := false
var is_air_attacking := false
var jump_pressed := false
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
const DEATH_SOUND = preload("res://Sounds/ImportedSounds/JumpSounds/001_we-lost.wav")
var footstep_sounds 


var ghost_scene = preload("res://Instance_Scenes/GhostDashAssassin.tscn")
var new_ghost_scene = preload("res://Instance_Scenes/AssassinGhost.tscn")
var dash_smoke_scene = preload("res://Instance_Scenes/DashSmokeAssassin.tscn")
var land_scene = preload("res://Instance_Scenes/LandDust.tscn")
var jump_scene = preload("res://Instance_Scenes/JumpDust.tscn")
var dust_scene = preload("res://Instance_Scenes/ParticlesDustAssassin.tscn")
var buff_scene = preload("res://Instance_Scenes/BuffEffect.tscn")
var air_explosion_scene = preload("res://Instance_Scenes/AirExplosion.tscn")
var shockwave_scene = preload("res://Instance_Scenes/Shockwave.tscn")
var clone_scene = preload("res://Instance_Scenes/AssassinClone.tscn")
var dash_attack_scene = preload("res://Instance_Scenes/AssassinDashAttack.tscn")
var impact_scene = preload("res://Instance_Scenes/Impact_Scene.tscn")
var energy_scene = preload("res://Instance_Scenes/AssassinEnergyParticle.tscn")
var crouch_smoke_scene = preload("res://Instance_Scenes/CrouchSmoke.tscn")

var ghosttime := 0.0
var crouchtime := 0.0
var attacktime := 0.0

onready var playersprite = $PlayerSprite
onready var animatedsmears = $SmearSprites
onready var animationplayer = $AnimationPlayer
onready var tween = $Tween
onready var dashparticles = $DashParticles2
onready var area_ground_attack = $NormalAttackArea/AttackGround
onready var area_jump_attack = $NormalAttackArea/AttackJump
onready var area_air_attack = $NormalAttackArea/AirAttack
onready var area_spin_attack = $SwordCutArea/SpinAttack
onready var cut_area = $CutArea/AirAttack2
onready var dashsound = $DashSound
onready var jumpsound = $JumpSound
onready var attacksound = $AttackSound
onready var stepsound = $FootStepSound
onready var thrusts = $Thrusts
onready var hurtbox = $HurtBox/CollisionShape2D
onready var coyotetimer = $CoyoteTimer
onready var dashtimer = $DashTimer
onready var footsteptimer = $FootStepTimer
onready var flashtimer = $FlashTimer
onready var combotimer = $ComboTimer
onready var justdashedtimer = $JustDashedTimer
onready var dashghosttimer = $DashGhostTimer
onready var hud = $HUD
onready var jumpbuffer = $JumpBuffer
onready var attackbuffer = $AttackBuffer
onready var airexplosiontimer = $AirExplosionTimer


var basic_attack_dmg = PlayerStats.assassin_basic_dmg
var dash_attack_dmg = PlayerStats.assassin_dash_attack_dmg
var spin_attack_dmg := 15
var cut_dmg := 15
export (Vector2) var tester := Vector2.ZERO



var dash_to_enemy_distance = 50
var player_glow_array = [4.55, 4.2, 3.5, 1]
var player_default_array = [1, 1, 1, 1]

var hit_the_ground = false
var motion_previous = Vector2()
var last_step = 0
var side = "RIGHT"
var xp_needed = 40
var has_leveled_up = false
var testpos = Vector2.ZERO
var testpos2 = Vector2.ZERO
var test_var_enemy 

var player_name

#Player stats
var hp = PlayerStats.hp
var life_steal = PlayerStats.life_steal
var energy = 50
var max_energy = 50
var current_xp = 0
var current_lvl = 1
var previous_state = IDLE

var dark_buff_active := false
var holy_buff_active := false



func _ready() -> void: #Främst debug
	
	playersprite.play("Idle")
	PlayerStats.connect("AttackDamageChanged", self, "_on_attack_damage_changed")
	PlayerStats.connect("EnemyDead", self, "on_EnemyDead")
	Quests.connect("xp_changed", self, "_on_xp_changed")
	hud.visible = true
	playersprite.visible = true
	animatedsmears.visible = false
	thrusts.visible = false
	animationplayer.playback_speed = 1
	footstep_sounds = PlayerStats.footsteps_sound
	

func _physics_process(delta: float) -> void: 
	match state:
		IDLE:
			_idle_state(delta)
		DEAD:
			_dead_state(delta)
		CROUCH:
			_crouch_state(delta)
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

#Help functions

func set_active(active): #Om jag vill avaktivera spelaren, används vid dialoger
	set_physics_process(active)
	set_process_input(active)
	

func check_sprites(): #Debug
	cut_area.disabled = true
	area_air_attack.disabled = true
	area_ground_attack.disabled = true
	area_jump_attack.disabled = true
	area_spin_attack.disabled = true
	thrusts.visible = false
	animatedsmears.visible = false
	can_attack = true
	_set_player_mod(player_default_array)
	

func _get_random_sound(type: String) -> void: #Slumpar vilket ljud jag får, så det inte blir alldeles för ensidigt
	rng.randomize()
	if type == "Jump":
		var number = rng.randi_range(0, JUMP_SOUNDS.size()-1)
		jumpsound.stream = JUMP_SOUNDS[number]
	if type == "Attack":
		var number = rng.randi_range(0, ATTACK_SOUNDS.size()-1)
		attacksound.stream = ATTACK_SOUNDS[number]
	jumpsound.pitch_scale = BackgroundMusic.voice_pitch_scale
	attacksound.pitch_scale = BackgroundMusic.voice_pitch_scale
	
	
	


func _apply_hurt_movement(delta) -> void: #Movement som appliceras varje "delta" när min spelare skadas
	velocity = velocity.move_toward(hurt_direction*0.1*MAX_SPEED, ACCELERATION*delta)
	velocity.y = velocity.y + GRAVITY * delta if velocity.y + GRAVITY * delta < 300 else 300
	velocity = move_and_slide(velocity, Vector2.UP)
	


func _apply_basic_movement(delta) -> void: #Movement som appliceras när spelaren rör på sig eller står i idle
	if direction.x != 0:
		velocity = velocity.move_toward(direction*MAX_SPEED, ACCELERATION*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION*delta)
	velocity.y += GRAVITY*delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if not hit_the_ground and is_on_floor(): #Att lerpa spelarspritens skala känns lite onödigt och är något jag gjorde i början när jag kollade på "How to make your movement more celeste-like", men känns RIP att ta bort när jag väl suttit där flera timmar och hållit på med olika värden. Det som händer iallafall är att spelarens x/y-skala ändras lite så det blir mer smooth air movement
		hit_the_ground = true
		playersprite.scale.y = range_lerp(abs(motion_previous.y), 0, abs(200), 0.9, 0.8)
		playersprite.scale.x = range_lerp(abs(motion_previous.x), 0, abs(200), 0.9, 0.9)
		#ger motion_previous.x/y ett värde från (mellan 0, abs(200)) till (0.9, 0.8 )
	playersprite.scale.y = lerp(playersprite.scale.y, 1, 1 - pow(0.01, delta)) #( 0.01 ^ delta)
	playersprite.scale.x = lerp(playersprite.scale.x, 1, 1 - pow(0.01, delta))
	#ger: playersprite.scale.x/y * 1 * 1-0.01^delta, varje delta
	
	
func _get_input_x_update_direction() -> float: 
	var input_x = Input.get_axis("move_left", "move_right")
	if input_x > 0:
		direction_x = "RIGHT"
		_flip_sprite(true)
	elif input_x < 0:
		direction_x = "LEFT"
		_flip_sprite(false)
	
	return input_x

func _get_input_x_crouch_direction() -> float: #Samma som _get_input_x_update_directio() fast man får tvärtom
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
		playersprite.scale.y = range_lerp(abs(velocity.y), 0, abs(JUMP_STRENGHT), 0.9, 0.8)  #Ändrar spelarens y skala när den är i luften för att få mer liv. Taget från youtube i början när jag jobbade på movement och jump strength
		playersprite.scale.x = range_lerp(abs(velocity.x), 0, abs(JUMP_STRENGHT), 0.9, 0.7)


func _get_closest_enemy(enemy_group):
	#Loopar igenom enemy_group, och ger tillbaka vilken fiende i gruppen som är närmast spelaren
	if len(enemy_group) > 0:
		var closest_enemy = enemy_group[0]
		for i in range(0, len(enemy_group)-1):
			if is_instance_valid(enemy_group[i]):
				if global_position.distance_to(enemy_group[i].global_position) < global_position.distance_to((closest_enemy.global_position + Vector2(5, 0))):
					closest_enemy = enemy_group[i]
			else:
				return closest_enemy

		return closest_enemy
	
	
func _attack_function():
	#Funktion för att kolla vilken attack som blev tryckt, attackerar om den kan attackera men sparar attacken om den inte kan attackera ( attackbuffert )
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
	
	
func _flip_sprite(right: bool) -> void:
	#Funktion som ger rätt värden beronede på vilket håll spelaren är riktad mot
	var variable
	if right:
		variable = 1
		playersprite.flip_h = false
		animatedsmears.flip_h = false
	else:
		variable = -1
		playersprite.flip_h = true
		animatedsmears.flip_h = true
	animatedsmears.position.x = 20*variable
	area_ground_attack.position.x = 36 * variable
	area_jump_attack.position.x = 20 * variable
	area_spin_attack.position.x = 34 * variable


#Instansierar andra scener till Player
#De flesta är väldigt simpla, där jag ger "scenerna" en position
#De mer komplicerade kommenterar jag på enskilt

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
	dust.global_position = playersprite.global_position + Vector2(0, 22)
	get_tree().get_root().add_child(dust)

func _add_jump_dust() -> void:
	var dust = jump_scene.instance()
	dust.global_position = playersprite.global_position + Vector2(0, 15)
	get_tree().get_root().add_child(dust)


func _add_buff(buff_name: String) -> void:
	var buff = buff_scene.instance()
	var effect1 = buff.get_child(0)
	buff.global_position = playersprite.global_position 
	if buff_name == "lvl_up":
		effect1.animation = "lvl_up"
	get_tree().get_root().add_child(buff)
	

func _add_first_air_explosion() -> void:
	var all_enemy = get_tree().get_nodes_in_group("Enemy") #En lista på alla fiender som är med i spelet
	state = COMBO #Egentligen bara så att den inte applicerar någon egen movement
	playersprite.visible = false 
	hurtbox.disabled = true #För svag om spelaren kan ta dmg
	var explosion = air_explosion_scene.instance()
	var closest_enemy #Gör att resten av koden kan köras även om det inte finns en närmsta fiende
	if all_enemy.size() > 0:
		closest_enemy = _get_closest_enemy(all_enemy)
	explosion.global_position = global_position + Vector2(5, -15) 
	if is_instance_valid(closest_enemy): #Måste se till att fienden har laddats klart / om den inte har hunnit tagits bort helt
		get_tree().get_root().add_child(explosion)
		if global_position.distance_to(closest_enemy.global_position) < 60:
			tween.interpolate_property(explosion, "position", explosion.global_position, closest_enemy.global_position + Vector2(5, -15), 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.start() #tvenar en slät animation från spelarens nuvarande position till fiendens position
			testpos = closest_enemy.global_position + Vector2(5, -15) #Ger ett nytt värde till explosionens startposition
			testpos2 = closest_enemy.global_position + Vector2(0, - 30) #
			global_position = testpos2
	
func _add_airexplosions() -> void:
	state = COMBO #Allt ba samma typ
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
				if testpos.distance_to(closest_enemy.global_position) < 300:
					tween.interpolate_property(explosion, "position", testpos, closest_enemy.global_position + Vector2(5, -15), 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)#tween.targeting_property(explosion, "global_position", closest_enemy, "global_position", closest_enemy.global_position, 1.0, Tween.TRANS_SINE , Tween.EASE_IN)
					tween.start()
					testpos = closest_enemy.global_position + Vector2(5, -15) 
					testpos2 = closest_enemy.global_position + Vector2(0, - 30)
					global_position = testpos2
					variable_enemy.erase(closest_enemy)
				yield(get_tree().create_timer(0.1), "timeout")
				
	
	airexplosiontimer.start(1.0)
	playersprite.visible = true
	_enter_idle_state()
	


func _add_impact(dir):
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
	if name == "DASH_GROUND":
		smoke.animation = "ImpactDustKick"
		smoke.global_position = global_position + Vector2(-10*direction.x, -10)
		smoke.flip_h = flip
	if name == "DASH_AIR":
		smoke.animation = "New Anim"
		smoke.global_position = global_position + Vector2(-30* direction.x, 0)
		smoke.flip_h = flip
	get_tree().get_root().add_child(smoke)
	

func _spawn_energy(enemy):
	var child = energy_scene.instance()
	child.global_position = enemy.global_position
	hit_count = 0
	get_tree().get_root().call_deferred("add_child", child)
	

func _add_shockwave():
	var wave = shockwave_scene.instance()
	add_child(wave)
	

func _add_clone(enemy):
	var all_enemy = PlayerStats.enemies_hit_by_player
	rng.randomize()
	if all_enemy.size() > 0:
		var enemy_ind = rng.randi_range(0, all_enemy.size() - 1)
		enemy = all_enemy[enemy_ind]
		if is_instance_valid(enemy):
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
			clone.global_position = enemy.global_position + Vector2(30*dir, -5)
			clone.flip_h = flip 
			get_tree().get_root().add_child(clone)

func _add_assassin_ghost(): 
	var ghost = new_ghost_scene.instance()
	ghost.animation = playersprite.animation
	ghost.frame = playersprite.frame
	ghost.global_position = global_position
	ghost.flip_h = playersprite.flip_h
	get_tree().get_root().add_child(ghost)


func _die(hp):
	if hp <= 0:
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

func take_damage(amount: int) -> void: #Om spelaren tar damage, samt vilket håll den ska flyga åt
	_enter_hurt_state()
	if enemy_side_of_you == "right":
		_flip_sprite(true)
		direction_x = "RIGHT"
		hurt_direction.x = -1
		velocity.x = -400
	if enemy_side_of_you == "left":
		_flip_sprite(false)
		direction_x = "LEFT"
		hurt_direction.x = 1
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

func _set_player_mod(array: Array): #Hjälp funktion där man kan ändra spelarens modulate mha en lista
	playersprite.modulate.r = array[0]
	playersprite.modulate.g = array[1]
	playersprite.modulate.b = array[2]
	playersprite.modulate.a = array[3]

func frameFreeze(timescale, duration): #Gör att allt i spelet går i timescale tempo, i duration sekunder
	Engine.time_scale = timescale
	yield(get_tree().create_timer(duration * timescale), "timeout")
	Engine.time_scale = 1

func flash(): #Använder shader. Tänker inte försöka förklara shaders
	playersprite.material.set_shader_param("flash_modifier", 0.7) 
	yield(get_tree().create_timer(0.2), "timeout")
	playersprite.material.set_shader_param("flash_modifier", 0.0)
	
func _alpha_tween() -> void: #Visar att spelaren är immun mot dmg
	var alpha_tween_values = [255, 60]
	for i in range (4):
		tween.interpolate_property(playersprite, "modulate:a8", alpha_tween_values[0], alpha_tween_values[1], 0.25)
		tween.start()
		yield(get_tree().create_timer(0.25), "timeout")
		alpha_tween_values.invert()
		tween.interpolate_property(playersprite, "modulate:a8", alpha_tween_values[0], alpha_tween_values[1], 0.25)
		tween.start()
		alpha_tween_values.invert()	


func _remember_jump() -> void: #Buffer
	jumpbuffer.start(0.2)

func _remember_attack() -> void: #Buffer
	attackbuffer.start(0.1)

func _change_xp() -> void:
	emit_signal("XPChanged", PlayerStats.current_xp)

func _dash_to_enemy(enemy, switch_side: bool) -> void:
	if not switch_side:
		if is_instance_valid(enemy):
			if global_position.x >= enemy.global_position.x:
				global_position.x = enemy.global_position.x + 30 
				direction_x = "LEFT"
				_flip_sprite(false)
			else:
				global_position.x = enemy.global_position.x - 30
				direction_x = "RIGHT"
				_flip_sprite(true)
	else:
		if is_instance_valid(enemy):
			if global_position.distance_to(enemy.global_position) < 100:
				if global_position.x <= enemy.global_position.x:
					global_position.x = enemy.global_position.x + 30
					direction_x = "LEFT"
					_flip_sprite(false)
				else:
					global_position.x = enemy.global_position.x - 30
					direction_x = "RIGHT"
					_flip_sprite(true)

func _get_smearsprite(button: String): 
	if button == "q":
		animatedsmears.animation = PlayerStats.assassin_smearsprite_q
	if button == "w":
		animatedsmears.animation = PlayerStats.assassin_smearsprite_w
	if button == "e":
		animatedsmears.animation = PlayerStats.assassin_smearsprite_e


func check_combo() -> void: #Kollar senaste attackerna 
	var full_list = PlayerStats.assassin_combo_list
	var re_combo_list = []
	var check_combo_list = []
	var index
	for i in range(0, combo_list.size()):
		re_combo_list.push_front(combo_list[i])
	for i in range(4):
		check_combo_list.append(re_combo_list[i])
	if full_list.has(check_combo_list):
		index = full_list.find(check_combo_list) + 1
		_enter_combo_state(index)
	else:
		_enter_idle_state()

func _get_random_attack():
	var attack = "Attack"
	rng.randomize()
	var nr = rng.randi_range(1, 3)
	attack = "Attack"+str(nr)
	return attack

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


func _input(event):
	if event.is_action_pressed("ui_accept"): #Uppdaterar globala stats innan spelaren accepterar en portal
		PlayerStats.hp = hp

#STATES:
func _idle_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	if (Input.is_action_just_pressed("Jump") and can_jump) or jump_pressed == true:
		_add_jump_dust()
		_enter_air_state(true)

		return
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

func _dead_state(_delta) -> void:
	set_process_input(false)

func _crouch_state(delta) -> void:
	direction.x = _get_input_x_crouch_direction()
	velocity = velocity.move_toward(Vector2.ZERO, 0.5*ACCELERATION*delta)
	velocity.y += GRAVITY*delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if Input.is_action_just_pressed("Dash"): 
		if Input.is_action_pressed("Crouch"):
			velocity.y = JUMP_STRENGHT * 0.1
			playersprite.play("JumpN")
			set_collision_mask_bit(11, false) #Gör att man kan hoppa genom plattformar. Mer smooth gameplay
			_enter_air_state(false)
	
	if Input.is_action_just_released("Crouch"):
		_enter_run_state()

	if abs(velocity.x) >= 50:
		crouchtime += delta
		if crouchtime >= 0.07:
			_add_crouch_ghost()
			_add_assassin_ghost()
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

	
	if Input.is_action_just_pressed("Dash") and can_dash:
		_enter_dash_state(false, true)
		return
		
	if Input.is_action_just_pressed("EAttack1") and PlayerStats.assassin_can_dash_attack:
		_enter_dash_attack_state(1)
		return
	
	if Input.is_action_just_pressed("Crouch"):
		_enter_crouch_state()
		return
	
	if (input_x == 1 and velocity.x < 0) or (input_x == -1 and velocity.x > 0):
		_enter_stop_state()
		return
	
	if can_footstep_sound:
		stepsound.play()
		can_footstep_sound = false
		footsteptimer.start(0.4)
	
	_apply_basic_movement(delta)
	
	if not is_on_floor():
		_enter_air_state(false)
		return

	if velocity.x == 0:
		_enter_idle_state()
		return
	

func _air_state(delta) -> void:
	if Input.is_action_just_pressed("Dash") and can_dash:
		#_add_dash_smoke("test2")
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

	_air_movement(delta)
	var current_animation = playersprite.get_animation()
	if is_on_floor(): 
		_add_land_dust()
		_enter_idle_state()
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
		ghosttime = 0.06

func _dash_state_ground(delta):
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
		
		_enter_dash_state(false, true)
		return
		
	if (input_x == 1 and velocity.x > 0) or (input_x == -1 and velocity.x < 0):
		_enter_run_state()
		return
	if abs(velocity.x) >= 20:
		crouchtime += delta
		if crouchtime >= 0.07:
			_add_crouch_ghost()
			_add_assassin_ghost()
			crouchtime = 0
	
	if not is_on_floor():
		_enter_air_state(false)
		return
	elif velocity.length() == 0:
		_enter_idle_state()
		return

func _attack_state_ground(delta) -> void:
	_attack_function()

	
func _attack_state_dash(attack_nr : int, delta) -> void:
	velocity = velocity.move_toward(direction*MAX_SPEED*3, ACCELERATION*delta*3)
	velocity = move_and_slide(velocity, Vector2.UP)


func _prepare_attack_air_state(delta) -> void:
	playersprite.scale.y = lerp(playersprite.scale.y, 1, 1 - pow(0.01, delta))
	playersprite.scale.x = lerp(playersprite.scale.x, 1, 1 - pow(0.01, delta))

func _attack_state_air(delta) -> void:

	if direction_x != "RIGHT":
		animatedsmears.rotation_degrees = -45
		cut_area.rotation_degrees = -45
		velocity.x = -MAX_SPEED*10
	else: 
		animatedsmears.rotation_degrees = 45
		cut_area.rotation_degrees = 45
		velocity.x = MAX_SPEED*10
	cut_area.disabled = false
	velocity.y = GRAVITY*2
	
	
	
	if is_on_floor():
		velocity.x = 0
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
func _jump_attack_state(delta) -> void:
	_air_movement(delta)
	if is_on_floor():
		_enter_idle_state()

func _combo_state(delta) -> void:
	if Input.is_action_just_pressed("Dash"):
		_dash_to_enemy(test_var_enemy, true)
	
	attacktime += delta
	if attacktime >= 0.02:
		_add_assassin_ghost()
		attacktime = 0

func _hurt_state(delta) -> void:
	_apply_hurt_movement(delta)

#Enter states
func _enter_idle_state() -> void:
	check_sprites()
	state = IDLE
	playersprite.play("Idle")
	can_jump = true

func _enter_dash_state(attack: bool, ground: bool) -> void:
	check_sprites()
	dashparticles.emitting = true
	direction = Input.get_vector("move_left", "move_right","ui_up", "ui_down")
	if state == IDLE and direction == Vector2.DOWN:
		return
	elif direction == Vector2.ZERO:
		direction.x = 1 if direction_x == "RIGHT" else -1
	dashsound.play()
	if ground:
		_add_dash_smoke("DASH_GROUND")
		state = DASH_GROUND
	else:
		_add_dash_smoke("DASH_AIR")
		state = DASH_AIR
		can_add_ass_ghost = true
	_set_player_mod(player_glow_array)
	playersprite.play("Dash")
	can_dash = false
	dashtimer.start(0.25)
	
	
		
func _enter_crouch_state() -> void:
	state = CROUCH
	if velocity.x >= 1 or velocity.x <= -1:
		if direction_x == "RIGHT":
			_flip_sprite(false)
		else:
			_flip_sprite(true)
	playersprite.play("Crouch")

func _enter_air_state(jump: bool) -> void:
	check_sprites()
	if jump:
		velocity.y = JUMP_STRENGHT
		if velocity.x == 0:
			playersprite.play("JumpN")
		else:
			playersprite.play("JumpF")
		_get_random_sound("Jump")
		jumpsound.play()
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

func _enter_attack1_state(attack: int) -> void:
	state = ATTACK_GROUND
	combotimer.start(1)
	is_attacking = true
	animatedsmears.position.y = 5
	animationplayer.play("Attack" + str(attack))
	previous_attack = attack
	can_attack = false
	if can_attack_sound:
		_get_random_sound("Attack")
		attacksound.play()
		can_attack_sound = false
	combo_list.append(previous_attack) 
	if combo_list.size() >= 4:
		check_combo()

func _enter_dash_attack_state(attack: int) -> void:
	if attack == 1 and energy >= 5:
		state = ATTACK_DASH
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
		area_jump_attack.disabled = false
	else:
		animationplayer.play("PrepareAirAttack")
		state = PREPARE_ATTACK_AIR
		dashparticles.emitting = true
		_add_shockwave() #Shockwaven är en shader 
		frameFreeze(0.3, 0.4)

func _enter_hurt_state() -> void:
	state = HURT
	yield(get_tree().create_timer(0.5),"timeout")
	_enter_air_state(false)
	
func _enter_combo_state(number : int) -> void:
	ghosttime = 0.0
	var enemy_list = PlayerStats.enemies_hit_by_player
	var enemy = _get_closest_enemy(PlayerStats.enemies_hit_by_player)
	test_var_enemy = enemy
	state = COMBO
	if number == 1: 
		_combo1(enemy)
	if number == 2:
		_combo2(enemy, enemy_list)
	if number == 3:
		_combo3(enemy, enemy_list)
	combo_list.clear()

func _combo1(enemy):
	animationplayer.play("ComboSpinAttack")
	combo_list.clear()
	energy -= 10
	if Input.is_action_pressed("Dash") and energy >= 10:
		for i in range(PlayerStats.assassin_clone_targets):
			_add_clone(enemy) 
		energy -= 10
	emit_signal("EnergyChanged", energy)

func _combo2(enemy, list):
	can_take_damage = false
	var clone_added = false
	energy -= 20
	for i in range(0, list.size() -1):
		if list.size()-1 >= i:
			var attack = _get_random_attack()
			animationplayer.playback_speed = 3.0
			animationplayer.play(attack)
			frameFreeze(0.2*i, 0.2)
			_dash_to_enemy(list[i], true)
			if Input.is_action_pressed("Dash") and energy >= 10:
				for n in range(PlayerStats.assassin_clone_targets):
					_add_clone(enemy) 
				clone_added = true
			yield(get_tree().create_timer(0.06675), "timeout")
	animationplayer.playback_speed = 1.0
	if clone_added:
		energy -= 10
	emit_signal("EnergyChanged", energy)

func _combo3(enemy, list):
	_add_first_air_explosion()
	energy -= 20
	WorldEnv.emit_signal("Darken", "Combo3")
	yield(get_tree().create_timer(0.2), "timeout")
	_add_airexplosions()
	if Input.is_action_pressed("Dash")  and energy >= 10:
		energy -= 10
		for i in range(PlayerStats.assassin_clone_targets):
			_add_clone(enemy)
	emit_signal("EnergyChanged", energy)

#Signaler

func _on_AnimationPlayer_animation_finished(anim_name): #Byter states efter en animation 
	if anim_name == "Attack1" or "Attack2" or "Attack3" or "SpinAttack" or "ComboSpinAttack" or "comboewqe1" or "comboewqe2" or "comboewqe3":
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
		WorldEnv.emit_signal("Darken", "Prepare")
		state = ATTACK_AIR
		hurtbox.disabled = true
		animationplayer.play("Thrust2")
	if anim_name == "Thrust2":
		hurtbox.disabled = false
		cut_area.disabled = true
		animatedsmears.rotation_degrees = 0
		if is_on_floor():
			velocity.x = 0
			animationplayer.play("OnGroundAfterAttack")
			dashparticles.emitting = false
			_enter_idle_state()
			can_jump = false
			return
	if anim_name == "OnGroundAfterAttack":
		can_jump = true



func _on_HurtBox_area_entered(area):
	var amount
	if area.is_in_group("EnemySword"):
		amount = area.get_parent().damage_dealt
		if area.get_parent().global_position.x > global_position.x:
			enemy_side_of_you = "right"
		else:
			enemy_side_of_you = "left"
		if can_take_damage:
			take_damage(amount)

func _on_attack_damage_changed(type):
	if type == "basic_attack_damage":
		life_steal = PlayerStats.life_steal
		basic_attack_dmg = PlayerStats.assassin_basic_dmg
	if type == "dash_attack_damage":
		dash_attack_dmg = PlayerStats.assassin_dash_attack_dmg

func _on_xp_changed() -> void:
	_change_xp()

func _on_CollectParticlesArea_area_entered(area) -> void:
	if area.is_in_group("XP-Particle"):
		PlayerStats.current_xp += 5
		if _level_up():
			emit_signal("LvlUp", PlayerStats.current_lvl, PlayerStats.xp_needed)
			WorldEnv.emit_signal("Darken", "lvl_up")
			PlayerStats.skilltree_points += 1
		_change_xp()
	if area.is_in_group("EnergyParticle"):
		energy += 5
		hp += life_steal
		if energy > 50:
			energy = 50
		if hp > 100:
			hp = 100
		emit_signal("EnergyChanged", energy)
		emit_signal("HPChanged", hp)


func _on_NormalAttackArea_area_entered(area):
	if area.is_in_group("EnemyHitbox"):
		hit_count += 1
		if not PlayerStats.enemies_hit_by_player.has(area.get_parent()):
			PlayerStats.enemies_hit_by_player.append(area.get_parent())
		if hit_count >= 2:
			_spawn_energy(area.get_parent())
	if area.is_in_group("Dummy"):
		hit_count += 1
		if not PlayerStats.enemies_hit_by_player.has(area.get_parent()):
			PlayerStats.enemies_hit_by_player.append(area.get_parent())
		if hit_count >= 2:
			_spawn_energy(area)

func on_jump_sound_timer_timeout() -> void:
	can_jump_sound = true

func on_attack_sound_timer_timeout() -> void:
	can_attack_sound = true

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
	dashparticles.emitting = false
	ghosttime = 0.0
	can_dash = true
	if can_add_ass_ghost:
		justdashedtimer.start(1)
		dashghosttimer.start(0.1)
	yield(get_tree().create_timer(0.1), "timeout")
	_set_player_mod(player_default_array)

func _on_JustDashedTimer_timeout() -> void:
	can_add_ass_ghost = false
	dashghosttimer.stop()
	
func on_EnemyDead(body) -> void:
	if PlayerStats.enemies_hit_by_player.has(body):
		PlayerStats.enemies_hit_by_player.erase(body)

func _on_DropDetect_body_exited(body):
	set_collision_mask_bit(11, true)

func _on_AttackSound_finished():
	can_attack_sound = true

func _on_FootStepTimer_timeout():
	can_footstep_sound = true

func _on_DashGhostTimer_timeout():
	_add_assassin_ghost()


func _on_JumpBuffer_timeout():
	jump_pressed = false

func _on_AttackBuffer_timeout():
	attack_pressed = 0

func _on_AirExplosionTimer_timeout():
	hurtbox.disabled = false
