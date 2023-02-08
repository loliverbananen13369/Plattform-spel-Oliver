extends Particles2D


onready var player1 = get_node("/root/Level 0/Node2D/Player/Position2D2")
onready var player2 = get_node("/root/Level 0/Node2D/Player/Position2D3")
onready var player = get_node("/root/Level 0/Node2D/Player/Position2D2")
var rng = RandomNumberGenerator.new()


func _ready():
	
	rng.randomize()
	var random_number = rng.randi_range(1,2)
	if random_number == 1:
		player = player1
	else:
		player = player2
	emitting = true
	$Timer.start(0.5)
	

func _process(delta):
	global_position.x = player.global_position.x 
	global_position.y = player.global_position.y 

func _on_Timer_timeout():
	queue_free()
	
