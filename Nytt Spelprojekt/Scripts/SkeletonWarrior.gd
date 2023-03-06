extends KinematicBody2D

enum {IDLE, AIR, RUN, ATTACK, DEAD, HURT, HUNTING, SPAWN}

const MAX_SPEED = 100
const ACCELERATION = 1000
const GRAVITY = 1000
const JUMP_STRENGHT = -410


export var direction_x = 1
var direction_x_to_player 
var velocity := Vector2()
var direction := Vector2.ZERO

var time_to_turn = false
var side 
var state = RUN

var rng = RandomNumberGenerator.new()

var dead = false

var player_in_radius = false

var hp_max = 100
var hp = hp_max

var can_attack = true

var can_die := true
var pushback_force = Vector2.ZERO

var test = 1

onready var animatedsprite = $AnimatedSprite
onready var idletimer = $IdleTimer
onready var runtimer = $RunTimer
var player 
var golem

var xp_scene = preload("res://Scenes/Experience-Particle.tscn")

var motion_previous = Vector2()

signal dead
signal hurt
signal side_of_player(which_side)
signal pos(position)

const INDICATOR_DAMAGE = preload("res://UI/DamageIndicator.tscn")

#onready var PlayerSword = preload("res://Scenes/NormalAttackArea.tscn")
var prutt = 0 #+delta
var hej = rand_range(6-prutt, 8-prutt)

var tween_values = [0.0, hej]
var tween = Tween.new()

var damage_amount = 0

func _ready(): 
	
	player = get_parent().get_parent().get_child(1).get_child(0)
	$PlayerDetector.monitoring = false
	state = SPAWN
	$AnimationPlayer.play("Spawn")
	

	
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
	if right:
		animatedsprite.flip_h = false
		$CollisionShape2D.position.x = -4
		$HurtBox/CollisionShape2D.position.x = -4
		$AttackDetector/CollisionShape2D.position.x  = 10
		$AttackArea/CollisionShape2D2.position.x = 10
	else:
		animatedsprite.flip_h = true
		$CollisionShape2D.position.x = 4
		$HurtBox/CollisionShape2D.position.x = 4
		$AttackDetector/CollisionShape2D.position.x  = -10
		$AttackArea/CollisionShape2D2.position.x = -10

func _get_direction_to_player():
	if player.global_position.x <= global_position.x:
		direction_x_to_player = -1
		_flip_sprite(false)
	else:
		direction_x_to_player = 1
		_flip_sprite(true)

func _check_if_hit_wall() -> void:
	if $WallRayCast.is_colliding():
		velocity.y = JUMP_STRENGHT
	else:
		return

func flash():
	animatedsprite.material.set_shader_param("flash_modifier", 0.8)
	$FlashTimer.start(0.2)
	
func _turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		direction_x *= -1
		$RayCast2D.position.x = direction_x*15

func _hit():
	$AttackArea/CollisionShape2D2.disabled = false
	
func _end_of_hit():
	$AttackArea/CollisionShape2D2.disabled = true
	_die_b()

func _bug_fixer() -> void:
	animatedsprite.modulate.a8 = 255
	$Sprite.visible = false
	$AnimatedSprite2.visible = false
	$HitParticles.visible = false
	$HitParticles.emitting = false

func take_damage(amount: int) -> void:
	knock_back(player.position)
	#velocity.y = GRAVITY
	hp = hp - amount
	#$AnimationPlayer.play("Hurt1")
	_die_b()

func knock_back(source_position: Vector2) -> void:
	$HitParticles.rotation = get_angle_to(source_position) + PI
	pushback_force = -global_position.direction_to(source_position) * 300
	
func _die_b():
	if hp <= 0:
		state = DEAD
		if can_die:
			$AnimationPlayer.play("Dead")
#Enter state

func frameFreeze(timescale, duration):
	Engine.time_scale = timescale
	#start_tween()
	yield(get_tree().create_timer(duration * timescale), "timeout")
	Engine.time_scale = 1

func _enter_tree():
	tween.name = "Tween"
	add_child(tween)    
	tween.connect("tween_completed", self, "on_tween_completed")
	
func start_tween():
	$Tween.interpolate_property($AnimatedSprite, "offset:x", tween_values[0], tween_values[1], 0.1)
	$Tween.start()
	prutt - $ShakeTimer.time_left
	$ShakeTimer.start(3)

func on_tween_completed(_object, _key):
	tween_values.invert()
	start_tween()

func _on_ShakeTimer_timeout() -> void:
	tween_values.invert()
	$Tween.kill()

#STATES
func _idle_state(delta) -> void:
	pass
	#_die_b()
	#if not is_on_floor():
		#_enter_air_state(1)

func _air_state(delta) -> void:
	#_die_b()
	_air_movement(delta)
	if is_on_floor():
		_enter_idle_state()

func _run_state(delta) -> void:
	#_die_b()
	_apply_basic_movement(delta)
	_turn_around()
	$Tween.remove_all()	
	if is_on_wall():
		direction_x *= -1
		$RayCast2D.position.x += direction_x*20

func _attack_state(delta) -> void:
	_air_movement(delta)

func _follow_player_state(delta) -> void:
	$Tween.remove_all()
	_apply_follow_player_movement(delta)
	_die_b()

func _spawn_state(_delta) -> void:
	velocity.x = 0
	velocity.y = 0
	$HurtBox/CollisionShape2D.disabled = true
	$PlayerDetector.monitoring = false

func _dead_state(_delta) -> void:
	velocity.x = 0
	velocity.y = 0
	$IdleTimer.stop()
	$RunTimer.stop()
	$HurtBox/CollisionShape2D.disabled = true
	#$CollisionShape2D.disabled = true
	#_on_AnimatedSprite_animation_finished()


func _hurt_state(delta) -> void:
	#pushback_force = lerp(pushback_force, Vector2.ZERO, delta * 10)
	#move_and_slide(pushback_force)

	_air_movement(delta)
	
	_die_b()
		

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
	emit_signal("side_of_player", side)
	velocity.x = 0
	can_attack = false
	
func _enter_hunt_state() -> void:
	idletimer.stop()
	runtimer.stop()
	state = HUNTING
	animatedsprite.play("Hunt")

func _enter_hurt_state(number: int) -> void:
	_get_direction_to_player()
	rng.randomize()
	var random_number = rng.randi_range(1,2)
	take_damage(damage_amount)
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

		
	flash()


func _on_IdleTimer_timeout():
	if state != ATTACK and state != AIR:
		 _enter_run_state()


func _on_RunTimer_timeout():
	if state != ATTACK and state != AIR:
		_enter_idle_state()

func _on_FlashTimer_timeout():
	animatedsprite.material.set_shader_param("flash_modifier", 0)


func _on_HurtBox_area_entered(area):
	var holy_active = player.get("holy_buff_active")
	var dark_active = player.get("dark_buff_active")
	var crit = false
	if holy_active or dark_active:
		crit = true
	else:
		crit = false
	if area.is_in_group("PlayerSword"):
		var damage = player.get("damage_a1")
		damage_amount = damage
		_enter_hurt_state(1)
		_spawn_damage_indicator(damage_amount, crit)
	if area.is_in_group("GolemAttack"):
		var damage = player.get("damage_a1")
		damage_amount = damage
		_enter_hurt_state(1)
		_spawn_damage_indicator(damage_amount, crit)
	if area.is_in_group("GolemBurst"):
		var damage = player.get("damage_a1")
		damage_amount = damage
		_enter_hurt_state(3)
		_spawn_damage_indicator(damage_amount, crit)
	if area.is_in_group("DashAttack"):
		var damage = player.get("damage_combo_ewqe1")
		damage_amount = damage
		_enter_hurt_state(1)
		_spawn_damage_indicator(damage_amount, crit)
	if area.is_in_group("Ability2"):
		var damage = player.get("damage_ability2")
		damage_amount = damage
		_enter_hurt_state(1)
		_spawn_damage_indicator(damage_amount, crit)
	elif area.is_in_group("Ability1"):
		var damage = player.get("damage_ability1")
		damage_amount = damage
		_enter_hurt_state(1)
		_spawn_damage_indicator(damage_amount, crit)
	if area.is_in_group("SwordCut"):
		var damage = player.get("damage_combo_qweq")
		damage_amount = damage
		_enter_hurt_state(2)
		_spawn_damage_indicator(damage_amount, crit)
	if area.is_in_group("AirExplosion"):
		damage_amount = 10
		emit_signal("pos", global_position)
		_enter_hurt_state(1)
		_spawn_damage_indicator(damage_amount, crit)

	_die_b()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Hurt1":
		$Sprite.visible = false
		if player_in_radius:
			_enter_hunt_state()
		else:
			_enter_idle_state()
	if anim_name == "Hurt2":
		$AnimatedSprite2.visible = false
		if player_in_radius:
			_enter_hunt_state()
		else:
			_enter_idle_state()
	if anim_name == "Hit":
		if $AttackDetector.overlaps_body(player):
			_enter_attack_state()
		elif player_in_radius:
			_enter_hunt_state()
		else:
			_enter_idle_state()
		can_attack = true
	if anim_name == "Spawn":
		_bug_fixer()
		$PlayerDetector.monitoring = true
		if player_in_radius:
			_enter_hunt_state()
		else:
			_enter_idle_state()
		$HurtBox/CollisionShape2D.disabled = false
	if anim_name == "Dead":
		_spawn_xp()
		PlayerStats.emit_signal("EnemyDead", self)
		queue_free()
		



func _on_PlayerDetector_body_entered(body):
	if state != HURT:
		if body.is_in_group("Player"):
			player_in_radius = true
			_enter_hunt_state()
		
func _on_PlayerDetector_body_exited(body):
	if body.is_in_group("Player"):
		player_in_radius = false
		_enter_run_state()

	
func on_GolemStatus():
	if true:
		print("true")


func _on_AttackDetector_body_entered(body):
	if state != HURT:
		_enter_attack_state()

func _on_AttackDetector_body_exited(body):
	if body.is_in_group("Player") and not can_attack:
		_enter_hunt_state()
	#if body.is_in_group("Player"):
	#	can_attack = true



func _on_AnimationPlayer_animation_changed(old_name: String) -> void:
	if old_name == "Hurt1":
		$Sprite.visible = false

func spawn_effect(EFFECT: PackedScene, effect_position: Vector2 = global_position):	
	if EFFECT:
		var effect = EFFECT.instance()
		get_tree().current_scene.add_child(effect)
		effect.global_position = effect_position + Vector2(-direction_x*5, -40)
		return effect

func _spawn_damage_indicator(damage: int, crit: bool):
	var indicator = spawn_effect(INDICATOR_DAMAGE)
	var _direction = direction_x
	var anim = indicator.get_node("AnimationPlayer")
	if indicator:
		if not crit:
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





