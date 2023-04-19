extends AnimatedSprite


var rng = RandomNumberGenerator.new()
var number
var anim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	frame = 0
	scale.y = 2
	scale.x = 2
	$AnimationPlayer.play("Burst")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	queue_free()
	

func _on_AnimationPlayer_animation_started(anim_name: String) -> void:
	if anim_name == "Burst":
		global_position.y -= 43
		global_position.x += 25
