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

var enemies_hit_by_player = PlayerStats.enemies_hit_by_player
var searching_for_enemy := false


onready var animatedsprite = $AnimatedSprite
onready var playerdetector = $PlayerDetector
onready var playerneararea = $PlayerNearArea
onready var enemydetector = $EnemyDetector
onready var animationplayer = $AnimationPlayer

var player
var follow_this_enemy
var enemy_who_hurt
var hit_wall = false

func _ready():
	PlayerStats.connect("PlayerHurt", self, "on_PlayerHurt")
	PlayerStats.connect("EnemyDead", self, "on_EnemyDead")
	PlayerStats.connect("EnemyHurt", self, "on_EnemyHurt")
	player = get_parent().get_child(2).get_child(1).get_child(0)
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
		$Attack1Area/CollisionShape2D.position.x = 12
		$RayCast2D.rotation_degrees = -90
	else:
		animatedsprite.flip_h = true
		$EnemyInRangeForAttack/CollisionShape2D.position.x = -12
		$Attack1Area/CollisionShape2D.position.x = -12
		$RayCast2D.rotation_degrees = 90

func _get_direction():
	if velocity.x < 0:
		direction_x = -1
		_flip_sprite(false)
	if velocity.x > 0:
		direction_x = 1
		_flip_sprite(true)
		
func _check_if_enemy_who_hit_in_radius() -> void:
	if PlayerStats.enemy_who_hurt_list.size() > 0:
		if is_instance_valid(_get_closest_enemy_to_player(PlayerStats.enemy_who_hurt_list)):
			if $EnemyDetector.overlaps_body(_get_closest_enemy_to_player(PlayerStats.enemy_who_hurt_list)):
				follow_this_enemy = (_get_closest_enemy_to_player(PlayerStats.enemy_who_hurt_list))
				_enter_follow_enemy_state(true)
	
func _check_if_enemy_who_got_hit_in_radius() -> void:
	if PlayerStats.enemies_hit_by_player.size() > 0:
		if is_instance_valid(_get_closest_enemy_to_player(PlayerStats.enemies_hit_by_player)):
			if $EnemyDetector.overlaps_body(_get_closest_enemy(PlayerStats.enemies_hit_by_player)):
				follow_this_enemy = (_get_closest_enemy(PlayerStats.enemies_hit_by_player))
				_enter_follow_enemy_state(false)


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
	
	if $RayCast2D.is_colliding():
		velocity.y = JUMP_STRENGHT
	else:
		return

func _teleport_to_player() -> void:
	global_position = player.global_position 

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
	follow_this_enemy = 0
	_check_if_enemy_who_hit_in_radius()
	_check_if_enemy_who_got_hit_in_radius()
	state = IDLE
	animatedsprite.play("Idle")
	animationplayer.stop(true)
	$Attack1Area/CollisionShape2D.set_deferred("disabled", true)
	
	

func _enter_follow_player_state() -> void:
	follow_this_enemy = 0
	_check_if_enemy_who_hit_in_radius()
	_check_if_enemy_who_got_hit_in_radius()
	state = FOLLOW_PLAYER
	animatedsprite.play("Run")

func _enter_attack_state() -> void:
	state = ATTACK
	animationplayer.play("Attack1")

func _enter_follow_enemy_state(playerhurt: bool) -> void:
	if playerhurt:
		animatedsprite.play("Run")
		follow_this_enemy = _get_closest_enemy_to_player(PlayerStats.enemy_who_hurt_list)
		#$EnemyDetector.monitoring = false
	else:
		animatedsprite.play("Run")
		if is_instance_valid(enemies_hit_by_player):
			follow_this_enemy = _get_closest_enemy(PlayerStats.enemies_hit_by_player)
	state = FOLLOW_ENEMY	
		#else:
		#	_enter_idle_state()
		

func _on_PlayerNearArea_body_exited(body):
	if state != ATTACK:
		if body.is_in_group("Player"):
			yield(get_tree().create_timer(0.15), "timeout")
			_enter_follow_player_state()

func _on_PlayerNearArea_body_entered(body):
	if state != ATTACK:
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
	_enter_follow_enemy_state(true)

func on_EnemyDead(body):
	if PlayerStats.enemy_who_hurt_list.has(body):
		PlayerStats.enemy_who_hurt_list.erase(body)
		if PlayerStats.enemy_who_hurt_list.size() > 0 and $EnemyDetector.overlaps_body(body):
			_enter_follow_enemy_state(true)
		else:
			_enter_idle_state()
	elif PlayerStats.enemies_hit_by_player.has(body):
		PlayerStats.enemies_hit_by_player.erase(body)
		if PlayerStats.enemies_hit_by_player.size() > 0 and $EnemyDetector.overlaps_body(body):
			_enter_follow_enemy_state(false)
		else:
			#_teleport_to_player()
			_enter_idle_state()

		#else:
		#	_teleport_to_player()
		#	animationplayer.stop(true)
		#	$Attack1Area/CollisionShape2D.disabled = true
		#	_enter_idle_state()
	
func on_EnemyHurt():
	if state != ATTACK and state != FOLLOW_ENEMY:
		_check_if_enemy_who_got_hit_in_radius()
	#if $EnemyDetector.overlaps_body(_get_closest_enemy(PlayerStats.enemy_who_hurt_list)):
	#	if state != ATTACK:
	#		_enter_follow_enemy_state(true)
	#elif $EnemyDetector.overlaps_body(_get_closest_enemy(PlayerStats.enemies_hit_by_player)):
	#	if state != ATTACK:
	#		_enter_follow_enemy_state(false)
	pass
func _on_EnemyInRangeForAttack_body_entered(body):
	if PlayerStats.enemy_who_hurt_list.has(body):
		_enter_attack_state()
	elif PlayerStats.enemies_hit_by_player.has(body):
		_enter_attack_state()
	#if searching_for_enemy:
	#	if body.is_in_group("Enemy"):
	#		_enter_attack_state()

	
func _on_EnemyInRangeForAttack_body_exited(body):
	if PlayerStats.enemy_who_hurt_list.has(body):
		_enter_follow_enemy_state(true)
	elif PlayerStats.enemies_hit_by_player.has(body):
		_enter_follow_enemy_state(false)
	else:
		_enter_idle_state()
	#if searching_for_enemy:
	#	if body.is_in_group("Enemy"):
	#		_enter_follow_enemy_state(false)

func _on_EnemyDetector_body_entered(body):
	if PlayerStats.enemy_who_hurt_list.has(body):
		_enter_follow_enemy_state(true)
	elif PlayerStats.enemies_hit_by_player.has(body):
		_enter_follow_enemy_state(false)
	
	
	
	#if searching_for_enemy:
	#	if body.is_in_group("Enemy"):
	#		_enter_follow_enemy_state(false)


func _on_PlayerDetector_body_exited(body):
	if body.is_in_group("Player"):
		_teleport_to_player()
		_enter_idle_state()
	



