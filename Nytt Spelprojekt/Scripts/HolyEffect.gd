extends Node2D


var tween_values = [0.8, 1]
var tween = Tween.new()
onready var player = get_node("/root/Level 0/Node2D/Player")

func _ready() -> void:
	$AnimatedSprite.frame = 0
	tween.name = "Tween"
	add_child(tween)    
	$Tween.interpolate_property(Engine, "time_scale", tween_values[1], tween_values[0], 0.5)
	$Tween.start()


func _process(delta: float) -> void:
	global_position = player.global_position + Vector2(10, -20)

func _on_AnimatedSprite_animation_finished() -> void:
	Engine.time_scale = 1
	queue_free()
