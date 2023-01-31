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

var motion_previous = Vector2()

signal dead
signal hurt


#onready var PlayerSword = preload("res://Scenes/NormalAttackArea.tscn")
var prutt = 0 #+delta
var hej = rand_range(6-prutt, 8-prutt)

var tween_values = [0.0, hej]
var tween = Tween.new()


func _ready(): 
	runtimer.start(3)
	$Area2D/CollisionShape2D.disabled = false
	
func _physics_process(delta: float) -> void:
	#print(player.position.x)  #+ 240)
	#print(global_position.x)
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
	
func _end_of_hit():
	$AttackDetector.monitoring = false


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
	pass
func _follow_player_state(delta) -> void:
	$Tween.remove_all()	
	if global_position.x > player.position.x:
		animatedsprite.flip_h = true
		$AttackDetector/CollisionShape2D.position.x  = -4
		test = -1
	if global_position.x <= player.position.x:
		animatedsprite.flip_h = false
		$AttackDetector/CollisionShape2D.position.x  = 24
		test = 1
	
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
	$CollisionShape2D.disabled = true
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

func _enter_hurt_state() -> void:
	var random_number = rng.randi_range(1,2)
	take_damage(5)
	state = HURT
	$AnimationPlayer.stop()
	if random_number == 1:
		$Sprite.animation = "Hurt1"
	else:
		$Sprite.animation = "Hurt2"
	$AnimationPlayer.play("Hurt1")
	flash()
	frameFreeze(1, 0.5)


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
		_enter_hurt_state()
		emit_signal("hurt")
		if hp <= 0:
			state = DEAD
			animatedsprite.play("Dead")
			emit_signal("dead")
		#if hp <= 0:
		#	state = DEAD
		#	animatedsprite.play("Dead")
		#$Area2D/CollisionShape2D.disabled = true


func _on_AnimatedSprite_animation_finished():
	if animatedsprite.animation == "Dead":
		queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Hurt1":
		if player_in_radius:
			animatedsprite.play("Hunt")
			state = HUNTING
		else:
			_enter_idle_state()
	if anim_name == "Hit":
		if player_in_radius:
			state = HUNTING
			animatedsprite.play("Hunt")
		else:
			_enter_idle_state()


func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("Player"):
		player_in_radius = true
		state = HUNTING
		animatedsprite.play("Hunt")
		_hit()
		
func _on_PlayerDetector_body_exited(body):
	if body.is_in_group("Player"):
		player_in_radius = false
		_enter_idle_state()

	
	

func _on_AttackDetector_body_entered(body):
	if body.is_in_group("Player"):
		state = ATTACK
		$AnimationPlayer.play("Hit")
		velocity.x = 0
		can_attack = false


func _on_AttackDetector_body_exited(body):
	if body.is_in_group("Player"):
		can_attack = true




