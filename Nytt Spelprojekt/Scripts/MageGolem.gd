extends KinematicBody2D

const MAX_SPEED = 200
const ACCELERATION = 1000
const GRAVITY = 1300
const JUMP_STRENGHT = -480

var velocity := Vector2.ZERO
var direction := Vector2.ZERO
var direction_x = 1
var direction_x_to_player = 1
var direction_x_to_enemy 

enum {IDLE, RUN, AIR, ATTACK, DEAD, PROTECT, FOLLOW_ENEMY, SPAWN, FOLLOW_PLAYER}
var state = FOLLOW_PLAYER

var searching_for_enemy := false


onready var animatedsprite = $AnimatedSprite
onready var playerdetector = $PlayerDetector
onready var playerneararea = $PlayerNearArea
onready var enemydetector = $EnemyDetector
onready var animationplayer = $AnimationPlayer

var ksanteq_scene = preload("res://Instance_Scenes/MageGolemKsanteQ.tscn")
var ksanteqimpact_scene = preload("res://Instance_Scenes/KsanteQImpact.tscn")

var player
var follow_this_enemy
var must_follow_this_enemy
var enemy_who_hurt
var hit_wall = false
var attack1_finished 
var wants_to_follow_enemy = false
var angry = false

func _ready():
	PlayerStats.golem_active = true
	PlayerStats.connect("PlayerHurt", self, "on_PlayerHurt")
	PlayerStats.connect("EnemyDead", self, "on_EnemyDead")
	PlayerStats.connect("EnemyHurt", self, "on_EnemyHurt")
	player = PlayerStats.player#get_parent().get_child(3).get_child(1).get_child(0)
func _physics_process(delta: float) -> void:
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
		PROTECT:
			_protect_player_state(delta)
		FOLLOW_ENEMY: 
			_follow_enemy_state(delta)
		SPAWN:
			_spawn_state(delta)
		FOLLOW_PLAYER:
			_follow_player_state(delta)

func _flip_sprite(right: bool):
	if right:
		animatedsprite.flip_h = false
		$EnemyInRangeForAttack/CollisionShape2D.position.x = 12
		$MustEnemyInRangeForAttack2/CollisionShape2D.position.x = 12
		$Attack1Area/CollisionShape2D.position.x = 12
		$RayCast2D.rotation_degrees = -90
	else:
		animatedsprite.flip_h = true
		$EnemyInRangeForAttack/CollisionShape2D.position.x = -12
		$MustEnemyInRangeForAttack2/CollisionShape2D.position.x = -12
		$Attack1Area/CollisionShape2D.position.x = -12
		$RayCast2D.rotation_degrees = 90

func _get_direction():
	if velocity.x < 0:
		direction_x = -1
		_flip_sprite(false)
	if velocity.x > 0:
		direction_x = 1
		_flip_sprite(true)
		
func _check_if_enemy_in_radius():
	var group_size = 0
	for body in $EnemyDetector.get_overlapping_bodies():
		if PlayerStats.enemies_for_golem.has(body):
			group_size += 1
			return true
	if group_size == 0:
		return false

func _check_if_enemy_in_range_for_attack():
	var group_size = 0
	if $EnemyInRangeForAttack.monitoring:
		for body in $EnemyInRangeForAttack.get_overlapping_bodies():
			if PlayerStats.enemies_for_golem.has(body):
				group_size += 1
				return true
	else:
		if $MustEnemyInRangeForAttack2.overlaps_body(must_follow_this_enemy) and is_instance_valid(must_follow_this_enemy):
			group_size += 1
			return true
	if group_size == 0:
		return false


func _get_direction_to_player():
	if player.global_position.x <= global_position.x:
		direction_x_to_player = -1
		_flip_sprite(false)
	else:
		direction_x_to_player = 1
		_flip_sprite(true)
		

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

func _get_closest_enemy_to_player(enemy_group):
	if len(enemy_group) > 0:
		var closest_enemy = enemy_group[0]
		for i in range(0, len(enemy_group)-1):
			if is_instance_valid(enemy_group[i]):
				if player.global_position.distance_to(enemy_group[i].global_position) < player.global_position.distance_to((closest_enemy.global_position + Vector2(5, 0))):
					closest_enemy = enemy_group[i]
			else:
				return closest_enemy

		return closest_enemy

func _basic_movement(delta) -> void:
	velocity.y += GRAVITY*delta
	
	velocity.x = MAX_SPEED * direction_x
	velocity = move_and_slide(velocity, Vector2.UP)
	
	

func _air_movement(delta) -> void:
	velocity.y = velocity.y + GRAVITY * delta if velocity.y + GRAVITY * delta < 500 else 500 
	velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func _check_if_hit_wall() -> void:
	if $RayCast2D.is_colliding() and state == FOLLOW_PLAYER:
		velocity.y = JUMP_STRENGHT
	else:
		return

func _teleport_to_player() -> void:
	global_position = player.global_position 

func _add_ksanteq() -> void:
	var enemy = follow_this_enemy
	var hejsan = abs(enemy.global_position.x - global_position.x)
	var q_pos = global_position + Vector2(0, 11)
	_get_direction_to_enemy(enemy)
	var dir = direction_x_to_enemy
	var amount = int(hejsan/24)
	for i in range(amount):
		var q = ksanteq_scene.instance()
		get_parent().add_child(q)
		q.global_position.y = q_pos.y
		q.global_position.x = q_pos.x + (i*24*dir)
		#get_parent().call_deferred("add_child", q)
		yield(get_tree().create_timer(0.35), "timeout")
	_add_ksanteqimpact(enemy)

func _add_ksanteqimpact(enemy) -> void:
	var q = ksanteqimpact_scene.instance()
	if is_instance_valid(enemy):
		q.global_position = enemy.global_position 
		get_parent().add_child(q)

#States
func _idle_state(delta) -> void:
	#if Input.is_action_just_pressed("PetAttackReady"):
	#	if searching_for_enemy:
	#		searching_for_enemy = false
	#	else:
	#		searching_for_enemy = true
	if not is_on_floor():
		_enter_air_state(false)
		return

func _run_state(delta) -> void:
	pass

func _air_state(delta) -> void:
	_air_movement(delta)
	if is_on_floor():
		_enter_idle_state()


func _attack_state(delta) -> void:
	pass

func _dead_state(delta) -> void:
	pass

func _protect_player_state(delta) -> void:
	pass

func _follow_enemy_state(delta) -> void:
	_get_direction_to_enemy(follow_this_enemy)
	velocity.y += GRAVITY*delta
	velocity.x = MAX_SPEED* direction_x_to_enemy
	velocity = move_and_slide(velocity, Vector2.UP)
	
	_check_if_enemy_in_range_for_attack()
	
	if velocity.x == 0:
		_check_if_hit_wall()
		return


func _spawn_state(delta) -> void:
	pass

func _follow_player_state(delta) -> void:
	#if Input.is_action_just_pressed("PetAttackReady"):
	#	if searching_for_enemy:
	#		searching_for_enemy = false
	#	else:
	#		searching_for_enemy = true
	_get_direction_to_player()
	velocity.y += GRAVITY*delta
	velocity.x = MAX_SPEED* direction_x_to_player
	velocity = move_and_slide(velocity, Vector2.UP)
	if velocity.x == 0:
		_check_if_hit_wall()
		return
	
func _enter_air_state(jump: bool) -> void:
	state = AIR
	if jump:
		velocity.y = JUMP_STRENGHT

func _enter_idle_state() -> void:
	state = IDLE
	animatedsprite.play("Idle")
	if wants_to_follow_enemy:
		if _check_if_enemy_in_radius():
			_enter_follow_enemy_state()
	#animationplayer.stop(true)
	#$Attack1Area/CollisionShape2D.set_deferred("disabled", true)
	
	

func _enter_follow_player_state() -> void:
	if wants_to_follow_enemy:
		if _check_if_enemy_in_radius():
			_enter_follow_enemy_state()
			return
	state = FOLLOW_PLAYER
	animatedsprite.play("Run")

func _enter_attack_state() -> void:
	state = ATTACK
	animationplayer.play("Attack1")

func _enter_attack_2_state() -> void:
	state = ATTACK
	animationplayer.play("Attack2")
	

func _enter_follow_enemy_state() -> void:
	if PlayerStats.enemies_for_golem.size() > 0:
		if not angry: 
			follow_this_enemy = _get_closest_enemy_to_player(PlayerStats.enemies_for_golem)
		animatedsprite.play("Run")
		state = FOLLOW_ENEMY	
	else:
		_enter_idle_state()


		

func _on_PlayerNearArea_body_exited(body):
	if state != ATTACK and state != FOLLOW_ENEMY:
		if body.is_in_group("Player"):
			yield(get_tree().create_timer(0.15), "timeout")
			_enter_follow_player_state()

func _on_PlayerNearArea_body_entered(body):
	if state != ATTACK and state != FOLLOW_ENEMY:
		if body.is_in_group("Player"):
			yield(get_tree().create_timer(0.15), "timeout")
			_enter_idle_state()

func _on_HitWallTimer_timeout():
	_enter_air_state(true)

func on_PlayerHurt():
	#searching_for_enemy = false
	animatedsprite.play("Angry")
	yield(get_tree().create_timer(1),"timeout")
	follow_this_enemy = _get_closest_enemy_to_player(PlayerStats.enemy_who_hurt_list)
	must_follow_this_enemy = _get_closest_enemy_to_player(PlayerStats.enemy_who_hurt_list)
	angry = true
	_enter_follow_enemy_state()
	$EnemyInRangeForAttack.set_deferred("monitoring", false)
	$MustEnemyInRangeForAttack2.set_deferred("monitoring", true)

func on_EnemyDead(body):
	if is_instance_valid(must_follow_this_enemy):
		if body == must_follow_this_enemy:
			angry = false
			PlayerStats.enemy_who_hurt_list.erase(body)
			$EnemyInRangeForAttack.set_deferred("monitoring", true)
			$MustEnemyInRangeForAttack2.set_deferred("monitoring", false)
	if PlayerStats.enemies_for_golem.has(body):
		PlayerStats.enemies_for_golem.erase(body)
		if PlayerStats.enemies_for_golem.size() == 0:
			wants_to_follow_enemy = false
			follow_this_enemy = null
			return
		follow_this_enemy = _get_closest_enemy_to_player(PlayerStats.enemies_for_golem)
		

	
func on_EnemyHurt():
	if state != ATTACK and state != FOLLOW_ENEMY:
		if not is_instance_valid(follow_this_enemy):
			if _check_if_enemy_in_radius():
				follow_this_enemy = _get_closest_enemy(PlayerStats.enemies_for_golem)
				_enter_attack_2_state()
				return
		_enter_attack_2_state()
		#	_add_ksanteq()
			#_enter_follow_enemy_state()
	


func _on_EnemyInRangeForAttack_body_entered(body):
	if PlayerStats.enemies_for_golem.has(body) and state != ATTACK:
		_enter_attack_state()



	
func _on_EnemyInRangeForAttack_body_exited(body):
	if PlayerStats.enemies_for_golem.has(body):
		if attack1_finished:
			_enter_follow_enemy_state()
		else:
			wants_to_follow_enemy = true


func _on_MustEnemyInRangeForAttack2_body_entered(body):
	if body == follow_this_enemy:
		_enter_attack_state()

func _on_MustEnemyInRangeForAttack2_body_exited(body):
	if body == follow_this_enemy:
		if attack1_finished:
			_enter_follow_enemy_state()
		else:
			wants_to_follow_enemy = true

func _on_EnemyDetector_body_entered(body):
	if PlayerStats.enemies_for_golem.has(body):
		_enter_follow_enemy_state()
	
	


func _on_PlayerDetector_body_exited(body):
	if body.is_in_group("Player"):
		_teleport_to_player()
		PlayerStats.enemy_who_hurt_list.clear()
		wants_to_follow_enemy = false
		_enter_idle_state()
	

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Attack1" or "Attack2":
		attack1_finished = true
		if $MustEnemyInRangeForAttack2.monitoring:
			if $MustEnemyInRangeForAttack2.overlaps_body(must_follow_this_enemy):
				_enter_attack_state()
			else:
				if wants_to_follow_enemy:
					_enter_follow_enemy_state()
		elif wants_to_follow_enemy:
			if _check_if_enemy_in_range_for_attack():
				_enter_attack_state()
			else:
				_enter_follow_enemy_state()
		else:
			_enter_idle_state()
	
		


func _on_AnimationPlayer_animation_started(anim_name: String) -> void:
	if anim_name == "Attack1":
		attack1_finished = false









