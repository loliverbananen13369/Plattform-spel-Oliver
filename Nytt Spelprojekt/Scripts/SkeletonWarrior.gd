extends KinematicBody2D

enum {IDLE, RUN, ATTACK, DEAD}

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

onready var animatedsprite = $AnimatedSprite
onready var idletimer = $IdleTimer
onready var runtimer = $RunTimer

func _ready():
	runtimer.start(3)
	
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
	animatedsprite.material.set_shader_param("flash_modifier", 1)
	$FlashTimer.start()
	
#STATES
func _idle_state(delta) -> void:
	pass
	#if velocity.x != 0:
	#	_enter_run_state()
	#	return

func _run_state(delta) -> void:
	_apply_basic_movement(delta)

func _attack_state(delta) -> void:
	pass

func _dead_state(delta) -> void:
	velocity.x = 0
	velocity.y = 0
	$Area2D/CollisionShape2D2.disabled = true
	$CollisionShape2D.disabled = true
	#_on_AnimatedSprite_animation_finished()
	

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
	print(idletimer.time_left)

func _enter_run_state() -> void:
	state = RUN
	animatedsprite.play("Run")
	rng.randomize()
	var time = rng.randi_range(3,5)
	runtimer.start(time)
	print(runtimer.time_left)



func _on_IdleTimer_timeout():
	_enter_run_state()


func _on_RunTimer_timeout():
	_enter_idle_state()

func _on_FlashTimer_timeout():
	animatedsprite.aterial.set_shader_param("flash_modifier", 0)

func _on_Area2D_area_entered(area):
	if area.is_in_group("PlayerSword"):
		frameFreeze(0.05, 1)
		print("Hej")
		state = DEAD
		animatedsprite.play("Dead")


func _on_AnimatedSprite_animation_finished():
	if animatedsprite.animation == "Dead":
		queue_free()



