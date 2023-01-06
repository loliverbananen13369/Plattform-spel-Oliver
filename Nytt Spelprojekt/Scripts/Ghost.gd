extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Tween.interpolate_property(self, "modulate", Color(1,0,1,1), Color(1,0,1,0), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	queue_free()
