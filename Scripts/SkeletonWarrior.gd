extends KinematicBody2D

"""
Har mycket onödig kod tror jag , men jag skrev den här tidigt och hade många många ideer då.
"""


enum {IDLE, AIR, RUN, ATTACK, DEAD, HURT, HUNTING, SPAWN}

const MAX_SPEED = 100
const ACCELERATION = 1000
const GRAVITY = 1000
const JUMP_STRENGHT = -410

const HURT_SOUNDS = [preload("res://Sounds/ImportedSounds/Enemy/EnemyHurt/enemy_hurt_1.wav"), preload("res://Sounds/ImportedSounds/Enemy/EnemyHurt/enemy_hurt_2.wav")]
const ATTACK_SOUNDS = [preload("res://Sounds/ImportedSounds/Enemy/EnemyAttack/enemy_attack_3.wav"), preload("res://Sounds/ImportedSounds/Enemy/EnemyAttack/enemy_attack_4.wav")]
const DEATH_SOUND = preload("res://Sounds/ImportedSounds/Enemy/EnemyDead/enemy_death_1.wav")

export var direction_x = 1

var can_hurt_sound := true

var direction_x_to_player 
var velocity := Vector2()
var direction := Vector2.ZERO

var time_to_turn = false
var side 
var state = RUN

var rng = RandomNumberGenerator.new()

var dead = false

var player_in_radius = false

export (int) var hp_max 
var hp 
export (String) var type
var damage_dealt

var can_attack = true
var can_hunt = true
var can_detect = true

var can_die := true
var pushback_force = Vector2.ZERO

var test = 1


onready var animatedsprite = $AnimatedSprite
onready var idletimer = $IdleTimer
onready var runtimer = $RunTimer
onready var hpbar = $HPBar/ProgressBar

var player 
var golem

var xp_scene = preload("res://Instance_Scenes/Experience-Particle.tscn")


var motion_previous = Vector2()

signal hurt
signal side_of_player(which_side)

const INDICATOR_DAMAGE = preload("res://UI/DamageIndicator.tscn")


var damage_amount = 0

func _ready():  #Främst debug, eftersom skelettet ska spawna först
	player = PlayerStats.player
	$AttackArea/CollisionShape2D2.disabled = true
	$PlayerDetector.monitoring = false
	$AttackDetector.monitoring = false
	velocity.x = 0
	velocity.y = 0
	$HurtBox.monitoring = false
	state = SPAWN
	$Sprite.visible = false
	$AnimationPlayer.play("Spawn")
	hp = hp_max
	hpbar.max_value = hp
	hpbar.value = hp
	

	
func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		AIR:
			_air_state(delta)
		RUN:
			_run_state(delta)
		ATTACK:
			_attack_state(delta)
		DEAD:
			_dead_state(delta)
		HURT: 
			_hurt_state(delta)
		HUNTING:
			_follow_player_state(delta)
		SPAWN:
			_spawn_state(delta)

	
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
		_flip_sprite(false)
	if direction_x == 1:
		_flip_sprite(true)

func _apply_follow_player_movement(delta) -> void:
	_get_direction_to_player()
	velocity.y += GRAVITY*delta
	velocity.x = MAX_SPEED* direction_x_to_player
	velocity = move_and_slide(velocity, Vector2.UP)
	

func _flip_sprite(right: bool):
	var dir
	if right:
		dir = 1
		animatedsprite.flip_h = false
	else:
		dir = -1
		animatedsprite.flip_h = true
	$CollisionShape2D.position.x = - 4*dir
	$HurtBox/CollisionShape2D.position.x = -4*dir
	$AttackDetector/CollisionShape2D.position.x  = 10*dir
	$AttackArea/CollisionShape2D2.position.x = 10*dir
	$WallRayCast/CollisionShape2D.position.x = 10*dir
	$RayCast2D.position.x = 15*dir
	$Sprite.position.x = -3 * dir
		
func _get_direction_to_player(): #Ger om spelarens globala position har större eller mindre x värde än en själv
	if player.global_position.x <= global_position.x:
		direction_x_to_player = -1
		_flip_sprite(false)
	else:
		direction_x_to_player = 1
		_flip_sprite(true)

func _get_random_sound(what: String) -> void:
	rng.randomize()
	if what == "Hurt":
		var number = rng.randi_range(0, HURT_SOUNDS.size()-1)
		$HurtSound.stream = HURT_SOUNDS[number]
	if what == "Attack":
		var number = rng.randi_range(0, ATTACK_SOUNDS.size()-1)
		$AttackSound.stream = ATTACK_SOUNDS[number]

func flash():
	animatedsprite.material.set_shader_param("flash_modifier", 0.0) 
	$FlashTimer.start(0.2)
	
func _turn_around():
	if direction_x !=0:
		direction_x *= -1
	else:
		direction_x = 1


func _bug_fixer() -> void:
	$HurtBox.set_deferred("monitoring", true)
	animatedsprite.modulate.a8 = 255
	$Sprite.visible = false
	$AnimatedSprite2.visible = false

func take_damage(amount: int) -> void:
	knock_back(player.position)
	hp = hp - amount
	hpbar.value = hp
	$HPBar/AnimationPlayer.stop(true)
	$HPBar/AnimationPlayer.play("default")
	
func knock_back(source_position: Vector2) -> void: #När fienden tar skada
	pushback_force = -global_position.direction_to(source_position) * 300
	
func _die_b():
	if hp <= 0:
		dead = true
		can_hunt = false
		can_attack = false
		$HurtBox/CollisionShape2D.set_deferred("disabled", true)
		_enter_dead_state()
#Enter state

func frameFreeze(timescale, duration):
	Engine.time_scale = timescale
	yield(get_tree().create_timer(duration * timescale), "timeout")
	Engine.time_scale = 1

#STATES
func _idle_state(_delta) -> void:
	if not is_on_floor():
		_enter_air_state(0)

func _air_state(delta) -> void:
	_air_movement(delta)
	if is_on_floor():
		_enter_idle_state()

func _run_state(delta) -> void:
	_apply_basic_movement(delta)


func _attack_state(delta) -> void:
	_air_movement(delta)

func _follow_player_state(delta) -> void:
	_apply_follow_player_movement(delta)
	if not can_hunt:
		_enter_idle_state()

func _spawn_state(_delta) -> void: #Återigen, så att den inte rör sig 
	pass

func _dead_state(_delta) -> void:
	pass


func _hurt_state(delta) -> void:
	_air_movement(delta)
	
		

func _enter_idle_state() -> void:
	state = IDLE
	animatedsprite.play("Idle")
	rng.randomize()
	var time = rng.randi_range(3,5)
	idletimer.start(time)
	_bug_fixer()

func _enter_air_state(num : int) -> void:
	idletimer.stop()
	runtimer.stop()
	state = AIR
	if num == 1:
		velocity.y = JUMP_STRENGHT

func _enter_run_state() -> void:
	state = RUN
	animatedsprite.play("Run")
	rng.randomize()
	var time = rng.randi_range(3,5)
	runtimer.start(time)

func _enter_attack_state() -> void:
	if global_position.x > player.position.x:
		side = "right"
	else:
		side = "left"
	state = ATTACK
	$AnimationPlayer.play("Hit")
	_get_random_sound("Attack")
	$AttackSound.play()
	emit_signal("side_of_player", side)
	velocity.x = 0
	can_attack = false
	
func _enter_hunt_state() -> void:
	idletimer.stop()
	runtimer.stop()
	state = HUNTING
	animatedsprite.play("Hunt")

func _enter_hurt_state(amount: int, number: int, dark: bool, holy: bool) -> void:
	_get_direction_to_player()
	rng.randomize()
	var random_number = rng.randi_range(1,2)
	if dark:
		amount *= 2
	elif holy:
		amount*=1.5
	take_damage(amount)
	_spawn_damage_indicator(amount, dark, holy)
	state = HURT
	$AnimationPlayer.stop()
	if random_number == 1:
		$Sprite.animation = "Hurt1"
	else:
		$Sprite.animation = "Hurt2"
	if number == 1:
		$AnimationPlayer.play("Hurt1")
	if number == 2:
		$AnimationPlayer.play("Hurt2")
	if number == 3:
		$AnimationPlayer.play("Hurt1")
		_enter_air_state(1)
	if can_hurt_sound:
		_get_random_sound("Hurt")
		$HurtSound.play()
	
	flash()
	_die_b()

func _enter_dead_state() -> void:
	can_attack = false
	$IdleTimer.stop()
	$RunTimer.stop()
	state = DEAD
	velocity.x = 0
	velocity.y = 0
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Dead")
	$HurtSound.stop()
	$HurtSound.stream = DEATH_SOUND
	$HurtSound.play()

func _on_IdleTimer_timeout():
	if state != ATTACK and state != AIR and state != HUNTING and state != DEAD:
		 _enter_run_state()


func _on_RunTimer_timeout():
	if state != ATTACK and state != AIR and state != HUNTING and state != DEAD:
		_enter_idle_state()

func _on_FlashTimer_timeout():
	animatedsprite.material.set_shader_param("flash_modifier", 0)


func _on_HurtBox_area_entered(area): #Kollar om en area2d kommer in i dess egna area. Holy och dark active ger extra damage om de är sanna.
	var holy_active = player.get("holy_buff_active")
	var dark_active = player.get("dark_buff_active")
	var damage = 0
	if area.is_in_group("PlayerSword"):
		damage = player.basic_attack_dmg
		_enter_hurt_state(damage, 1, dark_active, holy_active)
		return
	if area.is_in_group("DeadSword"):
		damage = player.dead_skeleton_dmg
		_enter_hurt_state(damage, 1, dark_active, holy_active)
		return
	if area.is_in_group("DeadExplosion"):
		damage = player.dead_skeleton_exp_dmg
		_enter_hurt_state(damage, 1, dark_active, holy_active)
		return
	if area.is_in_group("GolemAttack"):
		damage = player.golem_dmg
		_enter_hurt_state(damage, 1, dark_active, holy_active)
		return
	if area.is_in_group("GolemBurst"):
		damage = player.golem_dmg
		_enter_hurt_state(damage, 3, dark_active, holy_active)
		return
	if area.is_in_group("DashAttack"):
		damage = player.dash_attack_dmg
		_enter_hurt_state(damage, 1, dark_active, holy_active)
		return
	if area.is_in_group("Ability2"):
		damage = player.damage_ability2
		_enter_hurt_state(damage, 1, dark_active, holy_active)
		return
	if area.is_in_group("Ability1"):
		damage = player.damage_ability1
		_enter_hurt_state(damage, 1, dark_active, holy_active)
		return
	if area.is_in_group("SwordCut"):
		damage = player.spin_attack_dmg
		_enter_hurt_state(damage, 2, dark_active, holy_active)
		return
	if area.is_in_group("AirExplosion"):
		damage = 10
		_enter_hurt_state(damage, 1, dark_active, holy_active)
		return
	if area.is_in_group("Cut"):
		damage = player.cut_dmg
		_enter_hurt_state(damage, 2, dark_active, holy_active)
		return
	
	


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Hurt1":
		$Sprite.visible = false
		if player_in_radius and can_hunt:
			_enter_hunt_state()
		else:
			_enter_idle_state()
	if anim_name == "Hurt2":
		$AnimatedSprite2.visible = false
		if player_in_radius and can_hunt:
			_enter_hunt_state()
		else:
			_enter_idle_state()
	if anim_name == "Hit":
		if $AttackDetector.overlaps_body(player):
			_enter_attack_state()
		elif player_in_radius and can_hunt:
			_enter_hunt_state()
		else:
			_enter_idle_state()
		can_attack = true
	if anim_name == "Spawn":
		_bug_fixer()
		$PlayerDetector.monitoring = true
		$AttackDetector.monitoring = true

		if player_in_radius and can_hunt:
			_enter_hunt_state()
		else:
			_enter_idle_state()
	if anim_name == "Dead":
		_spawn_xp()
		remove_from_group("Enemy")
		PlayerStats.emit_signal("EnemyDead", self)
		Quests.emit_signal("EnemyDead", type)
		queue_free()
		

func _on_PlayerDetector_body_entered(body):
	if state != HURT and not dead:
		if body.is_in_group("Player") and can_hunt:
			player_in_radius = true
			_enter_hunt_state()
		
func _on_PlayerDetector_body_exited(body):
	if state != HURT and not dead:
		if body.is_in_group("Player"):
			player_in_radius = false
			_enter_run_state()


func _on_AttackDetector_body_entered(body):
	if state != HURT and not dead:
		if body.is_in_group("Player"):
			_enter_attack_state()

func _on_AttackDetector_body_exited(body):
	if body.is_in_group("Player") and not can_attack and can_hunt:
		_enter_hunt_state()



func spawn_effect(EFFECT: PackedScene, effect_position: Vector2 = global_position): #Jag antar att jag borde gjort så här i playerscenerna, istället för så många _add_... Tog detta i början när jag inte visste hur jag skulle kunna lägga till skadeindikatorer
	if EFFECT:
		var effect = EFFECT.instance()
		get_tree().current_scene.add_child(effect)
		effect.global_position = effect_position + Vector2(-direction_x*5, -40)
		return effect

func _spawn_damage_indicator(damage: int, dark: bool, holy: bool):
	var indicator = spawn_effect(INDICATOR_DAMAGE)
	var _direction = direction_x
	var anim = indicator.get_node("AnimationPlayer")
	if indicator:
		if not ( dark or holy ):
			anim.play("ShowDamage")
			indicator.label.text = str(damage)
		else:
			anim.play("ShowCrit")
			indicator.label.text = str(damage)
	emit_signal("hurt")


func _spawn_xp() -> void:
	var xp = xp_scene.instance()
	xp.position = global_position
	get_tree().get_root().add_child(xp)


func _on_RayCast2D_body_exited(body): #Ser till att fienden vänder sig om ifall den kommer falla av en plattform
	var layer = body.get_collision_layer()
	if layer == 16 or 2048:
		_turn_around()

func _on_WallRayCast_body_entered(body): #Ser till att fienden vänder sig om ifall den träffat en vägg
	var layer = body.get_collision_layer()
	if layer == 16:
		_turn_around()


func _on_HurtSound_finished():
	can_hurt_sound = true








