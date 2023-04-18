extends KinematicBody2D


const MAX_SPEED = 200
const ACCELERATION = 500
const GRAVITY = 1300
const JUMP_STRENGHT = -480

var velocity := Vector2.ZERO
var direction := Vector2.ZERO
var direction_x = 1
var direction_x_to_enemy = 1

enum {IDLE, RUN, AIR, ATTACK, DEAD, SPAWN}
var state = IDLE

var life_time := 5
var dead := false

onready var lt = $LifeTimer
onready var animsprite = $AnimatedSprite
onready var animplayer = $AnimationPlayer
onready var explosionsprite = $ExplosionSprite



var enemy


func _ready():
	explosionsprite.visible = false
	animsprite.modulate = "d4d4d4"
	lt.start(life_time)
	animsprite.scale.x = 1
	animsprite.scale.y = 1
	animsprite.play("Idle")

func _physics_process(delta):
	match state:
		IDLE:
			_idle_state(delta)
		RUN:
			_run_state(delta)
		AIR:
			_air_state(delta)
		ATTACK:
			_attack_state(delta)
		DEAD:
			_dead_state(delta)
		SPAWN:
			_spawn_state(delta)

#states
func _idle_state(delta) -> void:
	pass

func _run_state(delta) -> void:
	_get_direction_to_enemy(enemy)
	velocity.y += GRAVITY*delta
	velocity.x = MAX_SPEED* direction_x_to_enemy
	velocity = move_and_slide(velocity, Vector2.UP)

func _air_state(delta) -> void:
	pass

func _attack_state(delta) -> void:
	pass

func _dead_state(delta) -> void:
	pass

func _spawn_state(delta) -> void:
	pass

func _enter_idle_state() -> void:
	state = IDLE
	animsprite.play("Idle")
	
func _enter_run_state() -> void:
	#var all_enemy = get_tree().get_nodes_in_group("Enemy")
	var all_enemy = get_parent().get_tree().get_nodes_in_group("Enemy")
	state = RUN
	animsprite.play("Run")
	if _check_if_enemy_in_attack():
		_enter_attack_state()
	enemy = _get_closest_enemy(all_enemy)

func _enter_attack_state() -> void:
	velocity.x = 0
	state = ATTACK
	animplayer.play("Attack")

func _enter_dead_state() -> void:
	state = DEAD
	set_physics_process(false)
	velocity.x = 0
	$AttackDetector/CollisionShape2D.disabled = true
	$AttackArea/CollisionShape2D.disabled = true
	$EnemyDetector/CollisionShape2D.disabled = true
	$ExplosionArea/CollisionShape2D.disabled = false
	animsprite.visible = false
	animplayer.stop(false)
	explosionsprite.frame = 0
	explosionsprite.visible = true
	explosionsprite.play("Explosion")
	yield(explosionsprite, "animation_finished")
	queue_free()
	

func _flip_sprite(right:bool) -> void:
	if right:
		animsprite.flip_h = false
		$AttackArea/CollisionShape2D.position.x = 4
		$AttackDetector/CollisionShape2D.position.x = 4
	else:
		animsprite.flip_h = true
		$AttackArea/CollisionShape2D.position.x = -4
		$AttackDetector/CollisionShape2D.position.x = -4

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
	if is_instance_valid(enemy):
		if enemy.global_position.x <= global_position.x:
			direction_x_to_enemy = -1
			_flip_sprite(false)
		else:
			direction_x_to_enemy = 1
			_flip_sprite(true)
	else:
		direction_x_to_enemy = 0

func _check_enemy_irad():
	if dead:
		return false
	var all_enemy = get_parent().get_tree().get_nodes_in_group("Enemy")
	for body in $EnemyDetector.get_overlapping_bodies():
		if all_enemy.has(body):
			return true
	
	return false

func _check_if_enemy_in_attack():
	if dead:
		return false
	var all_enemy = get_parent().get_tree().get_nodes_in_group("Enemy")
	for body in $AttackDetector.get_overlapping_bodies():
		if all_enemy.has(body):
			return true
	return false

func _on_LifeTimer_timeout():
	_enter_dead_state()
	dead = true
	
func _on_EnemyDetector_body_entered(body):
	if body.is_in_group("Enemy"):
		if state != ATTACK or RUN or DEAD:
			_enter_run_state()

func _on_EnemyDetector_body_exited(body):
	if body.is_in_group("Enemy"):
		if not _check_enemy_irad():
			_enter_idle_state()

func _on_AttackDetector_body_entered(body):
	var all_enemy = get_parent().get_tree().get_nodes_in_group("Enemy")
	if state != ATTACK and body.is_in_group("Enemy"):
		_enter_attack_state()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		if _check_if_enemy_in_attack():
			_enter_attack_state()
			return
		if _check_enemy_irad():
			_enter_run_state()
			return
		else:
			_enter_idle_state()

