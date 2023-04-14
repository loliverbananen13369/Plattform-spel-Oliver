extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var label = $CanvasLayer/Label


func _ready():
	yield(get_tree().create_timer(3), "timeout")
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
