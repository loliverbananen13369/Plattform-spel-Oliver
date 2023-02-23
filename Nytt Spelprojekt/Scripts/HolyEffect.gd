extends Node2D


var tween_values = [0.5, 1]
var tween = Tween.new()
onready var spellsprite = $Spellsprite
onready var player = get_parent().get_child(2).get_child(1).get_child(0)
var prepare_attack_particles_scene = preload("res://Scenes/PreparingAttackParticles.tscn")

var rng = RandomNumberGenerator.new()

var vector = Vector2.ZERO

func _ready() -> void:
	spellsprite.frame = 0
	spellsprite.playing = true
	if spellsprite.animation == "lvl_up":
		spellsprite.scale.x = 2
		spellsprite.modulate.r = 3
		spellsprite.modulate.b = 1.5
		spellsprite.modulate.g = 1.5
		vector = Vector2(10, -18)
	if spellsprite.animation == "holy":
		spellsprite.modulate.r = 5
		spellsprite.modulate.b = 1.5
		spellsprite.modulate.g = 1.5
		vector = Vector2(10, -18)
		_add_preparing_attack_particles(20)
	if spellsprite.animation == "dark2":
		spellsprite.scale.x = 1
		spellsprite.scale.y = 1
		spellsprite.modulate.r = 1
		spellsprite.modulate.b = 1
		spellsprite.modulate.g = 1
		vector = Vector2(10, -18)
		yield(get_tree().create_timer(7.2), "timeout")
		queue_free()
	if spellsprite.animation == "lifesteal_particles":
		spellsprite.scale.x = 0.7
		spellsprite.scale.y = 0.7
		rng.randomize()
		var random_number = rng.randi_range(1, 2)
		rng.randomize()
		var random_number_x = rng.randi_range(-5, 5)
		rng.randomize()
		var random_number_y = rng.randi_range(-5, 5)
		if random_number == 1:
			vector = Vector2(20, 0) + Vector2(random_number_x, random_number_y)
		else:
			vector = Vector2(0, 0) + Vector2(random_number_x, random_number_y)
	if spellsprite.animation == "life_steal":
		spellsprite.scale.x = 2
		spellsprite.scale.y = 2
		vector = Vector2(10, -18)
		

		#tween.name = "Tween"
		#add_child(tween)    
		#$Tween.interpolate_property(Engine, "time_scale", tween_values[0], tween_values[1], 0.5)
		#$Tween.start()


func _process(delta: float) -> void:
	global_position = player.global_position + vector

func _on_AnimatedSprite_animation_finished() -> void:
	if spellsprite.animation == "holy":
		queue_free()
	if spellsprite.animation == "lvl_up":
		queue_free()
	if spellsprite.animation == "test":
		queue_free()

func _add_preparing_attack_particles(amount) -> void:
	for n in range (amount):
		rng.randomize()
		var nrx = rng.randi_range(-100, 100)
		var nry = rng.randi_range(-100, 100)
		var particles = prepare_attack_particles_scene.instance()
		particles.global_position = player.global_position + Vector2(nrx, nry)
		get_tree().get_root().add_child(particles)
		
