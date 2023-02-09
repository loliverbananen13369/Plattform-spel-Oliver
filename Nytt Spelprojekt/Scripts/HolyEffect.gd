extends Node2D


var tween_values = [0.5, 1]
var tween = Tween.new()
onready var spellsprite = $Spellsprite
onready var player = get_node("/root/Level 0/Node2D/Player")

func _ready() -> void:
	spellsprite.frame = 0
	if spellsprite.animation == "lvl_up":
		spellsprite.scale.x = 2
		spellsprite.modulate.r = 3
		spellsprite.modulate.b = 1.5
		spellsprite.modulate.g = 1.5
	if spellsprite.animation == "holy":
		spellsprite.modulate.r = 5
		spellsprite.modulate.b = 1.5
		spellsprite.modulate.g = 1.5
		#spellsprite.modulate = (2, 1.5, 1.5, 1)
	if spellsprite.animation == "dark2":
		spellsprite.scale.x = 1
		spellsprite.scale.y = 1
		spellsprite.modulate.r = 1
		spellsprite.modulate.b = 1
		spellsprite.modulate.g = 1
		yield(get_tree().create_timer(7.5), "timeout")
		queue_free()
		

		#tween.name = "Tween"
		#add_child(tween)    
		#$Tween.interpolate_property(Engine, "time_scale", tween_values[0], tween_values[1], 0.5)
		#$Tween.start()


func _process(delta: float) -> void:
	global_position = player.global_position + Vector2(10, -18)

func _on_AnimatedSprite_animation_finished() -> void:
	if spellsprite.animation == "holy":
		queue_free()
	if spellsprite.animation == "lvl_up":
		queue_free()
		
