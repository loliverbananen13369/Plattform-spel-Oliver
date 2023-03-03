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
		

func _get_direction_to_player():
	if player.global_position.x <= global_position.x:
		direction_x_to_player = -1
		_flip_sprite(false)
	else:
		direction_x_to_player = 1
		_flip_sprite(true)
		

func _get_direction_to_enemy(enemy):
	if enemy.global_position.x <= global_position.x:
		direction_x_to_enemy = -1
		_flip_sprite(false)
	else:
		direction_x_to_enemy = 1
		_flip_sprite(true)


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

func _idle_state(delta) -> void:
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

func _enter_follow_player_state() -> void:
	state = FOLLOW_PLAYER
	animatedsprite.play("Run")

func _enter_attack_state() -> void:
	state = ATTACK
	animationplayer.play("Attack1")

func _enter_follow_enemy_state(playerhurt: bool) -> void:
	if playerhurt:
		animatedsprite.play("Angry")
		follow_this_enemy = PlayerStats.enemy_who_hurt
		yield(get_tree().create_timer(1), "timeout")
		state = FOLLOW_ENEMY
		

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
	_enter_follow_enemy_state(true)


func _on_EnemyInRangeForAttack_body_entered(body):
	if body.is_in_group("EnemyWhoHurt"):
		_enter_attack_state()



func _on_EnemyInRangeForAttack_body_exited(body):
	if state == ATTACK:
		if body.is_in_group("EnemyWhoHurt"):
			_enter_follow_enemy_state(true)
