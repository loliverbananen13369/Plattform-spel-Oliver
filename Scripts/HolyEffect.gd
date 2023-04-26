extends Node2D


#När spelaren lvlar upp eller buffas


var tween_values = [0.5, 1]
var tween = Tween.new()
onready var spellsprite = $Spellsprite
onready var player = PlayerStats.player

var rng = RandomNumberGenerator.new()

var vector = Vector2.ZERO

func _ready() -> void:
	spellsprite.frame = 0
	spellsprite.playing = true
	if spellsprite.animation == "lvl_up":
		spellsprite.scale.x = 2
		spellsprite.modulate.r = 3
		spellsprite.modulate.b = 3
		spellsprite.modulate.g = 3
	if spellsprite.animation == "holy":
		spellsprite.scale.x = 2
		spellsprite.scale.y = 3
		spellsprite.modulate = "9d0088"
		vector = Vector2(0, -30)
	if spellsprite.animation == "dark2":
		spellsprite.scale.x = 1
		spellsprite.scale.y = 1
		spellsprite.modulate.r = 0.8
		spellsprite.modulate.b = 0.8
		spellsprite.modulate.g = 0.8
		vector = Vector2(0, -5)
		yield(get_tree().create_timer(7.2), "timeout")
		queue_free()
	if spellsprite.animation == "lifesteal_particles":
		spellsprite.modulate.r = 1.5
		spellsprite.modulate.b = 2.0
		spellsprite.modulate.g = 1.5
		spellsprite.scale.x = 0.6
		spellsprite.scale.y = 0.6
		rng.randomize()
		var random_number_x = rng.randi_range(-10, 10)
		rng.randomize()
		var random_number_y = rng.randi_range(5, 15)
		vector = Vector2(random_number_x, random_number_y)
	if spellsprite.animation == "life_steal":
		spellsprite.scale.x = 2
		spellsprite.scale.y = 2
		


func _process(delta: float) -> void:
	if is_instance_valid(player):
		global_position = player.global_position + vector

func _on_AnimatedSprite_animation_finished() -> void:
	if spellsprite.animation == "holy":
		queue_free()
	if spellsprite.animation == "lvl_up":
		queue_free()
	if spellsprite.animation == "test":
		queue_free()
	if spellsprite.animation == "holy_mage_test1":
		queue_free()


