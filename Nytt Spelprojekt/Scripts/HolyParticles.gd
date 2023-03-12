extends Particles2D


onready var player1 = PlayerStats.player.get_node("Position2D2")#get_parent().get_child(3).get_child(1).get_child(0).get_node("Position2D2")#get_node("/root/Level 0/Node2D/Player/Position2D2")
onready var player2 = PlayerStats.player.get_node("Position2D3")#get_parent().get_child(3).get_child(1).get_child(0).get_node("Position2D3")
onready var player = PlayerStats.player.get_node("Position2D2")#get_parent().get_child(3).get_child(1).get_child(0).get_node("Position2D2")
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
	
