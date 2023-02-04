class_name Enemy
extends KinematicBody2D

enum {IDLE, RUN, ATTACK, DEAD, HURT, HUNTING}

const MAX_SPEED = 100
const ACCELERATION = 1000
const GRAVITY = 1000
const JUMP_STRENGHT = -410


export var direction_x = 1
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


var pushback_force = Vector2.ZERO

var test = 1

onready var animatedsprite = $AnimatedSprite
onready var idletimer = $IdleTimer
onready var runtimer = $RunTimer
onready var player = get_parent().get_node("../Node2D/Player")

var xp_scene = preload("res://Scenes/Experience-Particle.tscn")

var motion_previous = Vector2()

signal dead
signal hurt
signal side_of_player(which_side)

const INDICATOR_DAMAGE = preload("res://UI/DamageIndicator.tscn")

#onready var PlayerSword = preload("res://Scenes/NormalAttackArea.tscn")
var prutt = 0 #+delta
var hej = rand_range(6-prutt, 8-prutt)

var tween_values = [0.0, hej]
var tween = Tween.new()

var damage_amount = 0

func _ready(): 
	runtimer.start(3)
	$Area2D/CollisionShape2D.disabled = false
	
func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
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
		animatedsprite.flip_h = true
	if direction_x == 1:
		animatedsprite.flip_h = false



func flash():
	animatedsprite.material.set_shader_param("flash_modifier", 0.8)
	$FlashTimer.start(0.2)
	

func _turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		direction_x *= -1
		$RayCast2D.position.x += direction_x*20

func _hit():
	$AttackDetector.monitoring = true
	$AttackDetector.monitorable = true
	
func _end_of_hit():
	$AttackDetector.monitoring = false
	$AttackDetector.monitorable = false
	_die_b(hp)


func take_damage(amount: int) -> void:
	knock_back(player.position)
	#velocity.y = GRAVITY
	hp = hp - amount
	#$AnimationPlayer.play("Hurt1")

func knock_back(source_position: Vector2) -> void:
	$HitParticles.rotation = get_angle_to(source_position) + PI
	pushback_force = -global_position.direction_to(source_position) * 300
	
func _die_b(hp):
	if hp <= 0:
		state = DEAD
		animatedsprite.play("Dead")
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

func on_tween_completed(object, key):
	tween_values.invert()
	start_tween()

func _on_ShakeTimer_timeout() -> void:
	tween_values.invert()
	$Tween.kill()

#STATES
func _idle_state(delta) -> void:


	_die_b(hp)
	_air_movement(delta)


func _run_state(delta) -> void:
	_die_b(hp)
	_apply_basic_movement(delta)
	_turn_around()
	$Tween.remove_all()	
	if is_on_wall():
		direction_x *= -1
		$RayCast2D.position.x += direction_x*20

func _attack_state(delta) -> void:
	if (player.position.x >= ( global_position.x + 10) ) or (player.position.x <= (global_position.x -10)):
		_enter_hunt_state()
	
	velocity.x = 0
	

func _follow_player_state(delta) -> void:
	$Tween.remove_all()	
	if (player.position.x >= ( global_position.x + 10) ) or (player.position.x <= (global_position.x -10)):
		if global_position.x > player.position.x:
			animatedsprite.flip_h = true
			$AttackDetector/CollisionShape2D.position.x  = -4
			test = -1
		if global_position.x <= player.position.x:
			animatedsprite.flip_h = false
			$AttackDetector/CollisionShape2D.position.x  = 24
			test = 1
	else:
		_enter_attack_state()
		test = 0
	
	#_turn_around()
	velocity.y += GRAVITY*delta
	
	velocity.x = MAX_SPEED* test
	velocity = move_and_slide(velocity, Vector2.UP)
	
	
	_die_b(hp)


func _dead_state(delta) -> void:
	velocity.x = 0
	velocity.y = 0
	$IdleTimer.stop()
	$RunTimer.stop()
	$Area2D/CollisionShape2D2.disabled = true
	$Area2D/CollisionShape2D.disabled = true
	#$CollisionShape2D.disabled = true
	#_on_AnimatedSprite_animation_finished()


func _hurt_state(delta) -> void:
	pushback_force = lerp(pushback_force, Vector2.ZERO, delta * 10)
	move_and_slide(pushback_force)

	_air_movement(delta)
	
	_die_b(hp)
		



func _enter_idle_state() -> void:
	state = IDLE
	animatedsprite.play("Idle")
	rng.randomize()
	var time = rng.randi_range(3,5)
	idletimer.start(time)

func _enter_run_state() -> void:
	state = RUN
	animatedsprite.play("Run")
	rng.randomize()
	var time = rng.randi_range(3,5)
	runtimer.start(time)

func _enter_attack_state() -> void:
	state = ATTACK
	$AnimationPlayer.play("Hit")
	
func _enter_hunt_state() -> void:
	state = HUNTING
	animatedsprite.play("Hunt")

func _enter_hurt_state(number: int) -> void:
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
	flash()


func _on_IdleTimer_timeout():
	if state != ATTACK:
		 _enter_run_state()


func _on_RunTimer_timeout():
	if state != ATTACK:
		_enter_idle_state()

func _on_FlashTimer_timeout():
	animatedsprite.material.set_shader_param("flash_modifier", 0)

func _on_Area2D_area_entered(area):
	if area.is_in_group("PlayerSword"):
		damage_amount = 5
		_enter_hurt_state(1)
		emit_signal("hurt")
		_spawn_damage_indicator(damage_amount)
	if area.is_in_group("ComboEWQE"):
		damage_amount = 10
		_enter_hurt_state(1)
		emit_signal("hurt")
		_spawn_damage_indicator(damage_amount)
	if area.is_in_group("SwordCut"):
		damage_amount = 15
		_enter_hurt_state(2)
		emit_signal("hurt")
		_spawn_damage_indicator(damage_amount)
	_die_b(hp)
		
		#if hp <= 0:
		#	state = DEAD
		#	animatedsprite.play("Dead")
		#$Area2D/CollisionShape2D.disabled = true


func _on_AnimatedSprite_animation_finished():
	if animatedsprite.animation == "Dead":
		_spawn_xp()
		queue_free()


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
		if player_in_radius:
			_enter_hunt_state()
			can_attack = true
		else:
			_enter_idle_state()
			can_attack = true


func _on_PlayerDetector_body_entered(body):
	if state != HURT:
		if body.is_in_group("Player"):
			player_in_radius = true
			_enter_hunt_state()
		
func _on_PlayerDetector_body_exited(body):
	if body.is_in_group("Player"):
		player_in_radius = false
		_enter_run_state()

	
	

func _on_AttackDetector_body_entered(body):
	if state != HURT:	
		if body.is_in_group("Player"):
			if global_position.x > player.position.x:
				side = "right"
			else:
				side = "left"
			state = ATTACK
			$AnimationPlayer.play("Hit")
			emit_signal("side_of_player", side)
			velocity.x = 0
			can_attack = false

func _on_AttackDetector_body_exited(body):
	pass
	#if body.is_in_group("Player"):
	#	can_attack = true



func _on_AnimationPlayer_animation_changed(old_name: String) -> void:
	if old_name == "Hurt1":
		$Sprite.visible = false

func spawn_effect(EFFECT: PackedScene, effect_position: Vector2 = global_position):	
	if EFFECT:
		var effect = EFFECT.instance()
		get_tree().current_scene.add_child(effect)
		effect.global_position = effect_position + Vector2(direction_x*5, -30)
		return effect

func _spawn_damage_indicator(damage: int):
	var indicator = spawn_effect(INDICATOR_DAMAGE)
	var _direction = direction_x
	if indicator:
		indicator.label.text = str(damage)
	
func _spawn_xp() -> void:
	var xp = xp_scene.instance()
	xp.position = global_position
	get_tree().get_root().add_child(xp)
