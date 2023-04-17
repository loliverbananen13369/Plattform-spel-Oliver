extends CanvasLayer


var reward : String

onready var label = $Label
onready var animp = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	_give_reward()

func _give_reward():
	PlayerStats.current_xp += int(reward)
	PlayerStats.player.emit_signal("XPChanged", PlayerStats.current_xp)
	label.text = ("reward:  +" + str(reward))
	animp.play("Reward")
	yield(animp, "animation_finished")
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
