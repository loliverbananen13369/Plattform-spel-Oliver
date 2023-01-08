extends KinematicBody2D

enum {IDLE, RUN, ATTACK, DEAD, HURT}

const MAX_SPEED = 100
const ACCELERATION = 1000
const GRAVITY = 1000
const JUMP_STRENGHT = -410

export var direction_x = 1
var velocity := Vector2()
var direction := Vector2.ZERO

var state = RUN

var rng = RandomNumberGenerator.new()

var dead = false

var hp_max = 100
var hp = hp_max

var pushback_force = Vector2.ZERO

onready var animatedsprite = $AnimatedSprite
onready var idletimer = $IdleTimer
onready var runtimer = $RunTimer
#onready var PlayerSword = preload("res://Scenes/NormalAttackArea.tscn")

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
	


func _apply_basic_movement(delta) -> void:
	velocity.y += GRAVITY*delta
	
	velocity.x = MAX_SPEED * direction_x
	velocity = move_and_slide(velocity, Vector2.UP)
	if direction_x == -1:
		animatedsprite.flip_h = true
	if direction_x == 1:
		animatedsprite.flip_h = false
	if is_on_wall():
		direction_x *= -1

func flash():
	animatedsprite.material.set_shader_param("flash_modifier", 0.8)
	$FlashTimer.start(0.2)
	
#STATES
func _idle_state(delta) -> void:
	if hp <= 0:
			state = DEAD
			animatedsprite.play("Dead")
	#if velocity.x != 0:
	#	_enter_run_state()
	#	return

func _run_state(delta) -> void:
	if hp <= 0:
			state = DEAD
			animatedsprite.play("Dead")
	_apply_basic_movement(delta)

func _attack_state(delta) -> void:
	pass

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
	frameFreeze(0.02, 0.4)
	flash()



	



func take_damage(amount: int) -> void:
	hp = hp - amount
	$AnimationPlayer.play("Hurt")
	print(hp)

func knock_back(source_position: Vector2) -> void:
	$HitParticles.rotation = get_angle_to(source_position) + PI
	pushback_force = -global_position.direction_to(source_position) * 300
	

#Enter state

func frameFreeze(timescale, duration):
	Engine.time_scale = timescale
	yield(get_tree().create_timer(duration * timescale), "timeout")
	Engine.time_scale = 1

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
	take_damage(10)
	state = HURT
	$AnimationPlayer.play("Hurt")

func _on_IdleTimer_timeout():
	_enter_run_state()


func _on_RunTimer_timeout():
	_enter_idle_state()

func _on_FlashTimer_timeout():
	animatedsprite.material.set_shader_param("flash_modifier", 0)

func _on_Area2D_area_entered(area):
	if area.is_in_group("PlayerSword"):
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Hurt")
		_enter_hurt_state()
		if hp <= 0:
			state = DEAD
			animatedsprite.play("Dead")
		#$Area2D/CollisionShape2D.disabled = true


func _on_AnimatedSprite_animation_finished():
	if animatedsprite.animation == "Dead":
		queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
		if anim_name == "Hurt":
			_enter_idle_state()
